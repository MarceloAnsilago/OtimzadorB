from __future__ import annotations

from enum import StrEnum

import pandas as pd


class CandleDirection(StrEnum):
    BULL = "BULL"
    BEAR = "BEAR"
    DOJI = "DOJI"


def classify_candle(open_price: float, close_price: float) -> CandleDirection:
    if close_price > open_price:
        return CandleDirection.BULL
    if close_price < open_price:
        return CandleDirection.BEAR
    return CandleDirection.DOJI


def add_candle_classification(dataframe: pd.DataFrame) -> pd.DataFrame:
    enriched = dataframe.copy()
    enriched["direction"] = [
        classify_candle(open_price, close_price).value
        for open_price, close_price in zip(enriched["open"], enriched["close"])
    ]
    enriched["range_size"] = enriched["max"] - enriched["min"]
    enriched["upper_wick"] = enriched["max"] - enriched[["open", "close"]].max(axis=1)
    enriched["lower_wick"] = enriched[["open", "close"]].min(axis=1) - enriched["min"]
    return enriched
