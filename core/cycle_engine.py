from __future__ import annotations

from dataclasses import dataclass

import pandas as pd


@dataclass(slots=True)
class CycleWindow:
    source_index: int
    candles: list[pd.Series]


def get_cycle_window(dataframe: pd.DataFrame, source_index: int, cycle: int) -> CycleWindow:
    candles: list[pd.Series] = []
    for offset in range(1, cycle + 1):
        next_index = source_index + offset
        if next_index >= len(dataframe):
            break
        candles.append(dataframe.iloc[next_index])
    return CycleWindow(source_index=source_index, candles=candles)


def get_entry_windows(
    dataframe: pd.DataFrame,
    source_index: int,
    cycle: int,
    max_gales: int = 3,
) -> list[CycleWindow]:
    windows: list[CycleWindow] = []
    for entry_offset in range(1, cycle + 1):
        candles: list[pd.Series] = []
        for gale_offset in range(0, max_gales + 1):
            next_index = source_index + entry_offset + gale_offset
            if next_index >= len(dataframe):
                break
            candles.append(dataframe.iloc[next_index])
        if candles:
            windows.append(CycleWindow(source_index=source_index + entry_offset - 1, candles=candles))
    return windows
