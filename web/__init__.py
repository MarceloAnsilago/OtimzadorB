from flask import Flask
from flask_socketio import SocketIO

socketio = SocketIO()


def create_app() -> Flask:
    from core.config import settings
    from web.routes.auth import auth_bp
    from web.routes.market import market_bp

    app = Flask(
        __name__,
        template_folder="templates",
        static_folder="static",
    )
    app.config["SECRET_KEY"] = settings.secret_key

    socketio.init_app(app, async_mode=settings.socketio_async_mode, cors_allowed_origins="*")
    app.register_blueprint(auth_bp)
    app.register_blueprint(market_bp)
    return app
