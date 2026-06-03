from __future__ import annotations

import json
import os
import shutil
import socket
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import iqoptionapi.constants as OP_code

try:
    from ctk_app import CONFIG_PATH, IQPayoutScanner, load_config
except ModuleNotFoundError:
    from OpBinBridge.ctk_app import CONFIG_PATH, IQPayoutScanner, load_config


ROOT_DIR = Path(__file__).resolve().parent


class IgnoredSignalError(RuntimeError):
    pass


@dataclass
class BridgeRuntimeConfig:
    mt5_common_files_dir: Path
    bridge_root_folder: str
    signals_in_folder: str
    status_folder: str
    processed_folder: str
    failed_folder: str
    ignored_folder: str
    receipts_folder: str
    poll_interval_seconds: float
    default_amount: float
    min_payout_percent: float
    use_otc_symbols: bool
    dry_run: bool
    allowed_symbols: list[str]
    iq_symbol_map: dict[str, str]

    @classmethod
    def from_file(cls, path: Path) -> BridgeRuntimeConfig:
        raw = json.loads(path.read_text(encoding="utf-8"))
        allowed_symbols = [str(item).upper().strip() for item in list(raw.get("allowed_symbols", [])) if str(item).strip()]
        iq_symbol_map = {
            str(key).upper().strip(): str(value).upper().strip()
            for key, value in dict(raw.get("iq_symbol_map", {})).items()
            if str(key).strip() and str(value).strip()
        }
        return cls(
            mt5_common_files_dir=Path(str(raw.get("mt5_common_files_dir", "")).strip()),
            bridge_root_folder=str(raw.get("bridge_root_folder", "OpBinBridge")).strip() or "OpBinBridge",
            signals_in_folder=str(raw.get("signals_in_folder", "signals_in")).strip() or "signals_in",
            status_folder=str(raw.get("status_folder", "status")).strip() or "status",
            processed_folder=str(raw.get("processed_folder", "signals_processed")).strip() or "signals_processed",
            failed_folder=str(raw.get("failed_folder", "signals_failed")).strip() or "signals_failed",
            ignored_folder=str(raw.get("ignored_folder", "signals_ignored")).strip() or "signals_ignored",
            receipts_folder=str(raw.get("receipts_folder", "receipts")).strip() or "receipts",
            poll_interval_seconds=float(raw.get("poll_interval_seconds", 1.0)),
            default_amount=float(raw.get("default_amount", 2.0)),
            min_payout_percent=float(raw.get("min_payout_percent", 0.0)),
            use_otc_symbols=bool(raw.get("use_otc_symbols", False)),
            dry_run=bool(raw.get("dry_run", False)),
            allowed_symbols=allowed_symbols,
            iq_symbol_map=iq_symbol_map,
        )

    @property
    def bridge_root_path(self) -> Path:
        return self.mt5_common_files_dir / self.bridge_root_folder

    @property
    def inbox_path(self) -> Path:
        return self.bridge_root_path / self.signals_in_folder

    @property
    def status_path(self) -> Path:
        return self.bridge_root_path / self.status_folder

    @property
    def processed_path(self) -> Path:
        return self.bridge_root_path / self.processed_folder

    @property
    def failed_path(self) -> Path:
        return self.bridge_root_path / self.failed_folder

    @property
    def ignored_path(self) -> Path:
        return self.bridge_root_path / self.ignored_folder

    @property
    def receipts_path(self) -> Path:
        return self.bridge_root_path / self.receipts_folder


