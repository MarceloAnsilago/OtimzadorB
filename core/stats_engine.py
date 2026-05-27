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
    max_loss_streak: int
    max_loss_streak_entry_1: int
    max_loss_streak_entry_2: int
    max_loss_streak_entry_3: int
    break_even_hit_rate_pct: float | None
    equity_curve: list[float]


@dataclass(slots=True)
class BankrollConfig:
    initial_capital: float
    initial_stake: float
    payout: float
    stake_mode: str


def _resolve_base_stake(capital: float, config: BankrollConfig) -> float:
    if config.stake_mode == "percentage":
        return capital * (config.initial_stake / 100.0)
    return config.initial_stake


def _resolve_operation_stakes(capital: float, config: BankrollConfig, attempts_used: int) -> list[float]:
    payout_ratio = config.payout / 100.0
    if payout_ratio <= 0:
        return []

    base_stake = _resolve_base_stake(capital, config)
    desired_profit = base_stake * payout_ratio
    stakes: list[float] = []
    accumulated_loss = 0.0

    for attempt_index in range(attempts_used):
        if attempt_index == 0:
            stake = base_stake
        else:
            stake = (accumulated_loss + desired_profit) / payout_ratio
        stakes.append(stake)
        accumulated_loss += stake

    return stakes


def _current_ruin_threshold(capital: float, config: BankrollConfig) -> float:
    if config.stake_mode == "percentage":
        return 0.01
    return max(min(config.initial_stake, capital), 0.01)


def _run_bankroll_path(results: list[MartingaleResult], config: BankrollConfig) -> tuple[list[float], bool, float, float]:
    capital = config.initial_capital
    payout_ratio = config.payout / 100.0
    epsilon = 1e-9
    equity_curve = [round(capital, 4)]
    peak_capital = capital
    max_drawdown_pct = 0.0

    for result in results:
        stakes = _resolve_operation_stakes(capital, config, result.attempts_used)
        if len(stakes) < result.attempts_used:
            equity_curve.append(round(capital, 4))
            drawdown_pct = ((peak_capital - capital) / peak_capital) * 100.0 if peak_capital > epsilon else 0.0
            return equity_curve, True, capital, max(max_drawdown_pct, drawdown_pct)

        for attempt_index, stake in enumerate(stakes):
            if stake <= 0:
                equity_curve.append(0.0)
                return equity_curve, True, 0.0, 100.0
            if stake > capital + epsilon:
                equity_curve.append(round(capital, 4))
                drawdown_pct = ((peak_capital - capital) / peak_capital) * 100.0 if peak_capital > epsilon else 0.0
                return equity_curve, True, capital, max(max_drawdown_pct, drawdown_pct)

            is_winning_attempt = result.step is not None and attempt_index == result.step
            if is_winning_attempt:
                capital += stake * payout_ratio
                break

            capital -= stake
            if capital <= epsilon:
                equity_curve.append(0.0)
                return equity_curve, True, 0.0, 100.0

        if capital <= epsilon:
            equity_curve.append(0.0)
            return equity_curve, True, 0.0, 100.0
        if capital + epsilon < _current_ruin_threshold(capital, config):
            equity_curve.append(round(capital, 4))
            drawdown_pct = ((peak_capital - capital) / peak_capital) * 100.0 if peak_capital > epsilon else 0.0
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


def _max_consecutive_full_losses(results: list[MartingaleResult]) -> int:
    max_streak = 0
    current_streak = 0
    for result in results:
        if result.outcome == "LOSS":
            current_streak += 1
            max_streak = max(max_streak, current_streak)
            continue
        current_streak = 0
    return max_streak


def _max_loss_streaks_by_entry(results: list[MartingaleResult]) -> tuple[int, int, int]:
    max_entry_1 = 0
    max_entry_2 = 0
    max_entry_3 = 0
    current_entry_1 = 0
    current_entry_2 = 0
    current_entry_3 = 0

    for result in results:
        if result.attempts_used >= 2:
            current_entry_1 += 1
            max_entry_1 = max(max_entry_1, current_entry_1)
        else:
            current_entry_1 = 0

        if result.attempts_used >= 3:
            current_entry_2 += 1
            max_entry_2 = max(max_entry_2, current_entry_2)
        else:
            current_entry_2 = 0

        if result.attempts_used >= 4:
            current_entry_3 += 1
            max_entry_3 = max(max_entry_3, current_entry_3)
        else:
            current_entry_3 = 0

    return max_entry_1, max_entry_2, max_entry_3


def _simulate_operation_pnl(result: MartingaleResult, config: BankrollConfig, reference_capital: float) -> float:
    capital = reference_capital
    starting_capital = reference_capital
    payout_ratio = config.payout / 100.0

    stakes = _resolve_operation_stakes(capital, config, result.attempts_used)
    if len(stakes) < result.attempts_used:
        return capital - starting_capital

    for attempt_index, stake in enumerate(stakes):
        is_winning_attempt = result.step is not None and attempt_index == result.step
        if is_winning_attempt:
            capital += stake * payout_ratio
            break
        capital -= stake

    return capital - starting_capital


def _estimate_break_even_hit_rate(results: list[MartingaleResult], config: BankrollConfig) -> float | None:
    if not results:
        return None

    pnls = [_simulate_operation_pnl(result, config, config.initial_capital) for result in results]
    positive_pnls = [pnl for pnl in pnls if pnl > 0]
    negative_pnls = [abs(pnl) for pnl in pnls if pnl < 0]

    if not positive_pnls:
        return None
    if not negative_pnls:
        return 0.0

    avg_profit = sum(positive_pnls) / len(positive_pnls)
    avg_loss = sum(negative_pnls) / len(negative_pnls)
    if avg_profit <= 0:
        return None

    return (avg_loss / (avg_profit + avg_loss)) * 100.0


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
    max_loss_streak = _max_consecutive_full_losses(martingale_results)
    max_loss_streak_entry_1, max_loss_streak_entry_2, max_loss_streak_entry_3 = _max_loss_streaks_by_entry(
        martingale_results
    )
    break_even_hit_rate_pct = _estimate_break_even_hit_rate(martingale_results, bankroll_config)
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
        max_loss_streak=max_loss_streak,
        max_loss_streak_entry_1=max_loss_streak_entry_1,
        max_loss_streak_entry_2=max_loss_streak_entry_2,
        max_loss_streak_entry_3=max_loss_streak_entry_3,
        break_even_hit_rate_pct=round(break_even_hit_rate_pct, 2) if break_even_hit_rate_pct is not None else None,
        equity_curve=equity_curve,
    )
