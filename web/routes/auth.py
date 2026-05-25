from flask import Blueprint, jsonify, render_template, request
from loguru import logger

from core.config import settings
from core.iq import iq_client

auth_bp = Blueprint("auth", __name__)


@auth_bp.get("/")
def login_page():
    if iq_client.is_connected():
        return render_template("dashboard.html")
    return render_template("login.html")


@auth_bp.post("/login")
def login_submit():
    payload = request.get_json(silent=True) or {}
    email = payload.get("email", "").strip() or settings.iq_option_email.strip()
    password = payload.get("password", "") or settings.iq_option_password

    logger.info("Login submitted | email={} | password_length={}", email, len(password))
    try:
        result = iq_client.connect(email, password)
    except Exception:
        logger.exception("Unhandled exception during login flow")
        return jsonify(
            {
                "ok": False,
                "message": "Falha interna ao concluir a conexao com a IQ Option.",
                "data": {},
            }
        ), 500

    status_code = 200 if result.ok else 401
    return jsonify({"ok": result.ok, "message": result.message, "data": result.payload}), status_code


@auth_bp.get("/api/session")
def session_status():
    return jsonify(iq_client.get_status())
