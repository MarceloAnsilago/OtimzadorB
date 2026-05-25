from __future__ import annotations

import threading
import time

import requests
from loguru import logger

from core.config import settings
from core.database import init_database
from core.logging_config import configure_logging
from web import create_app, socketio

_server_started = False


def _run_server() -> None:
    app = create_app()
    socketio.run(
        app,
        host=settings.host,
        port=settings.port,
        debug=settings.debug,
        use_reloader=False,
        allow_unsafe_werkzeug=True,
    )


def _wait_until_ready(url: str, timeout: float = 15.0) -> None:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            response = requests.get(url, timeout=1.5)
            if response.ok:
                return
        except requests.RequestException:
            time.sleep(0.2)
    raise RuntimeError(f"Flask server did not start in time: {url}")


def launch_server() -> str:
    global _server_started

    server_url = f"http://{settings.host}:{settings.port}/"
    if _server_started:
        return server_url

    configure_logging()
    init_database()
    logger.info("Starting Flask server at {}", server_url)

    server_thread = threading.Thread(target=_run_server, name="binrobo-flask", daemon=True)
    server_thread.start()
    _wait_until_ready(server_url)
    _server_started = True
    logger.info("Flask server ready")
    return server_url
