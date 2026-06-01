from __future__ import annotations

import json
import logging
import shutil
import sys
import time
import webbrowser
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

try:
    from iqoptionapi.stable_api import IQ_Option
except ImportError:  # pragma: no cover
    IQ_Option = None  # type: ignore[assignment]


ROOT_DIR = Path(__file__).resolve().parent
LOG_DIR = ROOT_DIR / "logs"
CONFIG_PATH = ROOT_DIR / "config.json"
DEFAULT_TERMINAL_DIR = ROOT_DIR.parents[3]
DEFAULT_COMMON_FILES_DIR = DEFAULT_TERMINAL_DIR / "Common" / "Files"


@dataclass
class BridgeConfig:
    email: str
    password: str
    balance_mode: str
    default_amount: float
    poll_interval_seconds: float
    expiration_minutes_default: int
    mt5_common_files_dir: Path
    bridge_root_folder: str
    signals_in_folder: str
    status_folder: str
    processed_folder: str
    failed_folder: str
    ignored_folder: str
    receipts_folder: str
    allowed_symbols: list[str]
    dry_run: bool
    min_payout_percent: float
    open_browser_on_start: bool
    browser_url: str
    status_freshness_seconds: int
    iq_symbol_map: dict[str, str]
    iq_candle_interval_seconds: int
    use_otc_symbols: bool

    @property
    def bridge_root_path(self) -> Path:
        return self.mt5_common_files_dir / self.bridge_root_folder

    @property
    def inbox_path(self) -> Path:
        return self.bridge_root_path / self.signals_in_folder

    @property
    def processed_path(self) -> Path:
        return self.bridge_root_path / self.processed_folder

    @property
    def status_path(self) -> Path:
        return self.bridge_root_path / self.status_folder

    @property
    def failed_path(self) -> Path:
        return self.bridge_root_path / self.failed_folder

    @property
    def ignored_path(self) -> Path:
        return self.bridge_root_path / self.ignored_folder

    @property
    def receipts_path(self) -> Path:
        return self.bridge_root_path / self.receipts_folder


@dataclass
class MartingaleState:
    symbol: str
    enabled: bool
    max_level: int
    current_level: int = 0
    last_result: str = ""


