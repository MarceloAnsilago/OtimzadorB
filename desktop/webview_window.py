from __future__ import annotations

import webview

from core.config import settings


def start_desktop_app(server_url: str) -> None:
    window = webview.create_window(
        title=settings.app_title,
        url=server_url,
        width=settings.window_width,
        height=settings.window_height,
        min_size=(1200, 760),
        background_color="#0b1020",
        text_select=False,
    )
    webview.start(debug=settings.webview_debug)
