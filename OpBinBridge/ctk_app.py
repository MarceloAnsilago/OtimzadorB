from __future__ import annotations

import json
import threading
import time
import tkinter as tk
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from tkinter import messagebox, ttk
from typing import Any

import iqoptionapi.constants as OP_code
from iqoptionapi.stable_api import IQ_Option


ROOT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = ROOT_DIR / "config.json"


@dataclass
class AppConfig:
    email: str
    password: str
    balance_mode: str
    min_payout_percent: float
    use_otc_symbols: bool


def load_config(path: Path) -> AppConfig:
    if not path.exists():
        raise FileNotFoundError(f"Config ausente em {path}.")
    raw = json.loads(path.read_text(encoding="utf-8"))
    return AppConfig(
        email=str(raw.get("email", "")).strip(),
        password=str(raw.get("password", "")).strip(),
        balance_mode=str(raw.get("balance_mode", "PRACTICE")).upper().strip() or "PRACTICE",
        min_payout_percent=float(raw.get("min_payout_percent", 80.0)),
        use_otc_symbols=bool(raw.get("use_otc_symbols", False)),
    )


def save_config(path: Path, config: AppConfig) -> None:
    raw: dict[str, Any] = {}
    if path.exists():
        raw = json.loads(path.read_text(encoding="utf-8"))
    raw.update(
        {
            "email": config.email,
            "password": config.password,
            "balance_mode": config.balance_mode,
            "min_payout_percent": config.min_payout_percent,
            "use_otc_symbols": config.use_otc_symbols,
        }
    )
    path.write_text(json.dumps(raw, indent=2, ensure_ascii=True), encoding="utf-8")


