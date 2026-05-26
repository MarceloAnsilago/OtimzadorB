from __future__ import annotations

from dataclasses import dataclass

from core.martingale_evaluator import MartingaleResult


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
    ruin_pct: float


@dataclass(slots=True)
class BankrollConfig:
    initial_capital: float
    initial_stake: float
    payout: float
    stake_mode: str


def _resolve_stake(capital: float, config: BankrollConfig) -> float:
    if config.stake_mode == "percentage":
        return capital * (config.initial_stake / 100.0)
    return config.initial_stake


def _simulate_bankroll(results: list[MartingaleResult], config: BankrollConfig) -> float:
    capital = config.initial_capital
    payout_ratio = config.payout / 100.0
    epsilon = 1e-9

    for result in results:
        for attempt_index in range(result.attempts_used):
            stake = _resolve_stake(capital, config)
            if stake <= 0:
                return 100.0
            if stake > capital + epsilon:
                return 100.0

            is_winning_attempt = result.step is not None and attempt_index == result.step
            if is_winning_attempt:
                capital += stake * payout_ratio
                break

            capital -= stake
            if capital <= epsilon:
                return 100.0

    return 0.0


def build_stats(
    param_value: float,
    counters: dict[str, int],
    martingale_results: list[MartingaleResult],
    bankroll_config: BankrollConfig,
) -> OptimizationStats:
    g0 = counters.get("WIN_G0", 0)
    g1 = counters.get("WIN_G1", 0)
    g2 = counters.get("WIN_G2", 0)
    g3 = counters.get("WIN_G3", 0)
    loss = counters.get("LOSS", 0)
    ops = g0 + g1 + g2 + g3 + loss
    score = (g0 * 1.0) + (g1 * 0.82) + (g2 * 0.64) + (g3 * 0.46) - (loss * 1.0)
    ruin_pct = _simulate_bankroll(martingale_results, bankroll_config)
    return OptimizationStats(
        param=param_value,
        g0=g0,
        g1=g1,
        g2=g2,
        g3=g3,
        loss=loss,
        ops=ops,
        score=round(score, 4),
        ruin_pct=round(ruin_pct, 2),
    )
