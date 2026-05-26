from __future__ import annotations

from dataclasses import dataclass

from core.candle_classifier import CandleDirection
from core.cycle_engine import CycleWindow
from core.signal_engine import CandleSignal


@dataclass(slots=True)
class MartingaleResult:
    outcome: str
    step: int | None
    attempts_used: int


def evaluate_martingale(signal: CandleSignal, cycle_window: CycleWindow, max_gales: int = 3) -> MartingaleResult:
    attempts = min(len(cycle_window.candles), max_gales + 1)
    for attempt in range(attempts):
        candle = cycle_window.candles[attempt]
        candle_direction = CandleDirection(str(candle["direction"]))
        if candle_direction is signal.direction:
            return MartingaleResult(outcome=f"WIN_G{attempt}", step=attempt, attempts_used=attempt + 1)
    return MartingaleResult(outcome="LOSS", step=None, attempts_used=attempts)
