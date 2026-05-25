from pathlib import Path

from loguru import logger


def configure_logging() -> None:
    logs_dir = Path("logs")
    logs_dir.mkdir(exist_ok=True)

    logger.remove()
    logger.add(
        logs_dir / "binrobo.log",
        rotation="5 MB",
        retention=5,
        level="INFO",
        enqueue=True,
        backtrace=False,
        diagnose=False,
    )
    logger.add(lambda message: print(message, end=""), level="INFO")
