from __future__ import annotations

import os
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()


def _as_bool(value: str, default: bool = False) -> bool:
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


@dataclass(slots=True)
class Settings:
    app_title: str = os.getenv("APP_TITLE", "BinRobo")
    host: str = os.getenv("APP_HOST", "127.0.0.1")
    port: int = int(os.getenv("APP_PORT", "5000"))
    debug: bool = _as_bool(os.getenv("APP_DEBUG"), False)
    webview_debug: bool = _as_bool(os.getenv("WEBVIEW_DEBUG"), False)
    window_width: int = int(os.getenv("WINDOW_WIDTH", "1400"))
    window_height: int = int(os.getenv("WINDOW_HEIGHT", "900"))
    secret_key: str = os.getenv("FLASK_SECRET_KEY", "change-this-secret-key")
    database_url: str = os.getenv("DATABASE_URL", "sqlite:///data/binrobo.db")
    socketio_async_mode: str = os.getenv("SOCKETIO_ASYNC_MODE", "threading")
    iq_option_email: str = os.getenv("IQ_OPTION_EMAIL", "")
    iq_option_password: str = os.getenv("IQ_OPTION_PASSWORD", "")


settings = Settings()
