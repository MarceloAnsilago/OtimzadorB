from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import pandas as pd


@dataclass(slots=True)
class FilterContext:
    values: dict[str, Any]


def filter_range_max(row: pd.Series, context: FilterContext) -> bool:
    range_limit = float(context.values.get("range_max", 0))
    return float(row["range_size"]) <= range_limit


def filter_wick_to_wick(row: pd.Series, context: FilterContext) -> bool:
    wick_mode = bool(context.values.get("wick_to_wick", False))
    if not wick_mode:
        return True
    return float(row["upper_wick"]) > 0 and float(row["lower_wick"]) > 0


FILTER_REGISTRY = {
    "range_max": filter_range_max,
    "wick_to_wick": filter_wick_to_wick,
}


def apply_filters(row: pd.Series, context: FilterContext) -> bool:
    return all(filter_fn(row, context) for filter_fn in FILTER_REGISTRY.values())
