from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

import orjson
from sqlalchemy import DateTime, String, Text, select
from sqlalchemy.orm import Mapped, Session, mapped_column

from core.database import Base, SessionLocal, engine


class ParameterConfig(Base):
    __tablename__ = "parameter_configs"

    key: Mapped[str] = mapped_column(String(100), primary_key=True)
    value_json: Mapped[str] = mapped_column(Text, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class ParameterStore:
    def _ensure_schema(self) -> None:
        Base.metadata.create_all(bind=engine, tables=[ParameterConfig.__table__])

    def get(self, key: str, default: Any = None) -> Any:
        self._ensure_schema()
        with SessionLocal() as session:
            model = session.get(ParameterConfig, key)
            if model is None:
                return default
            return orjson.loads(model.value_json)

    def set(self, key: str, value: Any) -> None:
        self._ensure_schema()
        payload = orjson.dumps(value).decode("utf-8")
        with SessionLocal() as session:
            model = session.get(ParameterConfig, key)
            if model is None:
                model = ParameterConfig(
                    key=key,
                    value_json=payload,
                    updated_at=datetime.now(timezone.utc),
                )
                session.add(model)
            else:
                model.value_json = payload
                model.updated_at = datetime.now(timezone.utc)
            session.commit()

    def get_optimizer_state(self) -> dict[str, Any]:
        return self.get(
            "optimizer_state",
            {
                "cycle": 5,
                "range_max_value": 35,
                "range_max_start": 0,
                "range_max_step": 5,
                "range_max_end": 60,
                "wick_to_wick": False,
            },
        )

    def save_optimizer_state(self, state: dict[str, Any]) -> None:
        self.set("optimizer_state", state)


parameter_store = ParameterStore()
