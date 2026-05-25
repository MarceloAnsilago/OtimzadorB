from __future__ import annotations

from dataclasses import dataclass


@dataclass(slots=True)
class OptimizationStats:
    param: float
    g0: int
    g1: int
    g2: int
    g3: int
    loss: int
    ops: int
    score: float


def build_stats(param_value: float, counters: dict[str, int]) -> OptimizationStats:
    g0 = counters.get("WIN_G0", 0)
    g1 = counters.get("WIN_G1", 0)
    g2 = counters.get("WIN_G2", 0)
    g3 = counters.get("WIN_G3", 0)
    loss = counters.get("LOSS", 0)
    ops = g0 + g1 + g2 + g3 + loss
    score = (g0 * 1.0) + (g1 * 0.82) + (g2 * 0.64) + (g3 * 0.46) - (loss * 1.0)
    return OptimizationStats(
        param=param_value,
        g0=g0,
        g1=g1,
        g2=g2,
        g3=g3,
        loss=loss,
        ops=ops,
        score=round(score, 4),
    )