class BridgeWorker:
    def __init__(self, config_path: Path) -> None:
        self.config_path = config_path
        self.app_config = load_config(config_path)
        self.runtime_config = BridgeRuntimeConfig.from_file(config_path)
        self.scanner = IQPayoutScanner(self.app_config)
        self.processed_count = 0
        self.failed_count = 0
        self.ignored_count = 0
        self.last_error = ""
        self.last_signal_file = ""
        self._ensure_directories()

    def run_forever(self) -> None:
        self._write_status(state="starting")
        while True:
            try:
                self._process_pending_signals()
                self._write_status(state="idle")
            except KeyboardInterrupt:
                self._write_status(state="stopped")
                raise
            except Exception as exc:
                self.last_error = str(exc)
                self._write_status(state="error")
            time.sleep(max(0.2, self.runtime_config.poll_interval_seconds))

    def _ensure_directories(self) -> None:
        for folder in (
            self.runtime_config.bridge_root_path,
            self.runtime_config.inbox_path,
            self.runtime_config.status_path,
            self.runtime_config.processed_path,
            self.runtime_config.failed_path,
            self.runtime_config.ignored_path,
            self.runtime_config.receipts_path,
        ):
            folder.mkdir(parents=True, exist_ok=True)

    def _process_pending_signals(self) -> None:
        signal_files = sorted(self.runtime_config.inbox_path.glob("signal_*.json"), key=lambda item: item.stat().st_mtime)
        for signal_file in signal_files:
            if not signal_file.is_file():
                continue
            if self._is_file_too_fresh(signal_file):
                continue
            self.last_signal_file = signal_file.name
            try:
                self._process_one_signal(signal_file)
                self.processed_count += 1
            except IgnoredSignalError as exc:
                self.ignored_count += 1
                self.last_error = str(exc)
                self._handle_ignored_signal(signal_file, exc)
            except Exception as exc:
                self.failed_count += 1
                self.last_error = str(exc)
                self._handle_failed_signal(signal_file, exc)

    def _process_one_signal(self, signal_file: Path) -> None:
        payload = json.loads(signal_file.read_text(encoding="utf-8-sig"))
        self._validate_signal_payload(payload)
        self._write_status(state="processing", active_signal=signal_file.name)

        direction = str(payload.get("direction", "")).upper().strip()
        expiration_minutes = int(payload.get("expiration_minutes", 1))
        amount = self._resolve_amount(payload)
        requested_symbol = str(payload.get("symbol", "")).upper().strip()
        order_symbol, option_kind, payout_percent = self._resolve_order_symbol(requested_symbol, expiration_minutes)

        if self.runtime_config.dry_run:
            receipt_payload = self._build_receipt_payload(
                payload,
                signal_file,
                order_symbol,
                option_kind,
                expiration_minutes,
                amount,
                payout_percent,
                order_id="dry-run",
                status="dry_run",
                message="Sinal validado sem envio de ordem porque dry_run=true.",
            )
            self._write_receipt(signal_file, receipt_payload)
            self._move_signal_file(signal_file, self.runtime_config.processed_path)
            return

        expiration_timestamp = self._resolve_expiration_timestamp(expiration_minutes)
        order_id, final_order_symbol = self.scanner.place_order(
            order_symbol,
            amount,
            direction,
            expiration_minutes,
            expiration_timestamp,
        )
        receipt_payload = self._build_receipt_payload(
            payload,
            signal_file,
            final_order_symbol,
            option_kind,
            expiration_minutes,
            amount,
            payout_percent,
            order_id=str(order_id),
            status="sent",
            message="Ordem enviada com sucesso.",
            expiration_timestamp=expiration_timestamp,
        )
        self._write_receipt(signal_file, receipt_payload)
        self._move_signal_file(signal_file, self.runtime_config.processed_path)

    def _validate_signal_payload(self, payload: dict[str, Any]) -> None:
        symbol = str(payload.get("symbol", "")).upper().strip()
        direction = str(payload.get("direction", "")).upper().strip()
        expiration_minutes = int(payload.get("expiration_minutes", 0) or 0)
        if not symbol:
            raise RuntimeError("Sinal sem symbol.")
        if direction not in {"CALL", "PUT"}:
            raise RuntimeError(f"Direction invalida no sinal: {direction!r}.")
        if expiration_minutes <= 0:
            raise RuntimeError(f"Expiration_minutes invalido no sinal: {expiration_minutes!r}.")
        if self.runtime_config.allowed_symbols and symbol not in self.runtime_config.allowed_symbols:
            raise IgnoredSignalError(f"Symbol {symbol} nao esta na allowlist da bridge.")

    def _resolve_amount(self, payload: dict[str, Any]) -> float:
        raw_amount = payload.get("amount_hint", self.runtime_config.default_amount)
        amount = float(raw_amount)
        if amount <= 0:
            return float(self.runtime_config.default_amount)
        return amount

    def _resolve_order_symbol(self, requested_symbol: str, expiration_minutes: int) -> tuple[str, str, float]:
        self.scanner.connect()
        option_kind = self.scanner._get_option_kind_for_duration(expiration_minutes)
        assert self.scanner.client is not None
        all_profit = dict(self.scanner.client.get_all_profit() or {})
        turbo_open_map, binary_open_map = self.scanner._get_binary_open_maps()
        open_map = turbo_open_map if option_kind == "turbo" else binary_open_map

        mapped_symbol = self.runtime_config.iq_symbol_map.get(requested_symbol, requested_symbol).upper().strip()
        candidates = self._build_symbol_candidates(mapped_symbol)
        preferred_order: list[str] = []
        if self.runtime_config.use_otc_symbols:
            preferred_order.extend(candidates["otc"])
            preferred_order.extend(candidates["regular"])
        else:
            preferred_order.extend(candidates["regular"])
            preferred_order.extend(candidates["otc"])

        best_any_open: tuple[str, float] | None = None
        for candidate in preferred_order:
            normalized_candidate = candidate.upper().strip()
            if normalized_candidate not in OP_code.ACTIVES:
                continue
            payout_percent = self.scanner._to_percent((all_profit.get(normalized_candidate) or {}).get(option_kind))
            info = self.scanner._get_open_info(normalized_candidate, open_map)
            is_open = bool(info.get("open"))
            if is_open and payout_percent >= self.runtime_config.min_payout_percent:
                return normalized_candidate, option_kind, payout_percent
            if is_open and best_any_open is None:
                best_any_open = (normalized_candidate, payout_percent)

        if best_any_open is not None:
            symbol_name, payout_percent = best_any_open
            raise IgnoredSignalError(
                f"{symbol_name} esta aberto em {option_kind.upper()}, mas payout {payout_percent:.2f}% "
                f"esta abaixo do minimo configurado ({self.runtime_config.min_payout_percent:.2f}%)."
            )

        raise IgnoredSignalError(
            f"Nenhum simbolo operavel encontrado para {requested_symbol} em {option_kind.upper()}. "
            "Verifique mapeamento, OTC e disponibilidade na IQ."
        )

    def _build_symbol_candidates(self, symbol: str) -> dict[str, list[str]]:
        normalized = symbol.upper().strip()
        is_otc = normalized.endswith("-OTC") or normalized.endswith("-OTC-OP")
        base = normalized
        if base.endswith("-OTC-OP"):
            base = base[:-3]
        if base.endswith("-OP") and not base.endswith("-OTC-OP"):
            base = base[:-3]

        regular = self._dedupe_symbols([base, f"{base}-OP"])
        otc_base = base if base.endswith("-OTC") else f"{base}-OTC"
        otc = self._dedupe_symbols([otc_base, f"{otc_base}-OP"])
        if is_otc:
            return {"regular": [], "otc": otc}
        return {"regular": regular, "otc": otc}

    def _resolve_expiration_timestamp(self, expiration_minutes: int) -> int:
        options = self.scanner.get_expiration_options()
        for item in options:
            if int(item["duration_minutes"]) == int(expiration_minutes):
                return int(item["expiration_timestamp"])
        raise RuntimeError(f"A IQ nao retornou expiracao valida para {expiration_minutes} minuto(s).")

    def _build_receipt_payload(
        self,
        signal_payload: dict[str, Any],
        signal_file: Path,
        order_symbol: str,
        option_kind: str,
        expiration_minutes: int,
        amount: float,
        payout_percent: float,
        order_id: str,
        status: str,
        message: str,
        expiration_timestamp: int = 0,
    ) -> dict[str, Any]:
        signal_time = int(signal_payload.get("signal_time", 0) or 0)
        return {
            "status": status,
            "message": message,
            "source_file": signal_file.name,
            "signal_id": self._signal_id_from_file(signal_file),
            "received_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "signal": signal_payload,
            "execution": {
                "symbol_requested": str(signal_payload.get("symbol", "")).upper().strip(),
                "order_symbol": order_symbol,
                "direction": str(signal_payload.get("direction", "")).upper().strip(),
                "option_kind": option_kind.upper(),
                "expiration_minutes": expiration_minutes,
                "expiration_timestamp": expiration_timestamp,
                "expiration_text": time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(expiration_timestamp))
                if expiration_timestamp > 0
                else "",
                "amount": amount,
                "payout_percent": payout_percent,
                "order_id": order_id,
            },
            "bridge": {
                "hostname": socket.gethostname(),
                "pid": os.getpid(),
                "balance_mode": self.app_config.balance_mode,
                "signal_time": signal_time,
            },
        }

    def _write_receipt(self, signal_file: Path, payload: dict[str, Any]) -> None:
        receipt_name = f"receipt_{self._signal_id_from_file(signal_file)}.json"
        self._write_json_atomic(self.runtime_config.receipts_path / receipt_name, payload)

    def _handle_failed_signal(self, signal_file: Path, exc: Exception) -> None:
        payload = {
            "status": "failed",
            "message": str(exc),
            "source_file": signal_file.name,
            "failed_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "bridge": {
                "hostname": socket.gethostname(),
                "pid": os.getpid(),
            },
        }
        self._write_receipt(signal_file, payload)
        self._move_signal_file(signal_file, self.runtime_config.failed_path)

    def _handle_ignored_signal(self, signal_file: Path, exc: Exception) -> None:
        payload = {
            "status": "ignored",
            "message": str(exc),
            "source_file": signal_file.name,
            "ignored_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "bridge": {
                "hostname": socket.gethostname(),
                "pid": os.getpid(),
            },
        }
        self._write_receipt(signal_file, payload)
        self._move_signal_file(signal_file, self.runtime_config.ignored_path)

    def _move_signal_file(self, signal_file: Path, target_folder: Path) -> None:
        target_folder.mkdir(parents=True, exist_ok=True)
        destination = target_folder / signal_file.name
        if destination.exists():
            destination = target_folder / f"{signal_file.stem}_{int(time.time())}{signal_file.suffix}"
        shutil.move(str(signal_file), str(destination))

    def _write_status(self, state: str, active_signal: str = "") -> None:
        payload = {
            "state": state,
            "active_signal": active_signal,
            "last_signal_file": self.last_signal_file,
            "last_error": self.last_error,
            "processed_count": self.processed_count,
            "failed_count": self.failed_count,
            "ignored_count": self.ignored_count,
            "dry_run": self.runtime_config.dry_run,
            "balance_mode": self.app_config.balance_mode,
            "heartbeat": time.strftime("%Y-%m-%d %H:%M:%S"),
            "hostname": socket.gethostname(),
            "pid": os.getpid(),
        }
        self._write_json_atomic(self.runtime_config.status_path / "bridge_status.json", payload)

    def _write_json_atomic(self, path: Path, payload: dict[str, Any]) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        temp_path = path.with_suffix(path.suffix + ".tmp")
        temp_path.write_text(json.dumps(payload, indent=2, ensure_ascii=True), encoding="utf-8")
        temp_path.replace(path)

    def _is_file_too_fresh(self, path: Path) -> bool:
        try:
            age_seconds = time.time() - path.stat().st_mtime
        except FileNotFoundError:
            return True
        return age_seconds < 0.5

    def _signal_id_from_file(self, signal_file: Path) -> str:
        return signal_file.stem.removeprefix("signal_")

    def _dedupe_symbols(self, symbols: list[str]) -> list[str]:
        unique: list[str] = []
        for item in symbols:
            normalized = item.upper().strip()
            if normalized and normalized not in unique:
                unique.append(normalized)
        return unique


def main() -> None:
    worker = BridgeWorker(CONFIG_PATH)
    worker.run_forever()


if __name__ == "__main__":
    main()