class IQOptionBridge:
    def __init__(self, config: BridgeConfig) -> None:
        self.config = config
        self.client: Any = None
        self.browser_opened = False
        self.session_started_at = int(time.time())
        self.martingale_states: dict[str, MartingaleState] = {}
        self.pending_orders: dict[str, dict[str, Any]] = {}

    def ensure_connection(self, force: bool = False) -> None:
        if self.config.dry_run and not force:
            return

        if IQ_Option is None:
            raise RuntimeError(
                "Dependencia iqoptionapi ausente. Rode `.venv\\Scripts\\pip install -r requirements.txt`."
            )

        if self.client is not None:
            try:
                if self.client.check_connect():
                    return
            except Exception:
                self.client = None

        self.client = IQ_Option(self.config.email, self.config.password)
        connected = self.client.connect()
        if isinstance(connected, tuple):
            ok = bool(connected[0])
            reason = connected[1] if len(connected) > 1 else ""
        else:
            ok = bool(connected)
            reason = ""

        if not ok:
            raise RuntimeError(f"Falha ao conectar na IQ Option. {reason}".strip())

        self.client.change_balance(self.config.balance_mode.upper())
        logging.info("Conectado na IQ Option em modo %s", self.config.balance_mode.upper())

    def run(self) -> None:
        ensure_runtime_dirs(self.config)
        self.maybe_open_browser()
        logging.info("Bridge iniciada. Inbox: %s", self.config.inbox_path)
        if self.config.dry_run:
            logging.warning("Bridge em DRY RUN. Nenhuma ordem real sera enviada.")
        else:
            logging.info("Bridge em modo REAL. Ordens poderao ser enviadas para a IQ Option.")
        while True:
            self.process_pending_signals()
            time.sleep(self.config.poll_interval_seconds)

    def maybe_open_browser(self) -> None:
        if not self.config.open_browser_on_start or self.browser_opened:
            return

        self.open_browser()

    def open_browser(self) -> bool:
        if self.browser_opened:
            return True

        if not self.config.browser_url.strip():
            logging.warning("open_browser_on_start ativo, mas browser_url esta vazio.")
            return False

        opened = webbrowser.open(self.config.browser_url)
        if opened:
            logging.info("Pagina da IQ Option aberta no navegador: %s", self.config.browser_url)
            self.browser_opened = True
            return True
        else:
            logging.warning("Nao foi possivel abrir o navegador automaticamente.")
            return False

    def process_pending_signals(self) -> None:
        ensure_runtime_dirs(self.config)
        self.reconcile_pending_orders()
        for signal_file in sorted(self.config.inbox_path.glob("*.json")):
            try:
                payload = json.loads(signal_file.read_text(encoding="utf-8"))
                if self.should_ignore_signal_file(signal_file, payload):
                    continue
                self.process_signal_file(signal_file, payload)
            except Exception as exc:
                logging.exception("Falha ao processar %s", signal_file.name)
                if signal_file.exists():
                    self.move_with_receipt(signal_file, self.config.failed_path, {"status": "error", "message": str(exc)})

    def get_iq_symbol(self, mt5_symbol: str) -> str:
        normalized = mt5_symbol.upper()
        iq_symbol = self.config.iq_symbol_map.get(normalized, normalized)
        if self.config.use_otc_symbols and not iq_symbol.endswith("-OTC"):
            return f"{iq_symbol}-OTC"
        return iq_symbol

    def get_latest_status_for_symbol(self, symbol: str) -> dict[str, Any] | None:
        normalized = symbol.upper().strip()
        for status in self.read_mt5_statuses():
            if str(status.get("symbol", "")).upper() != normalized:
                continue
            if not status.get("is_fresh"):
                continue
            return status
        return None

    def get_martingale_state(self, symbol: str) -> MartingaleState:
        normalized = symbol.upper().strip()
        state = self.martingale_states.get(normalized)
        status = self.get_latest_status_for_symbol(normalized)
        max_level = int(status.get("ea_max_martingale") or 0) if status else 0
        mg_mode = str(status.get("ea_entrar_martingale", "") or "")
        enabled = max_level > 0 and mg_mode != "ENTRAR_MARTINGALE_NAO_USAR"

        if state is None:
            state = MartingaleState(symbol=normalized, enabled=enabled, max_level=max_level)
            self.martingale_states[normalized] = state
        else:
            state.enabled = enabled
            state.max_level = max_level
            if state.current_level > state.max_level:
                state.current_level = state.max_level

        return state

    def calculate_martingale_amount(self, base_amount: float, payout_percent: float, level: int) -> float:
        if level <= 0 or payout_percent <= 0:
            return base_amount

        payout_decimal = payout_percent / 100.0
        stake = base_amount
        accumulated_loss = 0.0
        for _ in range(level):
            accumulated_loss += stake
            desired_profit = base_amount * payout_decimal
            target = accumulated_loss + desired_profit
            stake = target / payout_decimal
        return stake

    def get_current_payout_percent(self, iq_symbol: str) -> float:
        self.ensure_connection(force=True)

        try:
            all_profit = self.client.get_all_profit() or {}
            normalized_profit = {str(key).upper(): value for key, value in dict(all_profit).items()}
            symbol_profit = normalized_profit.get(iq_symbol.upper())
            if isinstance(symbol_profit, dict):
                turbo_profit = symbol_profit.get("turbo")
                if turbo_profit is not None:
                    return float(turbo_profit) * 100.0
                binary_profit = symbol_profit.get("binary")
                if binary_profit is not None:
                    return float(binary_profit) * 100.0
        except Exception as exc:
            logging.warning("Falha ao consultar payout turbo/binary para %s: %s", iq_symbol, exc)

        try:
            digital_payout = self.client.get_digital_payout(iq_symbol)
            if digital_payout:
                return float(digital_payout)
        except Exception as exc:
            logging.warning("Falha ao consultar payout digital para %s: %s", iq_symbol, exc)

        return 0.0

    def reconcile_pending_orders(self) -> None:
        if not self.pending_orders or self.config.dry_run:
            return

        now = time.time()
        for symbol, order in list(self.pending_orders.items()):
            expiration_minutes = int(order.get("expiration_minutes") or 0)
            placed_at = float(order.get("placed_at") or 0.0)
            ready_after = placed_at + (expiration_minutes * 60.0) + 5.0
            if expiration_minutes <= 0 or now < ready_after:
                continue

            order_id = order.get("order_id")
            try:
                self.ensure_connection()
                _result, profit_value = self.client.check_win_v4(order_id)
                profit_value = float(profit_value or 0.0)
                state = self.get_martingale_state(symbol)
                if profit_value > 0:
                    state.current_level = 0
                    state.last_result = "win"
                elif profit_value < 0:
                    state.last_result = "loss"
                    if state.enabled and state.current_level < state.max_level:
                        state.current_level += 1
                    else:
                        state.current_level = 0
                else:
                    state.current_level = 0
                    state.last_result = "equal"

                logging.info(
                    "Resultado IQ resolvido: %s order_id=%s lucro=%.2f proximo_mg=%d",
                    symbol,
                    order_id,
                    profit_value,
                    state.current_level,
                )
                del self.pending_orders[symbol]
            except Exception as exc:
                logging.warning("Falha ao reconciliar ordem pendente %s/%s: %s", symbol, order_id, exc)

    def set_balance_mode(self, balance_mode: str, persist: bool = True) -> None:
        normalized = balance_mode.upper().strip()
        if normalized not in {"PRACTICE", "REAL"}:
            raise ValueError("balance_mode deve ser PRACTICE ou REAL.")

        self.config.balance_mode = normalized
        if self.client is not None:
            self.client.change_balance(normalized)
            logging.info("Modo de conta alterado para %s", normalized)

        if persist:
            save_config(
                CONFIG_PATH,
                {
                    "balance_mode": normalized,
                },
            )

    def set_dry_run(self, dry_run: bool, persist: bool = True) -> None:
        self.config.dry_run = bool(dry_run)
        if persist:
            save_config(
                CONFIG_PATH,
                {
                    "dry_run": self.config.dry_run,
                },
            )

    def set_use_otc_symbols(self, enabled: bool, persist: bool = True) -> None:
        self.config.use_otc_symbols = bool(enabled)
        if persist:
            save_config(
                CONFIG_PATH,
                {
                    "use_otc_symbols": self.config.use_otc_symbols,
                },
            )

    def build_readiness_report(self) -> dict[str, Any]:
        statuses = self.read_mt5_statuses()
        fresh_statuses = [item for item in statuses if item.get("is_fresh")]
        symbol_map_missing = [
            item["symbol"]
            for item in fresh_statuses
            if str(item.get("symbol", "")).upper() != self.get_iq_symbol(str(item.get("symbol", "")))
        ]

        checks: list[dict[str, str]] = []
        checks.append(
            {
                "name": "Credenciais IQ",
                "status": "ok" if self.config.email.strip() and self.config.password.strip() else "error",
                "message": "Credenciais configuradas." if self.config.email.strip() and self.config.password.strip() else "Email/senha ausentes no config.",
            }
        )
        checks.append(
            {
                "name": "Heartbeats MT5",
                "status": "ok" if fresh_statuses else "error",
                "message": f"{len(fresh_statuses)} ativo(s) com status recente." if fresh_statuses else "Nenhum status recente do MT5 encontrado.",
            }
        )
        checks.append(
            {
                "name": "Modo de execucao",
                "status": "warning" if self.config.dry_run else "ok",
                "message": "Dry run ativo. Nao dispara ordem real." if self.config.dry_run else "Pronto para ordem real.",
            }
        )
        checks.append(
            {
                "name": "Conta selecionada",
                "status": "ok",
                "message": f"Conta {self.config.balance_mode.upper()} selecionada.",
            }
        )

        ready_for_live = bool(fresh_statuses) and bool(self.config.email.strip()) and bool(self.config.password.strip()) and not self.config.dry_run
        return {
            "ready_for_live": ready_for_live,
            "fresh_status_count": len(fresh_statuses),
            "symbols": [str(item.get("symbol", "")).upper() for item in fresh_statuses],
            "checks": checks,
            "symbol_map_missing": symbol_map_missing,
        }

    def get_account_snapshot(self) -> dict[str, Any]:
        self.ensure_connection(force=True)
        balance = float(self.client.get_balance())
        currency = str(self.client.get_currency() or "")
        mode = str(self.client.get_balance_mode() or self.config.balance_mode).upper()
        return {
            "balance": balance,
            "currency": currency,
            "balance_mode": mode,
        }

    def get_dashboard_snapshot(self) -> dict[str, Any]:
        self.process_pending_signals()
        return {
            "account": self.get_account_snapshot(),
            "comparisons": self.compare_mt5_iq_quotes(),
            "readiness": self.build_readiness_report(),
            "signal_stats": self.get_signal_statistics(),
        }

    def get_signal_statistics(self) -> dict[str, Any]:
        ensure_runtime_dirs(self.config)
        by_symbol: dict[str, dict[str, int]] = {}

        def ensure_symbol(symbol: str) -> dict[str, int]:
            normalized = symbol.upper().strip() or "UNKNOWN"
            stats = by_symbol.setdefault(
                normalized,
                {
                    "received": 0,
                    "sent": 0,
                    "dry_run": 0,
                    "failed": 0,
                    "pending": 0,
                },
            )
            return stats

        for receipt_file in sorted(self.config.receipts_path.glob("*.receipt.json")):
            try:
                payload = json.loads(receipt_file.read_text(encoding="utf-8"))
                if not self.is_session_receipt(receipt_file, payload):
                    continue
                symbol = str(payload.get("symbol", "UNKNOWN"))
                stats = ensure_symbol(symbol)
                status = str(payload.get("status", "")).lower()
                if status == "ignored":
                    continue
                if not self.is_actionable_payload(payload):
                    continue
                stats["received"] += 1
                if status == "sent":
                    stats["sent"] += 1
                elif status == "dry_run":
                    stats["dry_run"] += 1
                elif status == "error":
                    stats["failed"] += 1
            except Exception:
                continue

        for signal_file in sorted(self.config.inbox_path.glob("*.json")):
            try:
                payload = json.loads(signal_file.read_text(encoding="utf-8"))
                if not self.is_actionable_payload(payload):
                    continue
                if not self.is_session_signal_file(signal_file):
                    continue
                symbol = str(payload.get("symbol", "UNKNOWN"))
                stats = ensure_symbol(symbol)
                stats["received"] += 1
                stats["pending"] += 1
            except Exception:
                continue

        totals = {
            "received": 0,
            "sent": 0,
            "dry_run": 0,
            "failed": 0,
            "pending": 0,
        }
        for stats in by_symbol.values():
            for key in totals:
                totals[key] += stats.get(key, 0)

        return {
            "totals": totals,
            "by_symbol": by_symbol,
        }

    def get_iq_last_quote(self, mt5_symbol: str) -> dict[str, Any]:
        iq_symbol = self.get_iq_symbol(mt5_symbol)
        self.ensure_connection(force=True)
        candles = self.client.get_candles(
            iq_symbol,
            self.config.iq_candle_interval_seconds,
            1,
            time.time(),
        )
        if not candles:
            raise RuntimeError(f"Nao foi possivel obter cotacao da IQ para {iq_symbol}.")

        candle = candles[-1]
        close_value = float(candle.get("close"))
        timestamp_raw = int(candle.get("to") or candle.get("from") or candle.get("at") or 0)
        timestamp = timestamp_raw
        while timestamp > 10_000_000_000:
            timestamp = timestamp // 1000
        return {
            "iq_symbol": iq_symbol,
            "iq_close": close_value,
            "iq_timestamp": timestamp,
            "iq_timestamp_text": time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(timestamp)) if timestamp else "",
        }

    def read_mt5_statuses(self) -> list[dict[str, Any]]:
        ensure_runtime_dirs(self.config)
        now = int(time.time())
        statuses: list[dict[str, Any]] = []
        for status_file in sorted(self.config.status_path.glob("status_*.json")):
            try:
                payload = json.loads(status_file.read_text(encoding="utf-8"))
                server_time = int(payload.get("server_time") or 0)
                payload["status_file"] = status_file.name
                payload["is_fresh"] = server_time > 0 and (now - server_time) <= self.config.status_freshness_seconds
                statuses.append(payload)
            except Exception as exc:
                logging.warning("Falha ao ler status MT5 %s: %s", status_file.name, exc)
        return statuses

    def compare_mt5_iq_quotes(self) -> list[dict[str, Any]]:
        comparisons: list[dict[str, Any]] = []
        for status in self.read_mt5_statuses():
            if not status.get("is_fresh"):
                continue

            symbol = str(status.get("symbol", "")).upper()
            bid = float(status.get("bid") or 0.0)
            ask = float(status.get("ask") or 0.0)
            last = float(status.get("last") or 0.0)
            mt5_quote = last if last > 0 else (bid + ask) / 2 if (bid > 0 and ask > 0) else bid or ask
            if mt5_quote <= 0:
                continue

            row: dict[str, Any] = {
                "symbol": symbol,
                "strategy": status.get("strategy", ""),
                "timeframe": status.get("timeframe", ""),
                "ea_balance_mode": status.get("ea_balance_mode", ""),
                "ea_tipo_aporte": status.get("ea_tipo_aporte", ""),
                "ea_valor_aporte": float(status.get("ea_valor_aporte") or 0.0),
                "ea_amount_hint": float(status.get("ea_amount_hint") or 0.0),
                "ea_payout_hint": float(status.get("ea_payout_hint") or 0.0),
                "ea_max_martingale": int(status.get("ea_max_martingale") or 0),
                "ea_entrar_martingale": status.get("ea_entrar_martingale", ""),
                "ea_bridge_expiration_minutes": int(status.get("ea_bridge_expiration_minutes") or 0),
                "ea_total_operacoes": int(status.get("ea_total_operacoes") or 0),
                "ea_total_entradas_executadas": int(status.get("ea_total_entradas_executadas") or 0),
                "ea_total_wins": int(status.get("ea_total_wins") or 0),
                "ea_total_losses": int(status.get("ea_total_losses") or 0),
                "ea_winrate_pct": float(status.get("ea_winrate_pct") or 0.0),
                "ea_win_g0": int(status.get("ea_win_g0") or 0),
                "ea_win_g1": int(status.get("ea_win_g1") or 0),
                "ea_win_g2": int(status.get("ea_win_g2") or 0),
                "ea_win_g3": int(status.get("ea_win_g3") or 0),
                "ea_banca_inicial": float(status.get("ea_banca_inicial") or 0.0),
                "ea_banca_final": float(status.get("ea_banca_final") or 0.0),
                "ea_lucro_total": float(status.get("ea_lucro_total") or 0.0),
                "ea_maior_gale": float(status.get("ea_maior_gale") or 0.0),
                "ea_max_drawdown": float(status.get("ea_max_drawdown") or 0.0),
                "ea_max_drawdown_pct": float(status.get("ea_max_drawdown_pct") or 0.0),
                "ea_media_entradas_semana": float(status.get("ea_media_entradas_semana") or 0.0),
                "ea_primeira_quebra_apos_entradas": int(status.get("ea_primeira_quebra_apos_entradas") or 0),
                "ea_score_otimizacao": float(status.get("ea_score_otimizacao") or 0.0),
                "mt5_bid": bid,
                "mt5_ask": ask,
                "mt5_last": last,
                "mt5_quote": mt5_quote,
                "mt5_spread_points": float(status.get("spread_points") or 0.0),
                "mt5_point": float(status.get("point") or 0.0),
                "mt5_digits": int(status.get("digits") or 0),
                "mt5_timestamp": int(status.get("server_time") or 0),
                "mt5_timestamp_text": status.get("server_time_text", ""),
            }
            try:
                iq_data = self.get_iq_last_quote(symbol)
                row.update(iq_data)
                diff_abs = mt5_quote - float(iq_data["iq_close"])
                row["diff_abs"] = diff_abs
                row["diff_pct"] = (diff_abs / float(iq_data["iq_close"])) * 100.0 if float(iq_data["iq_close"]) else 0.0
                point_value = row["mt5_point"]
                diff_points = abs(diff_abs) / point_value if point_value > 0 else 0.0
                tolerance_points = max(float(row["mt5_spread_points"]) or 0.0, 1.0)
                similarity_score = 100.0 / (1.0 + (diff_points / tolerance_points))
                row["diff_points"] = diff_points
                row["similarity_score"] = round(similarity_score, 2)
                row["similarity_label"] = similarity_label(similarity_score)
            except Exception as exc:
                row["iq_error"] = str(exc)
                row["iq_symbol"] = self.get_iq_symbol(symbol)
            comparisons.append(row)

        comparisons.sort(key=lambda item: item["symbol"])
        return comparisons

    def process_signal_file(self, signal_file: Path, payload: dict[str, Any]) -> None:
        direction = str(payload.get("direction", "")).upper()
        symbol = str(payload.get("symbol", "")).upper()
        iq_symbol = self.get_iq_symbol(symbol)
        if direction not in {"CALL", "PUT"}:
            raise ValueError(f"Sinal invalido ou sem direcao executavel: {direction!r}")
        if self.config.allowed_symbols and symbol not in self.config.allowed_symbols:
            raise ValueError(f"Ativo nao permitido na bridge: {symbol}")
        if symbol in self.pending_orders:
            logging.info("Sinal %s aguardando resolucao da ordem pendente de %s.", signal_file.name, symbol)
            return

        base_amount = float(payload.get("amount_hint") or 0.0)
        if base_amount <= 0:
            base_amount = self.config.default_amount
        if base_amount <= 0:
            raise ValueError("Nenhum valor de entrada definido no sinal ou no config.")

        expiration = int(payload.get("expiration_minutes") or self.config.expiration_minutes_default)
        if expiration <= 0:
            raise ValueError("expiration_minutes precisa ser maior que zero.")

        payout_hint_percent = float(payload.get("payout_hint") or 0.0)
        current_payout_percent = self.get_current_payout_percent(iq_symbol)
        if self.config.min_payout_percent > 0 and current_payout_percent < self.config.min_payout_percent:
            logging.info(
                "Sinal %s ignorado por payout insuficiente: %s payout_atual=%.2f minimo=%.2f",
                signal_file.name,
                iq_symbol,
                current_payout_percent,
                self.config.min_payout_percent,
            )
            self.move_with_receipt(
                signal_file,
                self.config.ignored_path,
                {
                    "status": "ignored",
                    "reason": "payout_below_minimum",
                    "symbol": symbol,
                    "iq_symbol": iq_symbol,
                    "direction": direction,
                    "amount": amount,
                    "expiration_minutes": expiration,
                    "payout_hint_percent": payout_hint_percent,
                    "payout_current_percent": round(current_payout_percent, 2),
                    "min_payout_percent": self.config.min_payout_percent,
                    "signal_file": signal_file.name,
                    "processed_at": int(time.time()),
                },
            )
            return

        state = self.get_martingale_state(symbol)
        payout_for_amount = current_payout_percent if current_payout_percent > 0 else payout_hint_percent
        amount = round(self.calculate_martingale_amount(base_amount, payout_for_amount, state.current_level), 2)

        receipt: dict[str, Any] = {
            "status": "dry_run" if self.config.dry_run else "sent",
            "symbol": symbol,
            "iq_symbol": iq_symbol,
            "direction": direction,
            "base_amount": round(base_amount, 2),
            "amount": amount,
            "martingale_enabled": state.enabled,
            "martingale_level": state.current_level,
            "martingale_max_level": state.max_level,
            "expiration_minutes": expiration,
            "payout_hint_percent": payout_hint_percent,
            "payout_current_percent": round(current_payout_percent, 2),
            "min_payout_percent": self.config.min_payout_percent,
            "signal_file": signal_file.name,
            "processed_at": int(time.time()),
        }

        if not self.config.dry_run:
            self.ensure_connection()
            ok, order_id = self.client.buy(amount, iq_symbol, direction.lower(), expiration)
            if not ok:
                raise RuntimeError(f"IQ Option recusou a ordem para {iq_symbol}.")
            receipt["order_id"] = order_id
            receipt["placed_at"] = int(time.time())
            self.pending_orders[symbol] = {
                "order_id": order_id,
                "placed_at": time.time(),
                "expiration_minutes": expiration,
                "amount": amount,
                "base_amount": base_amount,
                "martingale_level": state.current_level,
            }

        logging.info(
            "Sinal %s processado: mt5=%s iq=%s %s amount=%s base=%s mg=%s exp=%s",
            signal_file.name,
            symbol,
            iq_symbol,
            direction,
            amount,
            base_amount,
            state.current_level,
            expiration,
        )
        self.move_with_receipt(signal_file, self.config.processed_path, receipt)

    def should_ignore_signal_file(self, signal_file: Path, payload: dict[str, Any]) -> bool:
        if not self.is_session_signal_file(signal_file):
            logging.info("Ignorando backlog anterior a sessao: %s", signal_file.name)
            self.move_with_receipt(
                signal_file,
                self.config.ignored_path,
                {
                    "status": "ignored",
                    "reason": "stale_startup_backlog",
                    "symbol": str(payload.get("symbol", "UNKNOWN")).upper(),
                    "direction": str(payload.get("direction", "")).upper(),
                    "signal_file": signal_file.name,
                    "processed_at": int(time.time()),
                },
            )
            return True

        if not self.is_actionable_payload(payload):
            logging.info("Ignorando sinal sem direcao executavel: %s", signal_file.name)
            self.move_with_receipt(
                signal_file,
                self.config.ignored_path,
                {
                    "status": "ignored",
                    "reason": "non_actionable_direction",
                    "symbol": str(payload.get("symbol", "UNKNOWN")).upper(),
                    "direction": str(payload.get("direction", "")).upper(),
                    "signal_file": signal_file.name,
                    "processed_at": int(time.time()),
                },
            )
            return True

        return False

    def is_actionable_payload(self, payload: dict[str, Any]) -> bool:
        direction = str(payload.get("direction", "")).upper().strip()
        return direction in {"CALL", "PUT"}

    def is_session_signal_file(self, signal_file: Path) -> bool:
        try:
            return int(signal_file.stat().st_mtime) >= self.session_started_at
        except OSError:
            return False

    def is_session_receipt(self, receipt_file: Path, payload: dict[str, Any]) -> bool:
        processed_at = int(payload.get("processed_at") or 0)
        if processed_at > 0:
            return processed_at >= self.session_started_at
        try:
            return int(receipt_file.stat().st_mtime) >= self.session_started_at
        except OSError:
            return False

    def move_with_receipt(self, signal_file: Path, target_dir: Path, receipt: dict[str, Any]) -> None:
        target_dir.mkdir(parents=True, exist_ok=True)
        self.config.receipts_path.mkdir(parents=True, exist_ok=True)

        if signal_file.exists():
            destination = target_dir / signal_file.name
            shutil.move(str(signal_file), str(destination))

        receipt_path = self.config.receipts_path / f"{signal_file.stem}.receipt.json"
        receipt_path.write_text(json.dumps(receipt, indent=2, ensure_ascii=True), encoding="utf-8")


