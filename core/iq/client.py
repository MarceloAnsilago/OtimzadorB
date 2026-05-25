from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from threading import Lock
import time
from typing import Any

import pandas as pd
from iqoptionapi.stable_api import IQ_Option
from loguru import logger


@dataclass(slots=True)
class IQConnectionResult:
    ok: bool
    message: str
    payload: dict[str, Any]


class IQOptionClient:
    def __init__(self) -> None:
        self._lock = Lock()
        self._api: IQ_Option | None = None
        self._last_email: str | None = None

    def connect(self, email: str, password: str) -> IQConnectionResult:
        if not email or not password:
            return IQConnectionResult(
                ok=False,
                message="Informe e-mail e senha para conectar.",
                payload={},
            )

        with self._lock:
            logger.info("Attempting IQ Option connection | email={}", email)
            api = IQ_Option(email, password)

            try:
                connected, reason = api.connect()
            except Exception as exc:
                logger.exception("Unexpected exception during IQ Option connect")
                return IQConnectionResult(
                    ok=False,
                    message="Falha inesperada ao conectar na IQ Option.",
                    payload={"reason": str(exc)},
                )

            if not connected:
                logger.warning("IQ Option refused connection | email={} | reason={}", email, reason)
                return IQConnectionResult(
                    ok=False,
                    message="Nao foi possivel autenticar na IQ Option.",
                    payload={"reason": reason or "unknown"},
                )

            self._api = api
            self._last_email = email
            payload = self._collect_session_snapshot()
            logger.info(
                "IQ Option connection established | email={} | balance_type={} | currency={}",
                email,
                payload.get("balance_type"),
                payload.get("currency"),
            )
            return IQConnectionResult(
                ok=True,
                message="Conexao com a IQ Option realizada com sucesso.",
                payload=payload,
            )

    def disconnect(self) -> None:
        with self._lock:
            if self._api is None:
                return
            try:
                self._api.api.close()
            except Exception:
                logger.exception("Unexpected exception during IQ Option disconnect")
            finally:
                self._api = None

    def get_status(self) -> dict[str, Any]:
        with self._lock:
            if self._api is None:
                return {"connected": False}

            connected = self._safe_check_connect()
            snapshot = self._collect_session_snapshot() if connected else {}
            return {"connected": connected, "email": self._last_email, **snapshot}

    def is_connected(self) -> bool:
        with self._lock:
            return self._safe_check_connect()

    def list_open_assets(self, limit: int = 60) -> list[dict[str, Any]]:
        with self._lock:
            if self._api is None or not self._safe_check_connect():
                raise RuntimeError("IQ Option nao conectada.")

            open_time = self._api.get_all_open_time()
            allowed_sections = ("forex", "crypto", "digital", "binary", "turbo", "cfd")
            assets: list[dict[str, Any]] = []

            for section in allowed_sections:
                section_data = open_time.get(section, {})
                for symbol, info in section_data.items():
                    if info.get("open"):
                        assets.append({"symbol": symbol, "category": section, "open": True})

            assets.sort(key=lambda item: (item["category"], item["symbol"]))
            return assets[:limit]

    def download_candles(self, asset: str, interval_seconds: int, count: int) -> dict[str, Any]:
        with self._lock:
            if self._api is None or not self._safe_check_connect():
                raise RuntimeError("IQ Option nao conectada.")

            logger.info(
                "Downloading candles | asset={} | interval_seconds={} | count={}",
                asset,
                interval_seconds,
                count,
            )
            candles = self._api.get_candles(asset, interval_seconds, count, time.time())

        if not candles:
            raise RuntimeError("Nenhum candle foi retornado para o ativo solicitado.")

        normalized_rows = []
        for candle in candles:
            timestamp = datetime.fromtimestamp(candle["from"], tz=timezone.utc)
            normalized_rows.append(
                {
                    "timestamp_utc": timestamp.isoformat(),
                    "open": candle.get("open"),
                    "close": candle.get("close"),
                    "min": candle.get("min"),
                    "max": candle.get("max"),
                    "volume": candle.get("volume"),
                }
            )

        dataframe = pd.DataFrame(normalized_rows)
        output_dir = Path("data") / "market"
        output_dir.mkdir(parents=True, exist_ok=True)

        safe_asset = asset.replace("/", "_").replace("\\", "_")
        generated_at = datetime.now(tz=timezone.utc).strftime("%Y%m%d_%H%M%S")
        file_path = output_dir / f"{safe_asset}_{interval_seconds}s_{count}_{generated_at}.csv"
        dataframe.to_csv(file_path, index=False)

        return {
            "asset": asset,
            "interval_seconds": interval_seconds,
            "count": count,
            "rows": len(normalized_rows),
            "file_path": str(file_path),
            "preview": normalized_rows[-10:],
            "started_at": normalized_rows[0]["timestamp_utc"],
            "ended_at": normalized_rows[-1]["timestamp_utc"],
        }

    def _safe_check_connect(self) -> bool:
        if self._api is None:
            return False

        try:
            return bool(self._api.check_connect())
        except Exception:
            logger.exception("Unexpected exception while checking IQ Option connection")
            return False

    def _collect_session_snapshot(self) -> dict[str, Any]:
        if self._api is None:
            return {}

        snapshot: dict[str, Any] = {"connected": self._safe_check_connect()}

        try:
            profile = self._api.get_profile_ansyc()
            if profile:
                snapshot["name"] = profile.get("name")
                snapshot["currency"] = profile.get("currency_char")
        except Exception:
            logger.exception("Failed to fetch IQ Option profile snapshot")

        try:
            snapshot["balance_type"] = self._api.get_balance_mode()
        except Exception:
            logger.exception("Failed to fetch IQ Option balance mode")

        try:
            balance = self._api.get_balance()
            if balance is not None:
                snapshot["balance"] = balance
        except Exception:
            logger.exception("Failed to fetch IQ Option balance")

        return snapshot


iq_client = IQOptionClient()
