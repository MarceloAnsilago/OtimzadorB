from __future__ import annotations

from dataclasses import dataclass

import pandas as pd

from core.candle_classifier import CandleDirection
from core.candle_filters import FilterContext, apply_filters


@dataclass(slots=True)
class CandleSignal:
    index: int
    timestamp_utc: str
    direction: CandleDirection


def build_signals(dataframe: pd.DataFrame, filter_context: FilterContext) -> list[CandleSignal]:
    signals: list[CandleSignal] = []
    for index, row in dataframe.iterrows():
        direction = CandleDirection(str(row["direction"]))
        if direction is CandleDirection.DOJI:
            continue
        if not apply_filters(row, filter_context):
            continue
        signals.append(
            CandleSignal(
                index=index,
                timestamp_utc=str(row["timestamp_utc"]),
                direction=direction,
            )
        )
    return signals
