from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from difflib import get_close_matches
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
        self._asset_catalog: dict[str, dict[str, Any]] = {}
        self._asset_catalog_loaded_at: float = 0.0

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
            payload["asset_catalog_ready"] = self._initialize_asset_catalog()
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

            catalog = self._refresh_asset_catalog(force=False)
            assets = sorted(catalog.values(), key=lambda item: (item["category"], item["symbol"]))
            return assets[:limit] if limit else assets

    def download_candles(self, asset: str, interval_seconds: int, count: int) -> dict[str, Any]:
        with self._lock:
            if self._api is None or not self._safe_check_connect():
                raise RuntimeError("IQ Option nao conectada.")

            catalog = self._refresh_asset_catalog(force=False)
            resolved_symbol, asset_info = self._resolve_asset_symbol(asset, catalog)
            logger.info(
                "Downloading candles | asset={} | interval_seconds={} | count={}",
                resolved_symbol,
                interval_seconds,
                count,
            )
            candles = self._download_candles_batched(resolved_symbol, interval_seconds, count)

        if not candles:
            raise RuntimeError("Nenhum candle foi retornado para o ativo solicitado.")

        candles.sort(key=lambda row: row["from"])
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

        safe_asset = resolved_symbol.replace("/", "_").replace("\\", "_")
        generated_at = datetime.now(tz=timezone.utc).strftime("%Y%m%d_%H%M%S")
        file_path = output_dir / f"{safe_asset}_{interval_seconds}s_{count}_{generated_at}.csv"
        dataframe.to_csv(file_path, index=False)

        return {
            "asset": resolved_symbol,
            "category": asset_info["category"],
            "interval_seconds": interval_seconds,
            "count": count,
            "rows": len(normalized_rows),
            "file_path": str(file_path),
            "preview": normalized_rows[-10:],
            "started_at": normalized_rows[0]["timestamp_utc"],
            "ended_at": normalized_rows[-1]["timestamp_utc"],
        }

    def _download_candles_batched(self, asset: str, interval_seconds: int, count: int) -> list[dict[str, Any]]:
        if self._api is None:
            raise RuntimeError("IQ Option nao conectada.")

        remaining = count
        end_time = time.time()
        all_candles: list[dict[str, Any]] = []

        while remaining > 0:
            batch_size = min(remaining, 1000)
            batch = self._api.get_candles(asset, interval_seconds, batch_size, end_time)
            if not batch:
                break

            all_candles.extend(batch)
            oldest_timestamp = min(item["from"] for item in batch)
            end_time = oldest_timestamp - 1
            remaining -= len(batch)

            if len(batch) < batch_size:
                break

        unique_candles = {item["from"]: item for item in all_candles}
        return list(unique_candles.values())

    def _refresh_asset_catalog(self, force: bool) -> dict[str, dict[str, Any]]:
        if self._api is None:
            return {}

        is_fresh = (time.time() - self._asset_catalog_loaded_at) < 120
        if self._asset_catalog and is_fresh and not force:
            return self._asset_catalog

        logger.info("Refreshing IQ Option asset catalog")
        self._api.update_ACTIVES_OPCODE()
        active_codes = self._api.get_all_ACTIVES_OPCODE()

        try:
            open_time = self._api.get_all_open_time()
        except Exception:
            logger.exception("Failed to fetch open_time from IQ Option; using opcode fallback catalog")
            fallback_catalog = self._build_fallback_catalog(active_codes)
            self._asset_catalog = fallback_catalog
            self._asset_catalog_loaded_at = time.time()
            logger.info("Fallback asset catalog ready | total_assets={}", len(fallback_catalog))
            return fallback_catalog

        allowed_sections = ("forex", "crypto", "digital", "binary", "turbo", "cfd")
        catalog: dict[str, dict[str, Any]] = {}
        for section in allowed_sections:
            section_data = open_time.get(section, {})
            for symbol, info in section_data.items():
                normalized_symbol = symbol.strip().upper()
                if not info.get("open"):
                    continue
                if normalized_symbol not in active_codes:
                    continue
                catalog[normalized_symbol] = {
                    "symbol": normalized_symbol,
                    "category": section,
                    "open": True,
                }

        self._asset_catalog = catalog
        self._asset_catalog_loaded_at = time.time()
        logger.info("Asset catalog ready | total_open_assets={}", len(catalog))
        return catalog

    def _initialize_asset_catalog(self) -> bool:
        try:
            self._refresh_asset_catalog(force=True)
            return True
        except Exception:
            logger.exception("Unexpected failure during asset catalog initialization")
            self._asset_catalog = {}
            self._asset_catalog_loaded_at = 0.0
            return False

    def _build_fallback_catalog(self, active_codes: dict[str, Any]) -> dict[str, dict[str, Any]]:
        catalog: dict[str, dict[str, Any]] = {}
        for symbol in active_codes.keys():
            normalized_symbol = str(symbol).strip().upper()
            if not normalized_symbol:
                continue
            catalog[normalized_symbol] = {
                "symbol": normalized_symbol,
                "category": self._guess_asset_category(normalized_symbol),
                "open": True,
            }
        return catalog

    def _guess_asset_category(self, symbol: str) -> str:
        if "-OTC" in symbol:
            return "otc"
        if any(token in symbol for token in ("BTC", "ETH", "LTC", "XRP", "DOGE")):
            return "crypto"
        if len(symbol) == 6 and symbol.isalpha():
            return "forex"
        return "market"

    def _resolve_asset_symbol(
        self,
        requested_asset: str,
        catalog: dict[str, dict[str, Any]],
    ) -> tuple[str, dict[str, Any]]:
        normalized_asset = requested_asset.strip().upper()
        if normalized_asset in catalog:
            return normalized_asset, catalog[normalized_asset]

        suggestion = get_close_matches(normalized_asset, catalog.keys(), n=1, cutoff=0.7)
        if suggestion:
            raise RuntimeError(f"Ativo invalido: {normalized_asset}. Talvez voce quis dizer {suggestion[0]}.")

        raise RuntimeError(f"Ativo invalido ou fechado: {normalized_asset}.")

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
