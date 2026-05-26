from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

import pandas as pd

from core.candle_classifier import add_candle_classification
from core.candle_filters import FilterContext
from core.cycle_engine import get_cycle_window
from core.martingale_evaluator import evaluate_martingale
from core.signal_engine import build_signals
from core.stats_engine import BankrollConfig, build_stats


@dataclass(slots=True)
class ParameterDefinition:
    key: str
    label: str
    value_type: str


@dataclass(slots=True)
class OptimizationRequest:
    dataset_path: str
    cycle: int
    initial_capital: float
    initial_stake: float
    payout: float
    stake_mode: str
    parameter: ParameterDefinition
    start: float
    step: float
    end: float
    fixed_filters: dict[str, Any]


def _generate_values(start: float, step: float, end: float, value_type: str) -> list[float | int]:
    values: list[float | int] = []
    current = start
    epsilon = 1e-9
    while current <= end + epsilon:
        if value_type == "int":
            values.append(int(round(current)))
        else:
            values.append(round(current, 8))
        current += step
    deduplicated = []
    for value in values:
        if value not in deduplicated:
            deduplicated.append(value)
    return deduplicated


class OptimizerEngine:
    def run(self, request: OptimizationRequest) -> dict[str, Any]:
        dataset_path = Path(request.dataset_path)
        if not dataset_path.exists():
            raise RuntimeError(f"Dataset nao encontrado: {dataset_path}")

        raw_dataframe = pd.read_csv(dataset_path)
        if raw_dataframe.empty:
            raise RuntimeError("O dataset carregado esta vazio.")

        dataframe = add_candle_classification(raw_dataframe)
        parameter_values = _generate_values(
            start=request.start,
            step=request.step,
            end=request.end,
            value_type=request.parameter.value_type,
        )
        if not parameter_values:
            raise RuntimeError("Nenhum valor foi gerado para a otimizacao.")

        result_rows: list[dict[str, Any]] = []
        for parameter_value in parameter_values:
            filter_values = dict(request.fixed_filters)
            filter_values[request.parameter.key] = parameter_value
            filter_context = FilterContext(values=filter_values)
            signals = build_signals(dataframe, filter_context)

            counters = {"WIN_G0": 0, "WIN_G1": 0, "WIN_G2": 0, "WIN_G3": 0, "LOSS": 0}
            martingale_results = []
            for signal in signals:
                cycle_window = get_cycle_window(dataframe, signal.index, request.cycle)
                if len(cycle_window.candles) < min(request.cycle, 4):
                    continue
                result = evaluate_martingale(signal, cycle_window, max_gales=3)
                counters[result.outcome] += 1
                martingale_results.append(result)

            stats = build_stats(
                float(parameter_value),
                counters,
                martingale_results,
                BankrollConfig(
                    initial_capital=request.initial_capital,
                    initial_stake=request.initial_stake,
                    payout=request.payout,
                    stake_mode=request.stake_mode,
                ),
            )
            result_rows.append(
                {
                    "param": parameter_value,
                    "g0": stats.g0,
                    "g1": stats.g1,
                    "g2": stats.g2,
                    "g3": stats.g3,
                    "loss": stats.loss,
                    "ops": stats.ops,
                    "win_pct": stats.win_pct,
                    "loss_pct": stats.loss_pct,
                    "score": stats.score,
                    "ruin_pct": stats.ruin_pct,
                    "final_capital": stats.final_capital,
                    "min_capital": stats.min_capital,
                    "max_drawdown_pct": stats.max_drawdown_pct,
                    "equity_curve": stats.equity_curve,
                }
            )

        result_rows.sort(key=lambda row: (row["score"], row["g0"], row["ops"]), reverse=True)
        return {
            "dataset_path": str(dataset_path),
            "parameter": {"key": request.parameter.key, "label": request.parameter.label},
            "rows": result_rows,
        }
