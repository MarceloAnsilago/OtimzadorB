from __future__ import annotations

from flask import Blueprint, jsonify, render_template, request

from core.iq import iq_client

market_bp = Blueprint("market", __name__)


@market_bp.get("/dashboard")
def dashboard_page():
    if not iq_client.is_connected():
        return render_template("login.html")
    return render_template("dashboard.html")


@market_bp.get("/api/market/assets")
def market_assets():
    if not iq_client.is_connected():
        return jsonify({"ok": False, "message": "Sessao IQ Option desconectada."}), 401

    limit = request.args.get("limit", default=120, type=int)
    assets = iq_client.list_open_assets(limit=limit)
    return jsonify({"ok": True, "assets": assets})


@market_bp.post("/api/market/download")
def market_download():
    if not iq_client.is_connected():
        return jsonify({"ok": False, "message": "Sessao IQ Option desconectada."}), 401

    payload = request.get_json(silent=True) or {}
    asset = str(payload.get("asset", "")).strip().upper()
    interval_seconds = int(payload.get("interval_seconds", 60))
    count = int(payload.get("count", 200))

    if not asset:
        return jsonify({"ok": False, "message": "Informe um ativo valido."}), 400

    if interval_seconds not in {60, 300, 900, 1800, 3600, 86400}:
        return jsonify({"ok": False, "message": "Timeframe nao suportado nesta fase."}), 400

    if count < 10 or count > 5000:
        return jsonify({"ok": False, "message": "Quantidade deve ficar entre 10 e 5000 candles."}), 400

    try:
        result = iq_client.download_candles(asset, interval_seconds, count)
    except Exception as exc:
        return jsonify({"ok": False, "message": str(exc)}), 400

    return jsonify({"ok": True, "message": "Dados baixados com sucesso.", "data": result})
