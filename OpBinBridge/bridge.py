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
    processed_folder: str
    failed_folder: str
    receipts_folder: str
    allowed_symbols: list[str]
    dry_run: bool
    open_browser_on_start: bool
    browser_url: str

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
    def failed_path(self) -> Path:
        return self.bridge_root_path / self.failed_folder

    @property
    def receipts_path(self) -> Path:
        return self.bridge_root_path / self.receipts_folder


class IQOptionBridge:
    def __init__(self, config: BridgeConfig) -> None:
        self.config = config
        self.client: Any = None
        self.browser_opened = False

    def ensure_connection(self) -> None:
        if self.config.dry_run:
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
        for signal_file in sorted(self.config.inbox_path.glob("*.json")):
            try:
                payload = json.loads(signal_file.read_text(encoding="utf-8"))
                self.process_signal_file(signal_file, payload)
            except Exception as exc:
                logging.exception("Falha ao processar %s", signal_file.name)
                if signal_file.exists():
                    self.move_with_receipt(signal_file, self.config.failed_path, {"status": "error", "message": str(exc)})

    def process_signal_file(self, signal_file: Path, payload: dict[str, Any]) -> None:
        direction = str(payload.get("direction", "")).upper()
        symbol = str(payload.get("symbol", "")).upper()
        if direction not in {"CALL", "PUT"}:
            raise ValueError(f"Sinal invalido ou sem direcao executavel: {direction!r}")
        if self.config.allowed_symbols and symbol not in self.config.allowed_symbols:
            raise ValueError(f"Ativo nao permitido na bridge: {symbol}")

        amount = float(payload.get("amount_hint") or 0.0)
        if amount <= 0:
            amount = self.config.default_amount
        if amount <= 0:
            raise ValueError("Nenhum valor de entrada definido no sinal ou no config.")

        expiration = int(payload.get("expiration_minutes") or self.config.expiration_minutes_default)
        if expiration <= 0:
            raise ValueError("expiration_minutes precisa ser maior que zero.")

        receipt: dict[str, Any] = {
            "status": "dry_run" if self.config.dry_run else "sent",
            "symbol": symbol,
            "direction": direction,
            "amount": amount,
            "expiration_minutes": expiration,
            "signal_file": signal_file.name,
            "processed_at": int(time.time()),
        }

        if not self.config.dry_run:
            self.ensure_connection()
            ok, order_id = self.client.buy(amount, symbol, direction.lower(), expiration)
            if not ok:
                raise RuntimeError(f"IQ Option recusou a ordem para {symbol}.")
            receipt["order_id"] = order_id

        logging.info(
            "Sinal %s processado: %s %s amount=%s exp=%s",
            signal_file.name,
            symbol,
            direction,
            amount,
            expiration,
        )
        self.move_with_receipt(signal_file, self.config.processed_path, receipt)

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
    config.processed_path.mkdir(parents=True, exist_ok=True)
    config.failed_path.mkdir(parents=True, exist_ok=True)
    config.receipts_path.mkdir(parents=True, exist_ok=True)


def load_config(config_path: Path) -> BridgeConfig:
    if not config_path.exists():
        raise FileNotFoundError(
            f"Config ausente em {config_path}. Copie config.example.json para config.json e preencha suas credenciais."
        )

    raw = json.loads(config_path.read_text(encoding="utf-8"))
    common_files_dir = Path(raw.get("mt5_common_files_dir") or DEFAULT_COMMON_FILES_DIR)
    return BridgeConfig(
        email=str(raw.get("email", "")),
        password=str(raw.get("password", "")),
        balance_mode=str(raw.get("balance_mode", "PRACTICE")),
        default_amount=float(raw.get("default_amount", 0.0)),
        poll_interval_seconds=float(raw.get("poll_interval_seconds", 1.0)),
        expiration_minutes_default=int(raw.get("expiration_minutes_default", 1)),
        mt5_common_files_dir=common_files_dir,
        bridge_root_folder=str(raw.get("bridge_root_folder", "OpBinBridge")),
        signals_in_folder=str(raw.get("signals_in_folder", "signals_in")),
        processed_folder=str(raw.get("processed_folder", "signals_processed")),
        failed_folder=str(raw.get("failed_folder", "signals_failed")),
        receipts_folder=str(raw.get("receipts_folder", "receipts")),
        allowed_symbols=[str(item).upper() for item in raw.get("allowed_symbols", [])],
        dry_run=bool(raw.get("dry_run", True)),
        open_browser_on_start=bool(raw.get("open_browser_on_start", False)),
        browser_url=str(raw.get("browser_url", "https://iqoption.com/")),
    )


def main() -> int:
    setup_logging()
    config = load_config(CONFIG_PATH)
    bridge = IQOptionBridge(config)
    bridge.run()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