class IQPayoutScanner:
    def __init__(self, config: AppConfig) -> None:
        self.config = config
        self.client: IQ_Option | None = None
        self._lock = threading.RLock()

    def _call_with_timeout(self, timeout_seconds: float, func: Any, *args: Any) -> Any:
        result: dict[str, Any] = {"done": False, "value": None, "error": None}

        def runner() -> None:
            try:
                result["value"] = func(*args)
            except Exception as exc:
                result["error"] = exc
            finally:
                result["done"] = True

        worker = threading.Thread(target=runner, daemon=True)
        worker.start()
        worker.join(timeout_seconds)
        if not result["done"]:
            raise TimeoutError(f"Operacao excedeu {timeout_seconds:.1f}s.")
        if result["error"] is not None:
            raise result["error"]
        return result["value"]

    def connect(self) -> None:
        with self._lock:
            if self.client is not None:
                try:
                    if self.client.check_connect():
                        return
                except Exception:
                    self.client = None

            client = IQ_Option(self.config.email, self.config.password)
            result = self._call_with_timeout(8.0, client.connect)
            if isinstance(result, tuple):
                ok = bool(result[0])
                reason = str(result[1] if len(result) > 1 else "")
            else:
                ok = bool(result)
                reason = ""
            if not ok:
                raise RuntimeError(f"Falha ao conectar na IQ Option. {reason}".strip())

            self._call_with_timeout(5.0, client.change_balance, self.config.balance_mode)
            self._hydrate_binary_actives_map(client)
            self.client = client

    def _log_order_attempt(
        self,
        order_symbol: str,
        amount: float,
        direction: str,
        expiration_minutes: int,
        preferred_kind: str,
        turbo_open: bool,
        binary_open: bool,
    ) -> None:
        print("=" * 50)
        print("ATIVO:", order_symbol)
        print("VALOR:", amount)
        print("DIRECAO:", direction)
        print("EXP:", expiration_minutes)
        print("TIPO_PREFERIDO:", preferred_kind)
        print("TURBO_OPEN:", turbo_open)
        print("BINARY_OPEN:", binary_open)
        print("=" * 50)

    def scan(self, min_payout_percent: float, include_otc: bool) -> list[dict[str, Any]]:
        self.connect()
        assert self.client is not None
        all_profit = dict(self.client.get_all_profit() or {})
        turbo_open_map, binary_open_map = self._get_binary_open_maps()
        rows: list[dict[str, Any]] = []

        for symbol, profit_data in all_profit.items():
            normalized_symbol = str(symbol).upper()
            if not include_otc and normalized_symbol.endswith("-OTC"):
                continue

            turbo = self._to_percent((profit_data or {}).get("turbo"))
            binary = self._to_percent((profit_data or {}).get("binary"))
            best = max(turbo, binary)
            if best < min_payout_percent:
                continue

            if binary >= turbo:
                best_kind = "BINARY"
            else:
                best_kind = "TURBO"

            order_symbol = self.normalize_order_symbol(normalized_symbol)
            if order_symbol not in OP_code.ACTIVES:
                continue
            turbo_open = bool(self._get_open_info(normalized_symbol, turbo_open_map).get("open"))
            binary_open = bool(self._get_open_info(normalized_symbol, binary_open_map).get("open"))
            if not turbo_open and not binary_open:
                continue

            rows.append(
                {
                    "symbol": normalized_symbol,
                    "order_symbol": order_symbol,
                    "turbo": turbo,
                    "binary": binary,
                    "best": best,
                    "best_kind": best_kind,
                    "turbo_open": turbo_open,
                    "binary_open": binary_open,
                    "operable_now": self._get_operability_label(normalized_symbol, turbo_open_map, binary_open_map),
                }
            )

        rows.sort(key=lambda item: (-float(item["best"]), item["symbol"]))
        return rows

    def place_order(
        self,
        symbol: str,
        amount: float,
        direction: str,
        expiration_minutes: int,
        expiration_timestamp: int,
    ) -> Any:
        self.connect()
        assert self.client is not None
        order_symbol = self.normalize_order_symbol(symbol)
        if order_symbol not in OP_code.ACTIVES:
            raise RuntimeError(f"{order_symbol} nao existe no mapa ACTIVES da iqoptionapi.")
        turbo_open_map, binary_open_map = self._get_binary_open_maps()
        turbo_info = self._get_open_info(symbol, turbo_open_map)
        binary_info = self._get_open_info(symbol, binary_open_map)
        if not turbo_info and not binary_info:
            raise RuntimeError(f"{order_symbol} nao apareceu no mapa de ativos binary/turbo da IQ.")
        turbo_open = bool(turbo_info.get("open"))
        binary_open = bool(binary_info.get("open"))
        if not turbo_open and not binary_open:
            raise RuntimeError(f"{order_symbol} esta fechado para binary/turbo na IQ neste momento.")
        operability_label = self._get_operability_label(symbol, turbo_open_map, binary_open_map)
        if operability_label.startswith("NAO"):
            otc_hint = self._build_otc_preference_hint(symbol, turbo_open_map, binary_open_map)
            if otc_hint:
                raise RuntimeError(otc_hint)
        option_kind = self._get_option_kind_for_duration(int(expiration_minutes))
        if option_kind == "turbo" and not turbo_open:
            raise RuntimeError(f"{order_symbol} nao esta aberto em TURBO neste momento.")
        if option_kind == "binary" and not binary_open:
            raise RuntimeError(f"{order_symbol} nao esta aberto em BINARY neste momento.")

        balance = self._call_with_timeout(5.0, self.client.get_balance)
        print("CONECTADO:", self.client.check_connect())
        print("SALDO:", balance)
        self._log_order_attempt(
            order_symbol,
            float(amount),
            direction,
            int(expiration_minutes),
            option_kind.upper(),
            turbo_open,
            binary_open,
        )
        ok, order_id = self._call_with_timeout(
            8.0,
            self.client.buy_by_raw_expirations,
            float(amount),
            order_symbol,
            direction.lower(),
            option_kind,
            int(expiration_timestamp),
        )
        print("OK:", ok)
        print("ORDER ID:", order_id)
        if not ok:
            otc_hint = self._build_unavailable_hint(symbol, turbo_open_map, binary_open_map, order_id)
            if otc_hint:
                raise RuntimeError(otc_hint)
            raise RuntimeError(f"IQ recusou a ordem para {order_symbol}: {order_id!r}")
        return order_id, order_symbol

    def get_expiration_options(self) -> list[dict[str, Any]]:
        self.connect()
        assert self.client is not None
        server_timestamp = self._get_server_timestamp()
        options: list[dict[str, Any]] = []
        for duration, expiration_timestamp, remaining_seconds in self._build_expiration_schedule(server_timestamp):
            if remaining_seconds <= 0:
                continue
            options.append(
                {
                    "duration_minutes": duration,
                    "expiration_timestamp": expiration_timestamp,
                    "remaining_seconds": remaining_seconds,
                    "time_label": time.strftime("%H:%M", time.localtime(expiration_timestamp)),
                }
            )
        return options

    def normalize_order_symbol(self, symbol: str) -> str:
        normalized = str(symbol).upper().strip()
        if normalized in OP_code.ACTIVES:
            return normalized
        if normalized.endswith("-OTC-OP") and normalized[:-3] in OP_code.ACTIVES:
            return normalized[:-3]
        if normalized.endswith("-OP") and normalized[:-3] in OP_code.ACTIVES:
            return normalized[:-3]
        return normalized

    def _hydrate_binary_actives_map(self, client: IQ_Option) -> None:
        init_v2 = dict(self._call_with_timeout(10.0, client.get_all_init_v2) or {})
        for branch in ("binary", "turbo"):
            actives = dict((init_v2.get(branch) or {}).get("actives") or {})
            for active_id, item in actives.items():
                raw_name = str((item or {}).get("name") or "").strip()
                if "." in raw_name:
                    raw_name = raw_name.split(".", 1)[1]
                symbol_name = raw_name.upper()
                if not symbol_name:
                    continue
                try:
                    OP_code.ACTIVES[symbol_name] = int(active_id)
                except Exception:
                    continue

    def _get_binary_open_maps(self) -> tuple[dict[str, Any], dict[str, Any]]:
        assert self.client is not None
        init_v2 = dict(self._call_with_timeout(10.0, self.client.get_all_init_v2) or {})
        turbo_open_map = self._extract_open_map(init_v2.get("turbo"))
        binary_open_map = self._extract_open_map(init_v2.get("binary"))
        return turbo_open_map, binary_open_map

    def _extract_open_map(self, option_data: Any) -> dict[str, dict[str, bool]]:
        actives = dict((option_data or {}).get("actives") or {})
        result: dict[str, dict[str, bool]] = {}
        for active in actives.values():
            item = dict(active or {})
            raw_name = str(item.get("name") or "").strip()
            if "." in raw_name:
                name = raw_name.split(".", 1)[1]
            else:
                name = raw_name
            if not name:
                continue
            enabled = bool(item.get("enabled"))
            is_suspended = bool(item.get("is_suspended"))
            result[name.upper()] = {"open": enabled and not is_suspended}
        return result

    def _get_open_info(self, symbol: str, open_map: dict[str, Any]) -> dict[str, Any]:
        for candidate in self._symbol_candidates(symbol):
            info = dict(open_map.get(candidate) or {})
            if info:
                return info
        return {}

    def _symbol_candidates(self, symbol: str) -> list[str]:
        raw = str(symbol).upper().strip()
        normalized = self.normalize_order_symbol(raw)
        candidates: list[str] = []
        if raw.endswith("-OTC") or raw.endswith("-OTC-OP"):
            source_candidates = (
                raw,
                normalized,
                f"{normalized}-OP",
            )
        else:
            source_candidates = (
                raw,
                normalized,
                f"{normalized}-OP",
            )
        for candidate in source_candidates:
            if candidate and candidate not in candidates:
                candidates.append(candidate)
        return candidates

    def _get_operability_label(
        self,
        symbol: str,
        turbo_open_map: dict[str, Any],
        binary_open_map: dict[str, Any],
    ) -> str:
        raw = str(symbol).upper().strip()
        turbo_open = bool(self._get_open_info(symbol, turbo_open_map).get("open"))
        binary_open = bool(self._get_open_info(symbol, binary_open_map).get("open"))
        if turbo_open or binary_open:
            return "SIM"
        if raw.endswith("-OTC") or raw.endswith("-OTC-OP"):
            return "NAO"
        otc_hint = self._build_otc_preference_hint(symbol, turbo_open_map, binary_open_map)
        if otc_hint:
            otc_symbol = f"{self.normalize_order_symbol(symbol)}-OTC"
            return f"NAO - use {otc_symbol}"
        return "NAO"

    def _build_otc_preference_hint(
        self,
        symbol: str,
        turbo_open_map: dict[str, Any],
        binary_open_map: dict[str, Any],
    ) -> str:
        normalized = self.normalize_order_symbol(symbol)
        raw = str(symbol).upper().strip()
        if raw.endswith("-OTC") or raw.endswith("-OTC-OP"):
            return ""
        regular_turbo_open = bool(self._get_open_info(normalized, turbo_open_map).get("open"))
        regular_binary_open = bool(self._get_open_info(normalized, binary_open_map).get("open"))
        if regular_turbo_open or regular_binary_open:
            return ""
        otc_symbol = f"{normalized}-OTC"
        if otc_symbol not in OP_code.ACTIVES:
            return ""
        turbo_open = bool(self._get_open_info(otc_symbol, turbo_open_map).get("open"))
        binary_open = bool(self._get_open_info(otc_symbol, binary_open_map).get("open"))
        if not turbo_open and not binary_open:
            return ""
        available_kinds: list[str] = []
        if turbo_open:
            available_kinds.append("TURBO")
        if binary_open:
            available_kinds.append("BINARY")
        kinds_text = " / ".join(available_kinds) if available_kinds else "IQ"
        return (
            f"A IQ recusou o mercado regular para {normalized} neste momento. "
            f"O equivalente OTC ({otc_symbol}) aparece disponivel em {kinds_text}. "
            f"Marque 'Incluir OTC' e selecione {otc_symbol}."
        )

    def _build_unavailable_hint(
        self,
        symbol: str,
        turbo_open_map: dict[str, Any],
        binary_open_map: dict[str, Any],
        order_error: Any,
    ) -> str:
        message = str(order_error or "")
        if "asset is not available at the moment" not in message.lower():
            return ""
        return self._build_otc_preference_hint(symbol, turbo_open_map, binary_open_map)

    def _get_server_timestamp(self) -> int:
        assert self.client is not None
        server_timestamp = getattr(getattr(self.client, "api", None), "timesync", None)
        value = int(getattr(server_timestamp, "server_timestamp", 0) or 0)
        if value > 0:
            return value
        return int(time.time())

    def _build_expiration_schedule(self, timestamp: int) -> list[tuple[int, int, int]]:
        now_date = datetime.fromtimestamp(timestamp)
        expiration_date = now_date.replace(second=0, microsecond=0)
        if int((expiration_date + timedelta(minutes=1)).timestamp()) - timestamp > 30:
            expiration_date = expiration_date + timedelta(minutes=1)
        else:
            expiration_date = expiration_date + timedelta(minutes=2)

        expirations: list[int] = []
        probe = expiration_date
        for _ in range(5):
            expirations.append(int(probe.timestamp()))
            probe = probe + timedelta(minutes=1)

        added_quarters = 0
        probe = now_date.replace(second=0, microsecond=0)
        while added_quarters < 11:
            if int(probe.strftime("%M")) % 15 == 0 and int(probe.timestamp()) - timestamp > 60 * 5:
                expirations.append(int(probe.timestamp()))
                added_quarters += 1
            probe = probe + timedelta(minutes=1)

        schedule: list[tuple[int, int, int]] = []
        for index, expiration_timestamp in enumerate(expirations):
            duration = index + 1 if index < 5 else 15 * (index - 4)
            remaining_seconds = max(0, expiration_timestamp - timestamp)
            schedule.append((duration, expiration_timestamp, remaining_seconds))
        return schedule

    def _get_option_kind_for_duration(self, duration: int) -> str:
        return "turbo" if int(duration) <= 5 else "binary"

    def _to_percent(self, value: Any) -> float:
        if value is None:
            return 0.0
        try:
            return round(float(value) * 100.0, 2)
        except Exception:
            return 0.0


