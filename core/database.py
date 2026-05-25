from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

from core.config import settings

engine = create_engine(settings.database_url, echo=False, future=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
Base = declarative_base()


def init_database() -> None:
    # Import ORM models before create_all so metadata is registered.
    from core import parameter_store  # noqa: F401

    Base.metadata.create_all(bind=engine)
