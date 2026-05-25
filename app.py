from desktop.webview_window import start_desktop_app
from web.server import launch_server


def main() -> None:
    server_url = launch_server()
    start_desktop_app(server_url)


if __name__ == "__main__":
    main()