class App(tk.Tk):
    def __init__(self, scanner: IQPayoutScanner, config: AppConfig) -> None:
        super().__init__()
        self.scanner = scanner
        self.config_model = config

        self.title("IQ Payout Scanner")
        self.geometry("980x700")
        self.minsize(860, 620)
        self.configure(bg="#101820")

        self.status_var = tk.StringVar(value="Pronto para buscar payouts.")
        self.updated_var = tk.StringVar(value="-")
        self.balance_mode_var = tk.StringVar(value=config.balance_mode)
        self.min_payout_var = tk.StringVar(value=f"{config.min_payout_percent:.0f}")
        self.otc_var = tk.BooleanVar(value=config.use_otc_symbols)
        self.selected_symbol_var = tk.StringVar(value="Nenhum ativo selecionado")
        self.selected_order_symbol_var = tk.StringVar(value="-")
        self.selected_kind_var = tk.StringVar(value="-")
        self.selected_operability_var = tk.StringVar(value="-")
        self.selected_execution_kind_var = tk.StringVar(value="-")
        self.selected_expiration_detail_var = tk.StringVar(value="-")
        self.iq_clock_var = tk.StringVar(value="Hora IQ: -")
        self.order_amount_var = tk.StringVar(value="2")
        self.order_direction_var = tk.StringVar(value="CALL")
        self.order_expiration_var = tk.StringVar(value="Selecione uma expiracao")
        self.expiration_status_var = tk.StringVar(value="Selecione um ativo para carregar as expiracoes da IQ.")
        self.expiration_values: list[str] = []
        self.expiration_options_by_label: dict[str, dict[str, int]] = {}

        self._configure_style()
        self._build_layout()

    def _configure_style(self) -> None:
        style = ttk.Style(self)
        try:
            style.theme_use("clam")
        except tk.TclError:
            pass
        style.configure("Root.TFrame", background="#101820")
        style.configure("Card.TFrame", background="#142235")
        style.configure("Head.TLabel", background="#142235", foreground="#f3f7fb", font=("Segoe UI", 24, "bold"))
        style.configure("Body.TLabel", background="#142235", foreground="#d1d9e4", font=("Segoe UI", 10))
        style.configure("MetricValue.TLabel", background="#142235", foreground="#f3f7fb", font=("Segoe UI", 18, "bold"))
        style.configure("MetricLabel.TLabel", background="#142235", foreground="#8ea3bb", font=("Segoe UI", 9))
        style.configure("Treeview", rowheight=28, font=("Consolas", 10))
        style.configure("Treeview.Heading", font=("Segoe UI", 9, "bold"))

    def _build_layout(self) -> None:
        root = ttk.Frame(self, style="Root.TFrame", padding=14)
        root.pack(fill="both", expand=True)
        root.columnconfigure(0, weight=1)
        root.rowconfigure(2, weight=1)

        header = ttk.Frame(root, style="Card.TFrame", padding=18)
        header.grid(row=0, column=0, sticky="ew")
        header.columnconfigure(0, weight=1)
        ttk.Label(header, text="IQ Payout Scanner", style="Head.TLabel").grid(row=0, column=0, sticky="w")
        ttk.Label(header, textvariable=self.status_var, style="Body.TLabel").grid(row=1, column=0, sticky="w", pady=(6, 0))
        ttk.Label(header, textvariable=self.updated_var, style="Body.TLabel").grid(row=1, column=1, sticky="e")

        top = ttk.Frame(root, style="Root.TFrame")
        top.grid(row=1, column=0, sticky="ew", pady=(12, 12))
        top.columnconfigure(0, weight=0)
        top.columnconfigure(1, weight=1)

        controls = ttk.Frame(top, style="Card.TFrame", padding=16)
        controls.grid(row=0, column=0, sticky="nsw", padx=(0, 10))
        controls.columnconfigure(0, weight=1)

        ttk.Label(controls, text="Controles", style="Head.TLabel").grid(row=0, column=0, sticky="w", pady=(0, 12))
        ttk.Label(controls, text="Conta", style="Body.TLabel").grid(row=1, column=0, sticky="w", pady=(0, 4))
        balance_combo = ttk.Combobox(controls, textvariable=self.balance_mode_var, state="readonly", values=("PRACTICE", "REAL"))
        balance_combo.grid(row=2, column=0, sticky="ew", pady=(0, 10))
        balance_combo.bind("<<ComboboxSelected>>", lambda _event: self._persist_config())

        ttk.Label(controls, text="Payout minimo (%)", style="Body.TLabel").grid(row=3, column=0, sticky="w", pady=(0, 4))
        payout_entry = ttk.Entry(controls, textvariable=self.min_payout_var)
        payout_entry.grid(row=4, column=0, sticky="ew", pady=(0, 10))

        ttk.Checkbutton(
            controls,
            text="Incluir OTC",
            variable=self.otc_var,
            command=self._persist_config,
        ).grid(row=5, column=0, sticky="w", pady=(0, 12))

        ttk.Button(controls, text="Buscar payouts", command=self._scan_in_background).grid(row=6, column=0, sticky="ew", pady=4)
        ttk.Button(controls, text="Salvar config", command=self._persist_config).grid(row=7, column=0, sticky="ew", pady=4)

        help_card = ttk.Frame(top, style="Card.TFrame", padding=16)
        help_card.grid(row=0, column=1, sticky="nsew")
        help_card.columnconfigure(1, weight=1)
        ttk.Label(help_card, text="Ordem", style="Head.TLabel").grid(row=0, column=0, columnspan=2, sticky="w", pady=(0, 12))
        ttk.Label(help_card, text="Ativo selecionado", style="Body.TLabel").grid(row=1, column=0, sticky="w")
        ttk.Label(help_card, textvariable=self.selected_symbol_var, style="MetricValue.TLabel").grid(row=1, column=1, sticky="w")
        ttk.Label(help_card, text="Simbolo de ordem", style="Body.TLabel").grid(row=2, column=0, sticky="w", pady=(10, 0))
        ttk.Label(help_card, textvariable=self.selected_order_symbol_var, style="Body.TLabel").grid(row=2, column=1, sticky="w", pady=(10, 0))
        ttk.Label(help_card, text="Melhor tipo", style="Body.TLabel").grid(row=3, column=0, sticky="w", pady=(10, 0))
        ttk.Label(help_card, textvariable=self.selected_kind_var, style="Body.TLabel").grid(row=3, column=1, sticky="w", pady=(10, 0))
        ttk.Label(help_card, text="Operavel agora", style="Body.TLabel").grid(row=4, column=0, sticky="w", pady=(10, 0))
        ttk.Label(help_card, textvariable=self.selected_operability_var, style="Body.TLabel").grid(row=4, column=1, sticky="w", pady=(10, 0))
        ttk.Label(help_card, text="Tipo enviado", style="Body.TLabel").grid(row=5, column=0, sticky="w", pady=(10, 0))
        ttk.Label(help_card, textvariable=self.selected_execution_kind_var, style="Body.TLabel").grid(
            row=5, column=1, sticky="w", pady=(10, 0)
        )
        ttk.Label(help_card, text="Expiracao enviada", style="Body.TLabel").grid(row=6, column=0, sticky="w", pady=(10, 0))
        ttk.Label(help_card, textvariable=self.selected_expiration_detail_var, style="Body.TLabel").grid(
            row=6, column=1, sticky="w", pady=(10, 0)
        )
        ttk.Label(help_card, textvariable=self.iq_clock_var, style="MetricLabel.TLabel").grid(row=7, column=0, columnspan=2, sticky="w", pady=(10, 0))
        ttk.Label(help_card, text="Valor", style="Body.TLabel").grid(row=8, column=0, sticky="w", pady=(14, 4))
        ttk.Entry(help_card, textvariable=self.order_amount_var).grid(row=8, column=1, sticky="ew", pady=(14, 4))
        ttk.Label(help_card, text="Direcao", style="Body.TLabel").grid(row=9, column=0, sticky="w", pady=(8, 4))
        ttk.Combobox(help_card, textvariable=self.order_direction_var, state="readonly", values=("CALL", "PUT")).grid(
            row=9, column=1, sticky="ew", pady=(8, 4)
        )
        ttk.Label(help_card, text="Expiracao IQ", style="Body.TLabel").grid(row=10, column=0, sticky="w", pady=(8, 4))
        self.expiration_combo = ttk.Combobox(help_card, textvariable=self.order_expiration_var, state="readonly", values=())
        self.expiration_combo.grid(row=10, column=1, sticky="ew", pady=(8, 4))
        self.expiration_combo.bind("<<ComboboxSelected>>", self._on_expiration_selected)
        ttk.Button(help_card, text="Atualizar expiracoes", command=self._refresh_expirations_in_background).grid(
            row=11, column=0, columnspan=2, sticky="ew", pady=(10, 0)
        )
        ttk.Label(help_card, textvariable=self.expiration_status_var, style="MetricLabel.TLabel").grid(
            row=12, column=0, columnspan=2, sticky="w", pady=(8, 0)
        )
        ttk.Button(help_card, text="Enviar ordem", command=self._place_order_in_background).grid(
            row=13, column=0, columnspan=2, sticky="ew", pady=(16, 0)
        )

        table_frame = ttk.Frame(root, style="Card.TFrame", padding=14)
        table_frame.grid(row=2, column=0, sticky="nsew")
        table_frame.columnconfigure(0, weight=1)
        table_frame.rowconfigure(0, weight=1)

        columns = ("symbol", "turbo", "binary", "best", "kind", "open", "operable")
        self.tree = ttk.Treeview(table_frame, columns=columns, show="headings")
        headings = {
            "symbol": "Ativo",
            "turbo": "Turbo %",
            "binary": "Binary %",
            "best": "Melhor %",
            "kind": "Melhor tipo",
            "open": "Aberto agora",
            "operable": "Operavel API",
        }
        widths = {
            "symbol": 220,
            "turbo": 140,
            "binary": 140,
            "best": 140,
            "kind": 160,
            "open": 180,
            "operable": 200,
        }
        for column in columns:
            self.tree.heading(column, text=headings[column])
            self.tree.column(column, width=widths[column], anchor="w", stretch=True)
        self.tree.grid(row=0, column=0, sticky="nsew")
        self.tree.bind("<<TreeviewSelect>>", self._on_select_asset)

        scrollbar = ttk.Scrollbar(table_frame, orient="vertical", command=self.tree.yview)
        scrollbar.grid(row=0, column=1, sticky="ns")
        self.tree.configure(yscrollcommand=scrollbar.set)

    def _scan_in_background(self) -> None:
        try:
            min_payout = float(self.min_payout_var.get().replace(",", "."))
        except ValueError:
            messagebox.showerror("IQ Payout Scanner", "Payout minimo invalido.")
            return

        self.status_var.set("Buscando payouts na IQ Option...")
        self._persist_config(show_message=False)

        def worker() -> None:
            try:
                rows = self.scanner.scan(min_payout, self.otc_var.get())
            except Exception as exc:
                self.after(0, lambda: messagebox.showerror("IQ Payout Scanner", str(exc)))
                self.after(0, lambda: self.status_var.set(f"Falha: {exc}"))
                return

            def apply() -> None:
                for item in self.tree.get_children():
                    self.tree.delete(item)
                for row in rows:
                    self.tree.insert(
                        "",
                        "end",
                        values=(
                            row["symbol"],
                            f"{row['turbo']:.2f}",
                            f"{row['binary']:.2f}",
                            f"{row['best']:.2f}",
                            row["best_kind"],
                            self._format_open_status(row),
                            row["operable_now"],
                        ),
                    )
                self.updated_var.set(f"Ultima leitura: {time.strftime('%Y-%m-%d %H:%M:%S')}")
                self.status_var.set(f"{len(rows)} ativo(s) abertos encontrados com payout >= {min_payout:.2f}%.")

            self.after(0, apply)

        threading.Thread(target=worker, daemon=True).start()

    def _on_select_asset(self, _event: Any) -> None:
        selection = self.tree.selection()
        if not selection:
            return
        values = self.tree.item(selection[0], "values")
        if not values:
            return
        self.selected_symbol_var.set(str(values[0]))
        self.selected_order_symbol_var.set(self.scanner.normalize_order_symbol(str(values[0])))
        self.selected_kind_var.set(str(values[4]))
        self.selected_operability_var.set(str(values[6]) if len(values) > 6 else "-")
        self.selected_execution_kind_var.set("-")
        self.selected_expiration_detail_var.set("-")
        self._refresh_expirations_in_background()

    def _on_expiration_selected(self, _event: Any) -> None:
        self._refresh_order_preview()

    def _place_order_in_background(self) -> None:
        symbol = self.selected_symbol_var.get().strip()
        if not symbol or symbol == "Nenhum ativo selecionado":
            messagebox.showerror("IQ Payout Scanner", "Selecione um ativo na grade.")
            return
        try:
            amount = float(self.order_amount_var.get().replace(",", "."))
        except ValueError:
            messagebox.showerror("IQ Payout Scanner", "Valor invalido.")
            return
        expiration = self._get_selected_expiration()
        if expiration is None:
            messagebox.showerror("IQ Payout Scanner", "Selecione uma expiracao valida da IQ.")
            return
        direction = self.order_direction_var.get().upper().strip()
        if direction not in {"CALL", "PUT"}:
            messagebox.showerror("IQ Payout Scanner", "Direcao invalida.")
            return
        expiration_minutes = int(expiration["duration_minutes"])
        expiration_timestamp = int(expiration["expiration_timestamp"])
        if amount <= 0 or expiration_minutes <= 0 or expiration_timestamp <= 0:
            messagebox.showerror("IQ Payout Scanner", "Valor e expiracao devem ser maiores que zero.")
            return

        self.status_var.set(f"Enviando ordem para {symbol}...")

        def worker() -> None:
            try:
                order_id, order_symbol = self.scanner.place_order(
                    symbol,
                    amount,
                    direction,
                    expiration_minutes,
                    expiration_timestamp,
                )
            except Exception as exc:
                self.after(0, lambda: messagebox.showerror("IQ Payout Scanner", str(exc)))
                self.after(0, lambda: self.status_var.set(f"Falha ao enviar ordem: {exc}"))
                return

            def apply() -> None:
                self.status_var.set(f"Ordem enviada: {order_symbol} {direction} valor={amount:.2f} id={order_id}")
                messagebox.showinfo("IQ Payout Scanner", f"Ordem enviada para {order_symbol}.\nID: {order_id}")

            self.after(0, apply)

        threading.Thread(target=worker, daemon=True).start()

    def _refresh_expirations_in_background(self) -> None:
        symbol = self.selected_symbol_var.get().strip()
        if not symbol or symbol == "Nenhum ativo selecionado":
            self.iq_clock_var.set("Hora IQ: -")
            self.expiration_status_var.set("Selecione um ativo para carregar as expiracoes da IQ.")
            self._apply_expiration_values([])
            return

        self.expiration_status_var.set("Carregando expiracoes da IQ...")

        def worker() -> None:
            try:
                options = self.scanner.get_expiration_options()
            except Exception as exc:
                self.after(0, lambda: self.expiration_status_var.set(f"Falha ao carregar expiracoes: {exc}"))
                return

            def apply() -> None:
                previous_selection = self.order_expiration_var.get().strip()
                labels: list[str] = []
                mapping: dict[str, dict[str, int]] = {}
                if options:
                    timestamp = int(options[0]["expiration_timestamp"]) - int(options[0]["remaining_seconds"])
                    self.iq_clock_var.set(f"Hora IQ: {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(timestamp))}")
                else:
                    self.iq_clock_var.set("Hora IQ: -")
                for item in options:
                    duration = int(item["duration_minutes"])
                    remaining_seconds = int(item["remaining_seconds"])
                    label = (
                        f"{item['time_label']} | {duration} min | "
                        f"restam {remaining_seconds // 60:02d}:{remaining_seconds % 60:02d}"
                    )
                    labels.append(label)
                    mapping[label] = {
                        "duration_minutes": duration,
                        "expiration_timestamp": int(item["expiration_timestamp"]),
                    }
                self.expiration_options_by_label = mapping
                self._apply_expiration_values(labels)
                if labels:
                    if previous_selection in mapping:
                        self.order_expiration_var.set(previous_selection)
                        self.expiration_status_var.set("Expiracoes sincronizadas com a IQ.")
                    else:
                        self.order_expiration_var.set("Selecione uma expiracao")
                        self.expiration_status_var.set("Selecione a expiracao desejada antes de enviar a ordem.")
                else:
                    self.expiration_status_var.set("A IQ nao retornou expiracoes no momento.")
                self._refresh_order_preview()

            self.after(0, apply)

        threading.Thread(target=worker, daemon=True).start()

    def _apply_expiration_values(self, values: list[str]) -> None:
        self.expiration_values = values
        self.expiration_combo["values"] = values
        if not values:
            self.order_expiration_var.set("Selecione uma expiracao")
            self.expiration_options_by_label = {}
            self.selected_execution_kind_var.set("-")
            self.selected_expiration_detail_var.set("-")

    def _get_selected_expiration(self) -> dict[str, int] | None:
        raw_value = self.order_expiration_var.get().strip()
        if not raw_value:
            return None
        mapped_value = self.expiration_options_by_label.get(raw_value)
        if mapped_value is not None:
            return mapped_value
        try:
            duration = int(raw_value)
        except ValueError:
            return None
        return {"duration_minutes": duration, "expiration_timestamp": 0}

    def _refresh_order_preview(self) -> None:
        raw_symbol = self.selected_symbol_var.get().strip()
        if not raw_symbol or raw_symbol == "Nenhum ativo selecionado":
            self.selected_order_symbol_var.set("-")
            self.selected_execution_kind_var.set("-")
            self.selected_expiration_detail_var.set("-")
            return
        self.selected_order_symbol_var.set(self.scanner.normalize_order_symbol(raw_symbol))
        expiration = self._get_selected_expiration()
        if expiration is None:
            self.selected_execution_kind_var.set("-")
            self.selected_expiration_detail_var.set("-")
            return
        duration = int(expiration["duration_minutes"])
        expiration_timestamp = int(expiration["expiration_timestamp"])
        self.selected_execution_kind_var.set(self.scanner._get_option_kind_for_duration(duration).upper())
        if expiration_timestamp > 0:
            exp_text = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(expiration_timestamp))
            self.selected_expiration_detail_var.set(f"{exp_text} | {duration} min")
        else:
            self.selected_expiration_detail_var.set(f"{duration} min")

    def _persist_config(self, show_message: bool = False) -> None:
        try:
            min_payout = float(self.min_payout_var.get().replace(",", "."))
        except ValueError:
            if show_message:
                messagebox.showerror("IQ Payout Scanner", "Payout minimo invalido.")
            return

        self.config_model.balance_mode = self.balance_mode_var.get().upper().strip() or "PRACTICE"
        self.config_model.min_payout_percent = min_payout
        self.config_model.use_otc_symbols = bool(self.otc_var.get())
        save_config(CONFIG_PATH, self.config_model)
        self.scanner.config = self.config_model
        if self.scanner.client is not None:
            try:
                self.scanner.client.change_balance(self.config_model.balance_mode)
            except Exception:
                self.scanner.client = None
        if show_message:
            messagebox.showinfo("IQ Payout Scanner", "Config salva.")

    def _format_open_status(self, row: dict[str, Any]) -> str:
        parts: list[str] = []
        if row.get("turbo_open"):
            parts.append("TURBO")
        if row.get("binary_open"):
            parts.append("BINARY")
        return " / ".join(parts) if parts else "-"

def main() -> None:
    config = load_config(CONFIG_PATH)
    if not config.email or not config.password:
        raise SystemExit("Preencha email e password em config.json.")

    app = App(IQPayoutScanner(config), config)
    app.mainloop()


if __name__ == "__main__":
    main()
