from __future__ import annotations

from enum import StrEnum
from math import isfinite

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


def _count_decimal_places(value: float) -> int:
    if not isfinite(value):
        return 0
    text = format(value, ".10f").rstrip("0").rstrip(".")
    if "." not in text:
        return 0
    return len(text.split(".", 1)[1])


def _infer_price_unit(dataframe: pd.DataFrame) -> float:
    max_decimals = 0
    for column_name in ("open", "close", "min", "max"):
        for value in dataframe[column_name]:
            max_decimals = max(max_decimals, _count_decimal_places(float(value)))
    if max_decimals <= 0:
        return 1.0
    return 10 ** (-max_decimals)


def add_candle_classification(dataframe: pd.DataFrame) -> pd.DataFrame:
    enriched = dataframe.copy()
    price_unit = _infer_price_unit(enriched)
    enriched["direction"] = [
        classify_candle(open_price, close_price).value
        for open_price, close_price in zip(enriched["open"], enriched["close"])
    ]
    enriched["range_size"] = (enriched["max"] - enriched["min"]) / price_unit
    enriched["upper_wick"] = enriched["max"] - enriched[["open", "close"]].max(axis=1)
    enriched["lower_wick"] = enriched[["open", "close"]].min(axis=1) - enriched["min"]
    return enriched