def setup_logging() -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[
            logging.FileHandler(LOG_DIR / "bridge.log", encoding="utf-8"),
            logging.StreamHandler(sys.stdout),
        ],
    )


def ensure_runtime_dirs(config: BridgeConfig) -> None:
    config.inbox_path.mkdir(parents=True, exist_ok=True)
    config.status_path.mkdir(parents=True, exist_ok=True)
    config.processed_path.mkdir(parents=True, exist_ok=True)
    config.failed_path.mkdir(parents=True, exist_ok=True)
    config.ignored_path.mkdir(parents=True, exist_ok=True)
    config.receipts_path.mkdir(parents=True, exist_ok=True)


def load_config(config_path: Path) -> BridgeConfig:
    if not config_path.exists():
        raise FileNotFoundError(
            f"Config ausente em {config_path}. Copie config.example.json para config.json e preencha suas credenciais."
        )

    raw = json.loads(config_path.read_text(encoding="utf-8"))
    symbol_map_raw = raw.get("iq_symbol_map") or {}
    if not isinstance(symbol_map_raw, dict):
        raise ValueError("iq_symbol_map deve ser um objeto JSON no formato {\"MT5\": \"IQ\"}.")
    common_files_dir = Path(raw.get("mt5_common_files_dir") or DEFAULT_COMMON_FILES_DIR)
    config = BridgeConfig(
        email=str(raw.get("email", "")),
        password=str(raw.get("password", "")),
        balance_mode=str(raw.get("balance_mode", "PRACTICE")),
        default_amount=float(raw.get("default_amount", 0.0)),
        poll_interval_seconds=float(raw.get("poll_interval_seconds", 1.0)),
        expiration_minutes_default=int(raw.get("expiration_minutes_default", 1)),
        mt5_common_files_dir=common_files_dir,
        bridge_root_folder=str(raw.get("bridge_root_folder", "OpBinBridge")),
        signals_in_folder=str(raw.get("signals_in_folder", "signals_in")),
        status_folder=str(raw.get("status_folder", "status")),
        processed_folder=str(raw.get("processed_folder", "signals_processed")),
        failed_folder=str(raw.get("failed_folder", "signals_failed")),
        ignored_folder=str(raw.get("ignored_folder", "signals_ignored")),
        receipts_folder=str(raw.get("receipts_folder", "receipts")),
        allowed_symbols=[str(item).upper() for item in raw.get("allowed_symbols", [])],
        dry_run=bool(raw.get("dry_run", True)),
        min_payout_percent=float(raw.get("min_payout_percent", 0.0)),
        open_browser_on_start=bool(raw.get("open_browser_on_start", False)),
        browser_url=str(raw.get("browser_url", "https://iqoption.com/")),
        status_freshness_seconds=int(raw.get("status_freshness_seconds", 10)),
        iq_symbol_map={str(key).upper(): str(value).upper() for key, value in symbol_map_raw.items()},
        iq_candle_interval_seconds=int(raw.get("iq_candle_interval_seconds", 60)),
        use_otc_symbols=bool(raw.get("use_otc_symbols", False)),
    )
    validate_config(config)
    return config


