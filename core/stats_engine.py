from __future__ import annotations

from dataclasses import dataclass
import random

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
    g0_pct: float
    g1_pct: float
    g2_pct: float
    g3_pct: float
    win_pct: float
    loss_pct: float
    score: float
    ruin_pct: float
    final_capital: float
    min_capital: float
    max_drawdown_pct: float
    equity_curve: list[float]


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


def _ruin_threshold(config: BankrollConfig) -> float:
    if config.stake_mode == "percentage":
        return max(config.initial_capital * (config.initial_stake / 100.0), 0.01)
    return max(config.initial_stake, 0.01)


def _run_bankroll_path(results: list[MartingaleResult], config: BankrollConfig) -> tuple[list[float], bool, float, float]:
    capital = config.initial_capital
    payout_ratio = config.payout / 100.0
    epsilon = 1e-9
    ruin_threshold = _ruin_threshold(config)
    equity_curve = [round(capital, 4)]
    min_capital = capital
    peak_capital = capital
    max_drawdown_pct = 0.0

    for result in results:
        for attempt_index in range(result.attempts_used):
            stake = _resolve_stake(capital, config)
            if stake <= 0:
                equity_curve.append(0.0)
                return equity_curve, True, 0.0, 100.0
            if stake > capital + epsilon:
                equity_curve.append(round(capital, 4))
                drawdown_pct = 100.0 if peak_capital > 0 else 0.0
                return equity_curve, True, capital, max(max_drawdown_pct, drawdown_pct)

            is_winning_attempt = result.step is not None and attempt_index == result.step
            if is_winning_attempt:
                capital += stake * payout_ratio
                break

            capital -= stake
            if capital <= epsilon:
                equity_curve.append(0.0)
                return equity_curve, True, 0.0, 100.0

        min_capital = min(min_capital, capital)
        if capital + epsilon < ruin_threshold:
            equity_curve.append(round(capital, 4))
            drawdown_pct = 100.0 if peak_capital > epsilon else 0.0
            return equity_curve, True, capital, max(max_drawdown_pct, drawdown_pct)
        peak_capital = max(peak_capital, capital)
        if peak_capital > epsilon:
            drawdown_pct = ((peak_capital - capital) / peak_capital) * 100.0
            max_drawdown_pct = max(max_drawdown_pct, drawdown_pct)
        equity_curve.append(round(capital, 4))

    return equity_curve, False, capital, round(max_drawdown_pct, 2)


def _estimate_ruin_probability(results: list[MartingaleResult], config: BankrollConfig, seed: int) -> float:
    if not results:
        return 0.0

    iterations = 200
    ruined_paths = 0
    sample = list(results)
    rng = random.Random(seed)

    for _ in range(iterations):
        rng.shuffle(sample)
        _, ruined, _, _ = _run_bankroll_path(sample, config)
        if ruined:
            ruined_paths += 1

    return (ruined_paths / iterations) * 100.0


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
    wins = g0 + g1 + g2 + g3
    g0_pct = (g0 / ops) * 100.0 if ops else 0.0
    g1_pct = (g1 / ops) * 100.0 if ops else 0.0
    g2_pct = (g2 / ops) * 100.0 if ops else 0.0
    g3_pct = (g3 / ops) * 100.0 if ops else 0.0
    win_pct = (wins / ops) * 100.0 if ops else 0.0
    loss_pct = (loss / ops) * 100.0 if ops else 0.0
    score = (g0 * 1.0) + (g1 * 0.82) + (g2 * 0.64) + (g3 * 0.46) - (loss * 1.0)
    equity_curve, _, final_capital, max_drawdown_pct = _run_bankroll_path(martingale_results, bankroll_config)
    ruin_pct = _estimate_ruin_probability(
        martingale_results,
        bankroll_config,
        seed=int(round(param_value * 1000)) + ops,
    )
    min_capital = min(equity_curve) if equity_curve else bankroll_config.initial_capital
    return OptimizationStats(
        param=param_value,
        g0=g0,
        g1=g1,
        g2=g2,
        g3=g3,
        loss=loss,
        ops=ops,
        g0_pct=round(g0_pct, 2),
        g1_pct=round(g1_pct, 2),
        g2_pct=round(g2_pct, 2),
        g3_pct=round(g3_pct, 2),
        win_pct=round(win_pct, 2),
        loss_pct=round(loss_pct, 2),
        score=round(score, 4),
        ruin_pct=round(ruin_pct, 2),
        final_capital=round(final_capital, 4),
        min_capital=round(min_capital, 4),
        max_drawdown_pct=max_drawdown_pct,
        equity_curve=equity_curve,
    )
