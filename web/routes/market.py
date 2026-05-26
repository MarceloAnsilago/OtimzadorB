from __future__ import annotations

from flask import Blueprint, jsonify, render_template, request

from core.iq import iq_client
from core.optimizer_engine import OptimizationRequest, OptimizerEngine, ParameterDefinition
from core.parameter_store import parameter_store

market_bp = Blueprint("market", __name__)
optimizer_engine = OptimizerEngine()


@market_bp.get("/dashboard")
def dashboard_page():
    if not iq_client.is_connected():
        return render_template("login.html")
    return render_template("dashboard.html", active_page="dashboard")


@market_bp.get("/parameters")
def parameters_page():
    if not iq_client.is_connected():
        return render_template("login.html")

    last_download = iq_client.get_last_download()
    optimizer_state = parameter_store.get_optimizer_state()
    parameters = {
        "asset": last_download.get("asset", ""),
        "count": last_download.get("count", 1000),
        "interval_seconds": last_download.get("interval_seconds", 60),
        "category": last_download.get("category", ""),
        "rows": last_download.get("rows", 0),
        "file_path": last_download.get("file_path", ""),
        "started_at": last_download.get("started_at", ""),
        "ended_at": last_download.get("ended_at", ""),
    }
    return render_template(
        "parameters.html",
        active_page="parameters",
        parameters=parameters,
        optimizer_state=optimizer_state,
    )


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


@market_bp.post("/api/optimizer/test")
def optimizer_test():
    if not iq_client.is_connected():
        return jsonify({"ok": False, "message": "Sessao IQ Option desconectada."}), 401

    last_download = iq_client.get_last_download()
    dataset_path = last_download.get("file_path", "")
    if not dataset_path:
        return jsonify({"ok": False, "message": "Nenhum dataset foi baixado ainda."}), 400

    payload = request.get_json(silent=True) or {}
    cycle = int(payload.get("cycle", 5))
    initial_capital = float(payload.get("initial_capital", 100))
    initial_stake = float(payload.get("initial_stake", 2))
    payout = float(payload.get("payout", 80))
    stake_mode = str(payload.get("stake_mode", "fixed")).strip().lower()
    range_max_value = float(payload.get("range_max_value", 35))
    range_max_start = float(payload.get("range_max_start", 0))
    range_max_step = float(payload.get("range_max_step", 5))
    range_max_end = float(payload.get("range_max_end", 60))
    wick_to_wick = bool(payload.get("wick_to_wick", False))

    if cycle < 1:
        return jsonify({"ok": False, "message": "Ciclo deve ser maior que zero."}), 400
    if initial_capital <= 0:
        return jsonify({"ok": False, "message": "Capital inicial deve ser maior que zero."}), 400
    if initial_stake <= 0:
        return jsonify({"ok": False, "message": "Aporte inicial deve ser maior que zero."}), 400
    if payout < 0:
        return jsonify({"ok": False, "message": "Payout deve ser zero ou maior."}), 400
    if stake_mode not in {"fixed", "percentage"}:
        return jsonify({"ok": False, "message": "Modo do aporte invalido."}), 400
    if range_max_step <= 0:
        return jsonify({"ok": False, "message": "Passo deve ser maior que zero."}), 400
    if range_max_end < range_max_start:
        return jsonify({"ok": False, "message": "Fim deve ser maior ou igual ao inicio."}), 400

    parameter_store.save_optimizer_state(
        {
            "cycle": cycle,
            "initial_capital": initial_capital,
            "initial_stake": initial_stake,
            "payout": payout,
            "stake_mode": stake_mode,
            "range_max_value": range_max_value,
            "range_max_start": range_max_start,
            "range_max_step": range_max_step,
            "range_max_end": range_max_end,
            "wick_to_wick": wick_to_wick,
        }
    )

    request_model = OptimizationRequest(
        dataset_path=dataset_path,
        cycle=cycle,
        initial_capital=initial_capital,
        initial_stake=initial_stake,
        payout=payout,
        stake_mode=stake_mode,
        parameter=ParameterDefinition(
            key="range_max",
            label="Tamanho maximo do range do candle (pontos)",
            value_type="int",
        ),
        start=range_max_start,
        step=range_max_step,
        end=range_max_end,
        fixed_filters={"wick_to_wick": wick_to_wick},
    )

    try:
        result = optimizer_engine.run(request_model)
    except Exception as exc:
        return jsonify({"ok": False, "message": str(exc)}), 400

    return jsonify({"ok": True, "message": "Otimizacao concluida.", "data": result})


@market_bp.post("/api/optimizer/promote")
def optimizer_promote():
    payload = request.get_json(silent=True) or {}
    selected_value = float(payload.get("param", 0))
    state = parameter_store.get_optimizer_state()
    state["range_max_value"] = selected_value
    parameter_store.save_optimizer_state(state)
    return jsonify({"ok": True, "message": "Parametro promovido com sucesso.", "state": state})