def save_config(config_path: Path, updates: dict[str, Any]) -> None:
    raw: dict[str, Any] = {}
    if config_path.exists():
        raw = json.loads(config_path.read_text(encoding="utf-8"))
    raw.update(updates)
    config_path.write_text(json.dumps(raw, indent=2, ensure_ascii=True), encoding="utf-8")


def validate_config(config: BridgeConfig) -> None:
    if config.default_amount < 0:
        raise ValueError("default_amount nao pode ser negativo.")

    if config.poll_interval_seconds <= 0:
        raise ValueError("poll_interval_seconds precisa ser maior que zero.")

    if config.expiration_minutes_default <= 0:
        raise ValueError("expiration_minutes_default precisa ser maior que zero.")

    if config.min_payout_percent < 0:
        raise ValueError("min_payout_percent nao pode ser negativo.")

    if config.status_freshness_seconds <= 0:
        raise ValueError("status_freshness_seconds precisa ser maior que zero.")

    if config.iq_candle_interval_seconds <= 0:
        raise ValueError("iq_candle_interval_seconds precisa ser maior que zero.")

    if config.balance_mode.upper() not in {"PRACTICE", "REAL"}:
        raise ValueError("balance_mode deve ser PRACTICE ou REAL.")

    if config.open_browser_on_start or config.browser_url.strip():
        parsed = urlparse(config.browser_url.strip())
        if parsed.scheme not in {"http", "https"} or not parsed.netloc:
            raise ValueError(
                f"browser_url invalida: {config.browser_url!r}. Use uma URL completa, por exemplo https://iqoption.com/."
            )


def similarity_label(score: float) -> str:
    if score >= 95:
        return "Muito alta"
    if score >= 80:
        return "Alta"
    if score >= 60:
        return "Media"
    if score >= 40:
        return "Baixa"
    return "Muito baixa"


def main() -> int:
    setup_logging()
    config = load_config(CONFIG_PATH)
    bridge = IQOptionBridge(config)
    try:
        bridge.run()
    except KeyboardInterrupt:
        logging.info("Bridge encerrada pelo usuario.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
