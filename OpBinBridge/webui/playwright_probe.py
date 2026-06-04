from __future__ import annotations

import ctypes
import json
import re
import time
import unicodedata
from pathlib import Path
from typing import Iterable

import cv2
import mss
import numpy as np
import pygetwindow as gw
from playwright.sync_api import BrowserContext, Frame, Locator, Page, TimeoutError, sync_playwright
from rapidocr_onnxruntime import RapidOCR


ROOT_DIR = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT_DIR / "config.json"
PROFILE_DIR = ROOT_DIR / "webui" / "playwright-profile"
LOG_PATH = ROOT_DIR / "logs" / "playwright_probe.log"
ARTIFACTS_DIR = ROOT_DIR / "logs" / "playwright_probe"
LOGIN_URL = "https://login.iqoption.com/pt/login?redirect_url=traderoom"
SW_MINIMIZE = 6
OCR_ENGINE: RapidOCR | None = None


def load_config() -> dict:
    return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))


def log(message: str) -> None:
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    line = f"{timestamp} {message}"
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with LOG_PATH.open("a", encoding="utf-8") as handle:
        handle.write(line + "\n")
    print(line)


def artifact_path(name: str) -> Path:
    ARTIFACTS_DIR.mkdir(parents=True, exist_ok=True)
    return ARTIFACTS_DIR / name


def get_ocr_engine() -> RapidOCR:
    global OCR_ENGINE
    if OCR_ENGINE is None:
        OCR_ENGINE = RapidOCR()
    return OCR_ENGINE


def normalize_symbol_text(text: str) -> str:
    return re.sub(r"[^A-Z]", "", text.upper())


def normalize_ui_text(text: str) -> str:
    stripped = unicodedata.normalize("NFKD", text)
    ascii_only = stripped.encode("ascii", "ignore").decode("ascii")
    return re.sub(r"[^a-z0-9]+", "", ascii_only.lower())


def minimize_console_window() -> None:
    try:
        kernel32 = ctypes.windll.kernel32
        user32 = ctypes.windll.user32
        hwnd = kernel32.GetConsoleWindow()
        if hwnd:
            user32.ShowWindow(hwnd, SW_MINIMIZE)
            log("Janela do console minimizada para liberar a captura da tela.")
    except Exception as exc:
        log(f"Falha ao minimizar console: {exc}")


def first_visible(locators: Iterable[Locator]) -> Locator | None:
    for locator in locators:
        try:
            if locator.count() > 0 and locator.first.is_visible():
                return locator.first
        except Exception:
            continue
    return None


def visible_text_input(page: Page) -> Locator | None:
    return first_visible(
        (
            page.locator("input[type='email']"),
            page.locator("input[type='text']"),
            page.locator("input:not([type])"),
            page.locator("input[name='email']"),
            page.locator("input[name='identifier']"),
            page.locator("input[autocomplete='username']"),
            page.locator("input[placeholder*='ticker' i]"),
            page.locator("input[placeholder*='nome' i]"),
            page.locator("input[placeholder*='ativo' i]"),
        )
    )


def visible_password_input(page: Page) -> Locator | None:
    return first_visible(
        (
            page.locator("input[type='password']"),
            page.locator("input[name='password']"),
            page.locator("input[autocomplete='current-password']"),
        )
    )


def visible_submit_button(page: Page) -> Locator | None:
    return first_visible(
        (
            page.get_by_role("button", name="Entrar"),
            page.get_by_text("Entrar", exact=True),
            page.locator("button[type='submit']"),
            page.locator("button"),
        )
    )


def wait_for_traderoom(page: Page) -> bool:
    if "/traderoom" in page.url.lower():
        return True

    try:
        page.wait_for_url("**/traderoom", timeout=20000)
    except TimeoutError:
        pass

    markers = (
        page.get_by_role("button", name="ACIMA"),
        page.get_by_role("button", name="ABAIXO"),
        page.get_by_text("Depositar", exact=False),
    )
    try:
        page.wait_for_timeout(1500)
        if "/traderoom" in page.url.lower():
            return True
        return first_visible(markers) is not None
    except Exception:
        return False


def wait_for_operational_traderoom(page: Page, timeout_ms: int = 45000) -> bool:
    deadline = time.time() + (timeout_ms / 1000.0)
    consecutive_ready = 0
    while time.time() < deadline:
        try:
            text = page.evaluate(
                "() => ((document.body && document.body.textContent) || '').replace(/\\s+/g, ' ').trim()"
            )
        except Exception:
            text = ""

        lowered = str(text).lower()
        if "/traderoom" in page.url.lower():
            splash_terms = ("conectando", "baixar aplicativo", "parceira oficial")
            if not any(term in lowered for term in splash_terms):
                consecutive_ready += 1
                log(f"Traderoom sem splash detectada ({consecutive_ready}/3).")
                if consecutive_ready >= 3:
                    page.wait_for_timeout(4000)
                    log("Traderoom operacional detectada.")
                    return True
            else:
                consecutive_ready = 0
                log("Traderoom ainda em splash/conectando; aguardando...")
        page.wait_for_timeout(2000)
    log("Traderoom nao ficou operacional dentro do tempo limite.")
    return False


def run_ocr_with_boxes(image: np.ndarray) -> list[dict]:
    ocr = get_ocr_engine()
    try:
        result, _ = ocr(image)
    except Exception as exc:
        log(f"Falha no OCR com boxes: {exc}")
        return []
    rows: list[dict] = []
    for item in result or []:
        try:
            points, text, score = item
            xs = [int(point[0]) for point in points]
            ys = [int(point[1]) for point in points]
            rows.append(
                {
                    "text": str(text).strip(),
                    "score": float(score),
                    "box": (min(xs), min(ys), max(xs) - min(xs), max(ys) - min(ys)),
                }
            )
        except Exception:
            continue
    return rows


def find_ocr_row(rows: list[dict], target: str, top_max: int | None = None) -> dict | None:
    wanted = normalize_symbol_text(target)
    matches: list[dict] = []
    for row in rows:
        text = str(row.get("text", ""))
        if normalize_symbol_text(text) != wanted:
            continue
        x, y, w, h = row["box"]
        if top_max is not None and y > top_max:
            continue
        matches.append(row)
    if not matches:
        return None
    matches.sort(key=lambda row: (row["box"][1], row["box"][0]))
    return matches[0]


def find_ocr_text_row(rows: list[dict], target: str, top_max: int | None = None) -> dict | None:
    wanted = normalize_ui_text(target)
    matches: list[dict] = []
    for row in rows:
        text = str(row.get("text", ""))
        normalized = normalize_ui_text(text)
        if wanted not in normalized:
            continue
        x, y, w, h = row["box"]
        if top_max is not None and y > top_max:
            continue
        matches.append(row)
    if not matches:
        return None
    matches.sort(key=lambda row: (row["box"][1], row["box"][0]))
    return matches[0]


def find_top_asset_rows(rows: list[dict], top_max: int = 70) -> list[dict]:
    matches: list[dict] = []
    ignored_texts = {"+", "x"}
    header_right_limit = 1500
    for row in rows:
        text = str(row.get("text", "")).strip()
        lowered = text.lower()
        if not text:
            continue
        if lowered in ignored_texts:
            continue
        x, y, w, h = row["box"]
        if y > top_max or x < 220 or x > header_right_limit or w < 18 or h < 10:
            continue
        if "deposit" in lowered or "iq option" in lowered:
            continue
        if text.startswith("$"):
            continue
        if len(normalize_ui_text(text)) <= 1:
            continue
        matches.append(row)

    matches.sort(key=lambda row: (row["box"][0], row["box"][1]))
    if not matches:
        return []

    groups: list[list[dict]] = []
    for row in matches:
        x, y, w, h = row["box"]
        if not groups:
            groups.append([row])
            continue
        prev_group = groups[-1]
        prev_right = max(item["box"][0] + item["box"][2] for item in prev_group)
        if x - prev_right <= 45:
            prev_group.append(row)
        else:
            groups.append([row])

    tab_rows: list[dict] = []
    generic_labels = {"binaria", "blitz", "bliz"}
    for group in groups:
        left = min(item["box"][0] for item in group)
        top = min(item["box"][1] for item in group)
        right = max(item["box"][0] + item["box"][2] for item in group)
        bottom = max(item["box"][1] + item["box"][3] for item in group)
        preferred = [
            item for item in group if str(item.get("text", "")).strip().lower() not in generic_labels
        ]
        label_row = min(preferred or group, key=lambda item: (item["box"][1], item["box"][0]))
        tab_rows.append(
            {
                "text": str(label_row.get("text", "")).strip(),
                "box": (left, top, right - left, bottom - top),
                "label_box": label_row["box"],
            }
        )
    return tab_rows


def click_ocr_box(page: Page, row: dict, label: str) -> None:
    x, y, w, h = row["box"]
    cx = int(x + (w / 2))
    cy = int(y + (h / 2))
    page.mouse.click(cx, cy)
    log(f"Clique enviado em {label} nas coordenadas ({cx}, {cy}).")


def capture_asset_header_rows(page: Page, artifact_name: str) -> list[dict]:
    screenshot_path = artifact_path(artifact_name)
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is None:
        log(f"Falha ao capturar screenshot {artifact_name}.")
        return []
    return find_top_asset_rows(run_ocr_with_boxes(image))


def click_plus_button(page: Page, tabs: list[dict]) -> bool:
    if tabs:
        anchor_tab = tabs[-1]
        x, y, w, h = anchor_tab["box"]
        candidate_offsets = (64, 72, 80, 88, 96, 104)
        candidate_ys = (
            int(y + max(10, h * 0.45)),
            int(y + max(14, h * 0.65)),
        )

        for offset in candidate_offsets:
            for candidate_y in candidate_ys:
                plus_x = int(x + w + offset)
                plus_y = max(5, candidate_y)
                page.mouse.click(plus_x, plus_y)
                log(f"Clique enviado no botao de adicionar ativo nas coordenadas ({plus_x}, {plus_y}).")
                page.wait_for_timeout(900)
                if click_options_in_asset_menu(page):
                    return True

    screenshot_path = artifact_path("header_plus_button.png")
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is None:
        return False
    rows = run_ocr_with_boxes(image)
    plus_row = None
    candidates = []
    for row in rows:
        text = str(row.get("text", "")).strip()
        if text != "+":
            continue
        x, y, w, h = row["box"]
        if y > 90 or x < 250:
            continue
        candidates.append(row)
    if candidates:
        candidates.sort(key=lambda row: row["box"][0])
        plus_row = candidates[-1]
    if plus_row is None:
        return False
    click_ocr_box(page, plus_row, "botao adicionar ativo")
    page.wait_for_timeout(900)
    return click_options_in_asset_menu(page)


def click_options_in_asset_menu(page: Page) -> bool:
    options_button = first_visible(
        (
            page.get_by_text("Opções", exact=False),
            page.get_by_text("Opcoes", exact=False),
            page.get_by_role("button", name="Opções"),
            page.get_by_role("button", name="Opcoes"),
        )
    )
    if options_button is not None:
        try:
            options_button.click(timeout=3000)
            log("Clique enviado na opcao 'Opções' do menu de ativos.")
            page.wait_for_timeout(900)
            return True
        except Exception as exc:
            log(f"Falha ao clicar em 'Opções' via DOM: {exc}")

    screenshot_path = artifact_path("asset_menu_after_plus.png")
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is None:
        return False
    rows = run_ocr_with_boxes(image)
    option_row = find_ocr_text_row(rows, "Opções")
    if option_row is None:
        option_row = find_ocr_text_row(rows, "Opcoes")
    if option_row is None:
        return False
    click_ocr_box(page, option_row, "opcao Opções")
    page.wait_for_timeout(900)
    log("Clique enviado na opcao 'Opções' via OCR.")
    return True


def click_binaries_in_asset_menu(page: Page) -> bool:
    binaries_button = first_visible(
        (
            page.get_by_text("Binárias", exact=False),
            page.get_by_text("Binarias", exact=False),
            page.get_by_role("button", name="Binárias"),
            page.get_by_role("button", name="Binarias"),
        )
    )
    if binaries_button is not None:
        try:
            binaries_button.click(timeout=3000)
            log("Clique enviado na opcao 'Binárias' do menu de ativos.")
            page.wait_for_timeout(900)
            return True
        except Exception as exc:
            log(f"Falha ao clicar em 'Binárias' via DOM: {exc}")

    screenshot_path = artifact_path("asset_menu_after_options.png")
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is None:
        return False
    rows = run_ocr_with_boxes(image)
    binary_row = find_ocr_text_row(rows, "Binárias")
    if binary_row is None:
        binary_row = find_ocr_text_row(rows, "Binarias")
    if binary_row is None:
        return False
    click_ocr_box(page, binary_row, "opcao Binárias")
    page.wait_for_timeout(900)
    log("Clique enviado na opcao 'Binárias' via OCR.")
    return True


def set_invest_amount(page: Page, amount: str) -> bool:
    invest_input = first_visible(
        (
            page.locator("input[inputmode='decimal']"),
            page.locator("input[inputmode='numeric']"),
            page.locator("input[type='tel']"),
            page.locator("input"),
        )
    )
    if invest_input is not None:
        try:
            invest_input.click(timeout=3000)
            invest_input.fill("")
            invest_input.fill(amount)
            log(f"Aporte preenchido via DOM: {amount}")
            page.wait_for_timeout(500)
            return True
        except Exception as exc:
            log(f"Falha ao preencher aporte via DOM: {exc}")

    screenshot_path = artifact_path("invest_amount_input.png")
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is None:
        return False
    rows = run_ocr_with_boxes(image)
    invest_row = find_ocr_text_row(rows, "Invest", top_max=340)
    if invest_row is None:
        return False

    x, y, w, h = invest_row["box"]
    click_x = int(x + max(32, w * 0.35))
    click_y = int(y + h + 20)
    page.mouse.click(click_x, click_y)
    page.wait_for_timeout(400)
    page.keyboard.press("Control+A")
    page.keyboard.press("Backspace")
    page.keyboard.type(amount, delay=60)
    log(f"Aporte digitado via OCR/teclado: {amount}")
    page.wait_for_timeout(500)
    return True


def expiration_matches_target(value: str, target_minutes: int) -> bool:
    normalized = normalize_ui_text(value)
    accepted = {
        str(target_minutes),
        f"{target_minutes}m",
        f"{target_minutes}min",
        f"{target_minutes:02d}m",
        f"00{target_minutes:02d}",
        f"{target_minutes:02d}00",
        f"000{target_minutes}",
    }
    if normalized in accepted:
        return True

    digits_only = re.sub(r"\\D", "", value)
    if digits_only in {f"{target_minutes:02d}", f"00{target_minutes:02d}", f"{target_minutes:02d}00"}:
        return True
    return False


def parse_remaining_time_to_seconds(value: str) -> int | None:
    match = re.search(r"(\d{1,2})\s*:\s*(\d{2})", value)
    if not match:
        return None
    minutes = int(match.group(1))
    seconds = int(match.group(2))
    return (minutes * 60) + seconds


def parse_mmss_to_seconds(value: str) -> int | None:
    match = re.search(r"(\d{2})\s*:\s*(\d{2})", value)
    if not match:
        return None
    minutes = int(match.group(1))
    seconds = int(match.group(2))
    return (minutes * 60) + seconds


def open_expiration_menu(page: Page) -> bool:
    expiration_button = first_visible(
        (
            page.get_by_text("Expiração", exact=False),
            page.get_by_text("Expiracao", exact=False),
        )
    )
    if expiration_button is not None:
        try:
            expiration_button.click(timeout=3000)
            log("Clique enviado em 'Expiração' via DOM.")
            page.wait_for_timeout(900)
            return True
        except Exception as exc:
            log(f"Falha ao clicar em 'Expiração' via DOM: {exc}")

    screenshot_path = artifact_path("expiration_button.png")
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is None:
        return False
    rows = run_ocr_with_boxes(image)
    expiration_row = find_ocr_text_row(rows, "Expiração", top_max=360)
    if expiration_row is None:
        expiration_row = find_ocr_text_row(rows, "Expiracao", top_max=360)
    if expiration_row is None:
        return False
    click_ocr_box(page, expiration_row, "botao Expiração")
    page.wait_for_timeout(900)
    log("Clique enviado em 'Expiração' via OCR.")
    return True


def verify_first_remaining_under_limit(page: Page, max_seconds: int = 119) -> bool:
    if not open_expiration_menu(page):
        log("Nao consegui abrir o menu de expiracao.")
        return False

    screenshot_path = artifact_path("expiration_menu_open.png")
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is None:
        log("Falha ao capturar screenshot do menu de expiracao.")
        return False
    rows = run_ocr_with_boxes(image)
    remaining_row = find_ocr_text_row(rows, "Restante", top_max=900)
    if remaining_row is None:
        log("Coluna 'Restante' nao encontrada no menu de expiracao.")
        return False

    rx, ry, rw, rh = remaining_row["box"]
    candidates: list[tuple[int, str, dict]] = []
    for row in rows:
        x, y, w, h = row["box"]
        if y <= ry + rh:
            continue
        if x < rx - 30:
            continue
        if x > rx + 160:
            continue
        text = str(row.get("text", "")).strip()
        seconds = parse_remaining_time_to_seconds(text)
        if seconds is None:
            continue
        candidates.append((y, text, row))

    if not candidates:
        log("Nenhum tempo encontrado abaixo da coluna 'Restante'.")
        return False

    candidates.sort(key=lambda item: item[0])
    first_value = candidates[0][1]
    first_row = candidates[0][2]
    first_seconds = parse_remaining_time_to_seconds(first_value)
    if first_seconds is None:
        log(f"Primeiro item da coluna 'Restante' nao pode ser interpretado: {first_value}")
        return False

    if first_seconds <= max_seconds:
        log(f"Primeiro item da coluna 'Restante' confirmado abaixo de 2 minutos: {first_value}")
        click_ocr_box(page, first_row, "primeiro tempo disponivel da coluna Restante")
        page.wait_for_timeout(900)
        log(f"Tempo de expiracao selecionado: {first_value}")
        return True

    log(f"Primeiro item da coluna 'Restante' nao atende ao limite < 2 min: {first_value}")
    return False


def detect_purchase_timer(page: Page) -> tuple[str, int] | None:
    script = """
    () => {
      const visible = [];
      const visit = (node) => {
        if (!node || node.nodeType !== Node.ELEMENT_NODE) return;
        const style = window.getComputedStyle(node);
        const rect = node.getBoundingClientRect();
        if (style.visibility !== 'hidden' && style.display !== 'none' && rect.width > 0 && rect.height > 0) {
          const text = (node.textContent || '').trim();
          if (text) visible.push({ text, left: rect.left, top: rect.top, width: rect.width, height: rect.height });
        }
        for (const child of node.children) visit(child);
        if (node.shadowRoot) {
          for (const child of node.shadowRoot.children) visit(child);
        }
      };
      visit(document.body || document.documentElement);
      const timerRe = /^\\d{2}:\\d{2}$/;
      const timerNodes = visible.filter((item) => timerRe.test(item.text) && item.top < 140 && item.left > 900 && item.left < 1350);
      if (!timerNodes.length) return null;
      timerNodes.sort((a, b) => a.top - b.top || Math.abs(a.left - 1120) - Math.abs(b.left - 1120));
      return { text: timerNodes[0].text, top: timerNodes[0].top };
    }
    """
    for frame in candidate_frames(page):
        try:
            result = frame.evaluate(script)
        except Exception:
            continue
        if not result:
            continue
        text = str(result.get("text", "")).strip()
        seconds = parse_mmss_to_seconds(text)
        if seconds is None:
            continue
        match = re.search(r"(\d{2}\s*:\s*\d{2})", text)
        return (match.group(1).replace(" ", "") if match else text), seconds

    screenshot_path = artifact_path("purchase_timer_check.png")
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is None:
        return None
    rows = run_ocr_with_boxes(image)
    timer_candidates: list[tuple[int, int, str]] = []
    for row in rows:
        text = str(row.get("text", "")).strip()
        seconds = parse_mmss_to_seconds(text)
        if seconds is None:
            continue
        x, y, w, h = row["box"]
        if y > 140 or x < 900 or x > 1350:
            continue
        timer_candidates.append((y, x, text))
    if not timer_candidates:
        return None
    timer_candidates.sort(key=lambda item: (item[0], abs(item[1] - 1120)))
    timer_text = timer_candidates[0][2]
    timer_seconds = parse_mmss_to_seconds(timer_text)
    if timer_seconds is None:
        return None
    match = re.search(r"(\d{2}\s*:\s*\d{2})", timer_text)
    return (match.group(1).replace(" ", "") if match else timer_text), timer_seconds


def click_order_button_visual(page: Page, direction: str) -> bool:
    image = capture_window_image(page)
    if image is None:
        return False
    height, width = image.shape[:2]
    right_start = max(0, int(width * 0.76))
    right_panel = image[:, right_start:]
    hsv = cv2.cvtColor(right_panel, cv2.COLOR_BGR2HSV)

    green_mask = cv2.inRange(hsv, np.array([35, 90, 80]), np.array([95, 255, 255]))
    orange_mask = cv2.inRange(hsv, np.array([5, 100, 80]), np.array([25, 255, 255]))
    green_large = cv2.morphologyEx(green_mask, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
    orange_large = cv2.morphologyEx(orange_mask, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))

    up_box = detect_button_box(green_large)
    down_box = detect_button_box(orange_large)
    normalized = str(direction).upper().strip()
    wants_up = normalized in {"CALL", "UP", "ACIMA"}
    target_box = up_box if wants_up else down_box
    label = "ACIMA" if wants_up else "ABAIXO"
    if target_box is None:
        log(f"Botao {label} nao encontrado via deteccao visual.")
        return False

    x, y, w, h = target_box
    click_x = int(right_start + x + (w / 2))
    click_y = int(y + (h / 2))
    page.mouse.click(click_x, click_y)
    log(f"Ordem enviada no botao {label} via deteccao visual em ({click_x}, {click_y}).")
    return True


def click_order_button(page: Page, direction: str) -> bool:
    normalized = str(direction).upper().strip()
    wants_up = normalized in {"CALL", "UP", "ACIMA"}
    locators = (
        ("ACIMA", (lambda frame: first_visible((frame.get_by_role("button", name="ACIMA"), frame.get_by_text("ACIMA", exact=True))))),
        ("ABAIXO", (lambda frame: first_visible((frame.get_by_role("button", name="ABAIXO"), frame.get_by_text("ABAIXO", exact=True))))),
    )
    label = "ACIMA" if wants_up else "ABAIXO"
    finder = locators[0][1] if wants_up else locators[1][1]
    for frame in candidate_frames(page):
        button = finder(frame)
        if button is None:
            continue
        try:
            button.click(timeout=2000)
            log(f"Ordem enviada no botao {label}.")
            return True
        except Exception as exc:
            log(f"Falha ao clicar no botao {label} via DOM: {exc}")
    log(f"Botao {label} nao encontrado via DOM; tentando deteccao visual.")
    return click_order_button_visual(page, direction)


def wait_for_candle_close_and_place_order(page: Page, direction: str) -> bool:
    log("Aguardando fim da vela para enviar a ordem.")
    last_seconds: int | None = None
    deadline = time.time() + 180
    missing_counter = 0
    while time.time() < deadline:
        timer = detect_purchase_timer(page)
        if timer is None:
            missing_counter += 1
            if missing_counter % 20 == 0:
                log("Contador HORA DE COMPRA nao localizado nesta amostragem.")
            page.wait_for_timeout(150)
            continue
        missing_counter = 0
        timer_text, seconds_left = timer
        if last_seconds != seconds_left:
            log(f"Contador HORA DE COMPRA detectado: {timer_text}")
        if seconds_left > 1:
            last_seconds = seconds_left
            page.wait_for_timeout(200)
            continue

        if seconds_left == 0:
            return click_order_button(page, direction)

        if last_seconds is not None and seconds_left > last_seconds:
            return click_order_button(page, direction)

        last_seconds = seconds_left
        page.wait_for_timeout(40)

    log("Tempo limite atingido aguardando o fim da vela.")
    return False


def focus_asset_search_input(page: Page) -> bool:
    search_input = first_visible(
        (
            page.locator("input[placeholder*='ticker' i]"),
            page.locator("input[placeholder*='nome' i]"),
            page.locator("input[type='search']"),
            page.locator("input[type='text']"),
            page.locator("input:not([type])"),
        )
    )
    if search_input is not None:
        try:
            search_input.click(timeout=3000)
            log("Campo de busca de ativos focado via DOM.")
            return True
        except Exception as exc:
            log(f"Falha ao focar campo de busca via DOM: {exc}")

    screenshot_path = artifact_path("asset_search_input.png")
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is None:
        return False
    rows = run_ocr_with_boxes(image)
    search_row = find_ocr_text_row(rows, "Pesquisar por nome ou ticker", top_max=320)
    if search_row is None:
        search_row = find_ocr_text_row(rows, "ticker", top_max=320)
    if search_row is None:
        return False
    click_ocr_box(page, search_row, "campo de busca de ativos")
    page.wait_for_timeout(500)
    log("Campo de busca de ativos focado via OCR.")
    return True


def try_close_tab(page: Page, tab: dict, expected_count: int, attempt: int, label: str) -> list[dict] | None:
    x, y, w, h = tab["box"]
    label_x, label_y, label_w, label_h = tab.get("label_box", tab["box"])
    candidate_points = [
        (int(label_x - 34), int(y + 6)),
        (int(label_x - 30), int(y + 6)),
        (int(label_x - 26), int(y + 6)),
        (int(label_x - 22), int(y + 6)),
        (int(label_x - 18), int(y + 6)),
        (int(label_x - 30), int(y + 9)),
        (int(label_x - 26), int(y + 9)),
        (int(label_x - 22), int(y + 9)),
    ]

    for point_index, (candidate_x, candidate_y) in enumerate(candidate_points, start=1):
        click_x = max(5, candidate_x)
        click_y = max(5, candidate_y)
        page.mouse.click(click_x, click_y)
        log(
            f"Tentativa {attempt}.{point_index}: clique para fechar '{label}' em ({click_x}, {click_y})."
        )
        page.wait_for_timeout(700)
        updated_tabs = capture_asset_header_rows(page, f"asset_tabs_cleanup_step_{attempt}_{point_index}.png")
        if len(updated_tabs) < expected_count:
            log(f"Quantidade de abas apos fechamento: {len(updated_tabs)}")
            return updated_tabs
    return None


def close_extra_asset_tabs(page: Page) -> list[dict]:
    page.wait_for_timeout(1500)
    tabs = capture_asset_header_rows(page, "asset_tabs_before_cleanup.png")
    if not tabs:
        log("Nenhuma aba de ativo detectada no topo para limpeza.")
        return []

    if len(tabs) == 1 and tabs[0]["box"][0] < 500:
        log("Apenas uma aba de ativo detectada; nada para fechar.")
        return tabs

    log(f"{len(tabs)} abas detectadas no topo. Fechando ate sobrar apenas a aba fixa da esquerda.")
    attempts = 0
    while tabs and attempts < 30:
        if len(tabs) == 1 and tabs[0]["box"][0] < 500:
            break
        attempts += 1
        if len(tabs) > 1:
            tab = tabs[1]
        else:
            tab = tabs[0]
        updated_tabs = try_close_tab(page, tab, len(tabs), attempts, str(tab.get("text", "")))
        if updated_tabs is not None:
            tabs = updated_tabs
            continue

        log("A aba alvo nao fechou nessa iteracao; recapturando antes de tentar de novo.")
        tabs = capture_asset_header_rows(page, f"asset_tabs_cleanup_step_{attempts}_refresh.png")

    page.wait_for_timeout(1200)
    remaining_tabs = capture_asset_header_rows(page, "asset_tabs_after_cleanup.png")
    log(f"Abas restantes apos limpeza: {[row['text'] for row in remaining_tabs]}")
    return remaining_tabs


def open_asset_search_via_plus(page: Page) -> bool:
    tabs = close_extra_asset_tabs(page)
    if click_plus_button(page, tabs):
        click_binaries_in_asset_menu(page)
        if focus_asset_search_input(page):
            log("Campo de busca do seletor de ativos detectado apos abrir 'Binárias'.")
            return True

    log("Nao consegui abrir o seletor de ativos pelo botao +.")
    return False


def select_asset_via_ocr(page: Page, target_symbol: str) -> bool:
    page.wait_for_timeout(1000)
    if not open_asset_search_via_plus(page):
        log("Falha ao abrir a busca de ativo pelo botao de adicionar.")
        return False
    focus_asset_search_input(page)
    search_input = visible_text_input(page)
    if search_input is not None:
        try:
            search_input.click(timeout=3000)
            search_input.fill("")
            search_input.fill(target_symbol)
            log(f"Busca de ativo preenchida no input visivel: {target_symbol}")
        except Exception as exc:
            log(f"Falha ao preencher input visivel da busca ({exc}); usando teclado.")
            page.keyboard.press("Control+A")
            page.keyboard.press("Backspace")
            page.keyboard.type(target_symbol, delay=80)
            log(f"Busca de ativo digitada por teclado: {target_symbol}")
    else:
        page.keyboard.press("Control+A")
        page.keyboard.press("Backspace")
        page.keyboard.type(target_symbol, delay=80)
        log(f"Busca de ativo digitada por teclado: {target_symbol}")
    page.wait_for_timeout(1500)

    list_path = artifact_path("asset_select_after_type.png")
    page.screenshot(path=str(list_path))
    list_image = cv2.imread(str(list_path))
    if list_image is None:
        log("Falha ao capturar lista de ativos apos digitar busca.")
        return False

    target_display = f"{target_symbol[:3]}/{target_symbol[3:]}" if "/" not in target_symbol else target_symbol
    list_rows = run_ocr_with_boxes(list_image)
    target_row = find_ocr_row(list_rows, target_display)
    if target_row is None:
        target_row = find_ocr_row(list_rows, target_symbol)
    if target_row is None:
        log(f"Ativo {target_display} nao apareceu na lista OCR apos a busca.")
        return False

    click_ocr_box(page, target_row, f"ativo alvo {target_display}")
    page.wait_for_timeout(2500)

    verify_path = artifact_path("asset_select_verify.png")
    page.screenshot(path=str(verify_path))
    verify_image = cv2.imread(str(verify_path))
    if verify_image is None:
        return False
    verify_rows = run_ocr_with_boxes(verify_image)
    verified = find_ocr_row(verify_rows, target_display, top_max=90) is not None
    log(f"Selecao do ativo {target_display}: {'OK' if verified else 'NAO CONFIRMADA'}")
    return verified


def candidate_frames(page: Page) -> list[Frame]:
    return [page.main_frame, *page.frames]


def close_save_password_prompt(page: Page) -> None:
    dismiss_button = first_visible(
        (
            page.get_by_role("button", name="Agora não"),
            page.get_by_role("button", name="Agora nao"),
            page.get_by_role("button", name="Nunca"),
            page.get_by_label("Fechar"),
            page.get_by_text("Agora não", exact=True),
            page.get_by_text("Nunca", exact=True),
        )
    )
    if dismiss_button is None:
        log("Popup de salvar senha nao apareceu ou nao foi identificado.")
        return

    try:
        dismiss_button.click(timeout=3000)
        page.wait_for_timeout(500)
        log("Popup de salvar senha fechado.")
    except Exception as exc:
        log(f"Falha ao fechar popup de salvar senha: {exc}")


def try_login(page: Page, config: dict) -> None:
    email = str(config.get("email", "")).strip()
    password = str(config.get("password", "")).strip()
    if not email or not password:
        log("Email/senha ausentes no config.json; login automatico ignorado.")
        return

    current_url = page.url.lower()
    if "/traderoom" in current_url:
        log("Sessao ja esta na traderoom; login automatico nao necessario.")
        return
    if "login.iqoption.com" not in current_url and "/login" not in current_url:
        return

    log("Pagina de login detectada. Tentando autenticar automaticamente...")
    page.wait_for_timeout(1500)

    try:
        visible_input_count = page.locator("input:visible").count()
        log(f"Inputs visiveis detectados: {visible_input_count}")
    except Exception:
        pass

    email_input = visible_text_input(page)
    password_input = visible_password_input(page)
    submit_button = visible_submit_button(page)

    if email_input is None or password_input is None:
        log("Campos de login nao encontrados automaticamente.")
        return
    if submit_button is None:
        log("Botao de login nao encontrado automaticamente.")
        return

    email_input.click(timeout=3000)
    email_input.fill("")
    email_input.fill(email)

    password_input.click(timeout=3000)
    password_input.fill("")
    password_input.fill(password)

    page.wait_for_timeout(300)
    submit_button.click(timeout=5000)
    page.wait_for_timeout(3000)
    log(f"Login submetido. URL atual: {page.url}")
    close_save_password_prompt(page)


def detect_current_asset(page: Page) -> str | None:
    script = """
    () => {
      const collectElements = (root) => {
        const out = [];
        const visit = (node) => {
          if (!node) return;
          if (node.nodeType === Node.ELEMENT_NODE) {
            out.push(node);
            if (node.shadowRoot) {
              for (const child of node.shadowRoot.children) visit(child);
            }
            for (const child of node.children) visit(child);
          }
        };
        visit(root.body || root.documentElement || root);
        return out;
      };
      const pairRe = /^[A-Z]{3}\\/[A-Z]{3}(?:-OTC)?$/;
      const nodes = collectElements(document);
      const visible = nodes.filter((el) => {
        const style = window.getComputedStyle(el);
        const rect = el.getBoundingClientRect();
        return style.visibility !== 'hidden' && style.display !== 'none' && rect.width > 0 && rect.height > 0;
      });
      const matches = visible
        .map((el) => ({ text: (el.textContent || '').trim(), rect: el.getBoundingClientRect() }))
        .filter((item) => pairRe.test(item.text));
      if (!matches.length) return null;
      matches.sort((a, b) => (a.rect.top - b.rect.top) || (a.rect.left - b.rect.left));
      return matches[0].text;
    }
    """
    for frame in candidate_frames(page):
        try:
            asset = frame.evaluate(script)
            if asset:
                return str(asset)
        except Exception:
            continue
    return None


def collect_visible_text_samples(page: Page) -> list[str]:
    script = """
    () => {
      const collectElements = (root) => {
        const out = [];
        const visit = (node) => {
          if (!node) return;
          if (node.nodeType === Node.ELEMENT_NODE) {
            out.push(node);
            if (node.shadowRoot) {
              for (const child of node.shadowRoot.children) visit(child);
            }
            for (const child of node.children) visit(child);
          }
        };
        visit(root.body || root.documentElement || root);
        return out;
      };
      const nodes = collectElements(document);
      const visible = nodes.filter((el) => {
        const style = window.getComputedStyle(el);
        const rect = el.getBoundingClientRect();
        return style.visibility !== 'hidden' && style.display !== 'none' && rect.width > 0 && rect.height > 0;
      });
      const texts = visible
        .map((el) => (el.textContent || '').trim())
        .filter((text) => text && text.length <= 30)
        .slice(0, 200);
      return [...new Set(texts)];
    }
    """
    all_texts: list[str] = []
    for frame in candidate_frames(page):
        try:
            texts = list(frame.evaluate(script))
        except Exception:
            continue
        for text in texts:
            if text not in all_texts:
                all_texts.append(text)
            if len(all_texts) >= 50:
                return all_texts
    return all_texts


def detect_main_payout(page: Page) -> float | None:
    script = """
    () => {
      const collectElements = (root) => {
        const out = [];
        const visit = (node) => {
          if (!node) return;
          if (node.nodeType === Node.ELEMENT_NODE) {
            out.push(node);
            if (node.shadowRoot) {
              for (const child of node.shadowRoot.children) visit(child);
            }
            for (const child of node.children) visit(child);
          }
        };
        visit(root.body || root.documentElement || root);
        return out;
      };
      const percentRe = /^\\+?(\\d{1,3})%$/;
      const nodes = collectElements(document);
      const visible = nodes.filter((el) => {
        const style = window.getComputedStyle(el);
        const rect = el.getBoundingClientRect();
        return style.visibility !== 'hidden' && style.display !== 'none' && rect.width > 0 && rect.height > 0;
      });
      const matches = visible
        .map((el) => ({ text: (el.textContent || '').trim(), rect: el.getBoundingClientRect() }))
        .filter((item) => percentRe.test(item.text))
        .map((item) => ({
          value: Number(item.text.replace(/[+%]/g, '')),
          area: item.rect.width * item.rect.height,
          rightBias: item.rect.left,
        }));
      if (!matches.length) return null;
      matches.sort((a, b) => (b.rightBias - a.rightBias) || (b.area - a.area) || (b.value - a.value));
      return matches[0].value;
    }
    """
    for frame in candidate_frames(page):
        try:
            payout = frame.evaluate(script)
            if payout is not None:
                return float(payout)
        except Exception:
            continue
    return None


def log_frame_diagnostics(page: Page) -> None:
    parts: list[str] = []
    for index, frame in enumerate(candidate_frames(page)):
        try:
            name = frame.name or "-"
            url = frame.url or "-"
            text_count = len(collect_texts_from_frame(frame))
            parts.append(f"{index}:{name}:{url}:{text_count}")
        except Exception:
            continue
    log(f"Frames detectados: {parts}")


def collect_texts_from_frame(frame: Frame) -> list[str]:
    script = """
    () => {
      const collectElements = (root) => {
        const out = [];
        const visit = (node) => {
          if (!node) return;
          if (node.nodeType === Node.ELEMENT_NODE) {
            out.push(node);
            if (node.shadowRoot) {
              for (const child of node.shadowRoot.children) visit(child);
            }
            for (const child of node.children) visit(child);
          }
        };
        visit(root.body || root.documentElement || root);
        return out;
      };
      const nodes = collectElements(document);
      const visible = nodes.filter((el) => {
        const style = window.getComputedStyle(el);
        const rect = el.getBoundingClientRect();
        return style.visibility !== 'hidden' && style.display !== 'none' && rect.width > 0 && rect.height > 0;
      });
      const texts = visible
        .map((el) => (el.textContent || '').trim())
        .filter((text) => text && text.length <= 40);
      return [...new Set(texts)].slice(0, 50);
    }
    """
    try:
        return list(frame.evaluate(script))
    except Exception:
        return []


def log_dom_diagnostics(page: Page) -> None:
    try:
        body_inner_text = page.evaluate("() => (document.body && document.body.innerText) ? document.body.innerText : ''")
    except Exception:
        body_inner_text = ""
    try:
        body_text_content = page.evaluate("() => (document.body && document.body.textContent) ? document.body.textContent : ''")
    except Exception:
        body_text_content = ""
    try:
        html_length = page.evaluate("() => document.documentElement ? document.documentElement.outerHTML.length : 0")
    except Exception:
        html_length = 0

    direct_checks = {
        "depositar": 0,
        "acima": 0,
        "abaixo": 0,
        "percent": 0,
    }
    try:
        direct_checks["depositar"] = page.get_by_text("Depositar", exact=False).count()
    except Exception:
        pass
    try:
        direct_checks["acima"] = page.get_by_text("ACIMA", exact=False).count()
    except Exception:
        pass
    try:
        direct_checks["abaixo"] = page.get_by_text("ABAIXO", exact=False).count()
    except Exception:
        pass
    try:
        direct_checks["percent"] = page.locator("text=/\\d{1,3}%/").count()
    except Exception:
        pass

    log(f"Diagnostico DOM: innerText={len(body_inner_text)} textContent={len(body_text_content)} html={html_length} checks={direct_checks}")
    if body_inner_text:
        compact = " | ".join(body_inner_text.splitlines()[:20])
        log(f"Body innerText amostra: {compact[:500]}")


def detect_button_box(mask: np.ndarray, min_area: int = 8000) -> tuple[int, int, int, int] | None:
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    best_box = None
    best_area = 0
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        area = w * h
        if area < min_area:
            continue
        if h < 80 or w < 80:
            continue
        if area > best_area:
            best_area = area
            best_box = (x, y, w, h)
    return best_box


def detect_text_box(mask: np.ndarray, min_area: int = 40) -> tuple[int, int, int, int] | None:
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    boxes: list[tuple[int, int, int, int]] = []
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        area = w * h
        if area < min_area or w < 3 or h < 6:
            continue
        boxes.append((x, y, w, h))
    if not boxes:
        return None
    x1 = min(box[0] for box in boxes)
    y1 = min(box[1] for box in boxes)
    x2 = max(box[0] + box[2] for box in boxes)
    y2 = max(box[1] + box[3] for box in boxes)
    return (x1, y1, x2 - x1, y2 - y1)


def expand_box(box: tuple[int, int, int, int], image_shape: tuple[int, int, int], pad: int = 8) -> tuple[int, int, int, int]:
    x, y, w, h = box
    height, width = image_shape[:2]
    x1 = max(0, x - pad)
    y1 = max(0, y - pad)
    x2 = min(width, x + w + pad)
    y2 = min(height, y + h + pad)
    return (x1, y1, x2 - x1, y2 - y1)


def save_crop(image: np.ndarray, box: tuple[int, int, int, int] | None, name: str) -> None:
    if box is None:
        return
    x, y, w, h = box
    crop = image[y : y + h, x : x + w]
    if crop.size == 0:
        return
    cv2.imwrite(str(artifact_path(name)), crop)


def preprocess_for_ocr(image: np.ndarray, mode: str) -> np.ndarray:
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    scaled = cv2.resize(gray, None, fx=2.5, fy=2.5, interpolation=cv2.INTER_CUBIC)
    if mode == "payout":
        return scaled
    _, binary = cv2.threshold(scaled, 120, 255, cv2.THRESH_BINARY)
    return binary


def read_text_from_image(image: np.ndarray, mode: str) -> list[str]:
    ocr = get_ocr_engine()
    variants: list[np.ndarray] = [image]
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    variants.append(gray)
    variants.append(preprocess_for_ocr(image, mode))

    collected: list[str] = []
    for variant in variants:
        try:
            result, _ = ocr(variant)
        except Exception as exc:
            log(f"Falha no OCR ({mode}): {exc}")
            continue
        if not result:
            continue
        for item in result:
            try:
                text = str(item[1]).strip()
            except Exception:
                continue
            if text and text not in collected:
                collected.append(text)
    return collected


def parse_payout_from_texts(texts: list[str]) -> float | None:
    import re
    candidates: list[float] = []
    for text in texts:
        cleaned = text.replace("O", "0").replace("o", "0").replace("S", "5")
        for match in re.finditer(r"(\d{1,3})(?:[.,](\d{1,2}))?\s*%?", cleaned):
            integer = match.group(1)
            decimal = match.group(2)
            number = f"{integer}.{decimal}" if decimal else integer
            try:
                value = float(number)
            except Exception:
                continue
            candidates.append(value)
    preferred = [value for value in candidates if 50 <= value <= 100]
    if preferred:
        return max(preferred)
    fallback = [value for value in candidates if 1 <= value <= 100]
    if fallback:
        return max(fallback)
    return None


def detect_green_text_box(image: np.ndarray) -> tuple[int, int, int, int] | None:
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(hsv, np.array([35, 70, 70]), np.array([95, 255, 255]))
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, np.ones((2, 2), np.uint8))
    return detect_text_box(mask, min_area=20)


def crop_bottom_right_region(image: np.ndarray, top_ratio: float = 0.42, left_ratio: float = 0.56) -> tuple[np.ndarray, tuple[int, int]]:
    height, width = image.shape[:2]
    y = max(0, int(height * top_ratio))
    x = max(0, int(width * left_ratio))
    return image[y:, x:], (x, y)


def capture_window_image(page: Page) -> np.ndarray | None:
    minimize_console_window()
    page.wait_for_timeout(2500)
    screenshot_path = artifact_path("traderoom_full.png")
    page.screenshot(path=str(screenshot_path))
    image = cv2.imread(str(screenshot_path))
    if image is not None and image.mean() < 250:
        log("Screenshot capturada pelo Playwright com conteudo visivel.")
        return image

    log("Screenshot do Playwright veio branca; tentando captura da janela real com MSS.")
    try:
        title = page.title()
    except Exception:
        title = ""

    candidates = []
    for window in gw.getAllWindows():
        try:
            if not window.title or window.width <= 0 or window.height <= 0:
                continue
            if "iq option" in window.title.lower() or (title and title.lower() in window.title.lower()):
                candidates.append(window)
        except Exception:
            continue
    if not candidates:
        log("Nenhuma janela candidata encontrada para captura MSS.")
        return image

    target = max(candidates, key=lambda win: win.width * win.height)
    left = max(0, int(target.left))
    top = max(0, int(target.top))
    width = max(1, int(target.width))
    height = max(1, int(target.height))
    monitor = {"left": left, "top": top, "width": width, "height": height}

    try:
        with mss.mss() as sct:
            raw = sct.grab(monitor)
        window_image = np.array(raw)
        window_image = cv2.cvtColor(window_image, cv2.COLOR_BGRA2BGR)
        cv2.imwrite(str(artifact_path("traderoom_window_mss.png")), window_image)
        log(f"Captura MSS salva para janela '{target.title}' em {monitor}.")
        return window_image
    except Exception as exc:
        log(f"Falha na captura MSS: {exc}")
        return image


def analyze_traderoom_visual(page: Page) -> dict:
    image = capture_window_image(page)
    if image is None:
        log("Falha ao carregar screenshot da traderoom para analise visual.")
        return

    height, width = image.shape[:2]
    right_start = max(0, int(width * 0.76))
    right_panel = image[:, right_start:]
    cv2.imwrite(str(artifact_path("traderoom_right_panel.png")), right_panel)

    hsv = cv2.cvtColor(right_panel, cv2.COLOR_BGR2HSV)

    green_mask = cv2.inRange(hsv, np.array([35, 90, 80]), np.array([95, 255, 255]))
    orange_mask = cv2.inRange(hsv, np.array([5, 100, 80]), np.array([25, 255, 255]))

    green_large = cv2.morphologyEx(green_mask, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
    orange_large = cv2.morphologyEx(orange_mask, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))

    up_box = detect_button_box(green_large)
    down_box = detect_button_box(orange_large)

    payout_mask = cv2.morphologyEx(green_mask, cv2.MORPH_OPEN, np.ones((2, 2), np.uint8))
    if up_box is not None:
        ux, uy, uw, uh = up_box
        payout_mask[uy : uy + uh, max(0, ux - 10) : min(payout_mask.shape[1], ux + uw + 10)] = 0
    payout_box = detect_text_box(payout_mask)

    overlay = right_panel.copy()
    for label, box, color in (
        ("up", up_box, (0, 255, 0)),
        ("down", down_box, (0, 140, 255)),
        ("payout", payout_box, (255, 255, 0)),
    ):
        if box is None:
            continue
        x, y, w, h = box
        cv2.rectangle(overlay, (x, y), (x + w, y + h), color, 2)
        cv2.putText(overlay, label, (x, max(15, y - 6)), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2, cv2.LINE_AA)

    cv2.imwrite(str(artifact_path("traderoom_overlay.png")), overlay)
    save_crop(right_panel, up_box, "button_up.png")
    save_crop(right_panel, down_box, "button_down.png")
    save_crop(right_panel, payout_box, "payout_region.png")

    up_texts: list[str] = []
    down_texts: list[str] = []
    payout_texts: list[str] = []
    payout_value: float | None = None
    if up_box is not None:
        ux, uy, uw, uh = up_box
        up_texts = read_text_from_image(right_panel[uy : uy + uh, ux : ux + uw], "button")
    if down_box is not None:
        dx, dy, dw, dh = down_box
        down_texts = read_text_from_image(right_panel[dy : dy + dh, dx : dx + dw], "button")
    if payout_box is not None:
        px, py, pw, ph = payout_box
        payout_crop = right_panel[py : py + ph, px : px + pw]
        focused_crop, (focus_x, focus_y) = crop_bottom_right_region(payout_crop)
        cv2.imwrite(str(artifact_path("payout_focus_region.png")), focused_crop)
        green_box = detect_green_text_box(focused_crop)
        if green_box is not None:
            green_box = expand_box(green_box, focused_crop.shape, pad=12)
            gx, gy, gw_, gh_ = green_box
            green_crop = focused_crop[gy : gy + gh_, gx : gx + gw_]
            cv2.imwrite(str(artifact_path("payout_green_region.png")), green_crop)
            payout_texts = read_text_from_image(green_crop, "payout")
        else:
            payout_texts = read_text_from_image(focused_crop, "payout")
        payout_value = parse_payout_from_texts(payout_texts)

    log(f"Analise visual salva em {ARTIFACTS_DIR}")
    log(f"Deteccao visual direita: up={up_box} down={down_box} payout={payout_box}")
    log(f"OCR botoes/payout: up={up_texts} down={down_texts} payout={payout_texts} payout_num={payout_value}")
    return {
        "up_box": up_box,
        "down_box": down_box,
        "payout_box": payout_box,
        "payout_value": payout_value,
        "up_texts": up_texts,
        "down_texts": down_texts,
        "payout_texts": payout_texts,
    }


def detect_market_open(page: Page) -> bool:
    for frame in candidate_frames(page):
        up_button = first_visible(
            (
                frame.get_by_role("button", name="ACIMA"),
                frame.get_by_text("ACIMA", exact=True),
            )
        )
        down_button = first_visible(
            (
                frame.get_by_role("button", name="ABAIXO"),
                frame.get_by_text("ABAIXO", exact=True),
            )
        )
        if up_button is None or down_button is None:
            continue

        try:
            up_disabled = up_button.is_disabled()
        except Exception:
            up_disabled = False
        try:
            down_disabled = down_button.is_disabled()
        except Exception:
            down_disabled = False
        return not up_disabled and not down_disabled
    return False


def inspect_traderoom(page: Page, min_payout: float) -> None:
    if not wait_for_traderoom(page):
        log(f"Traderoom nao confirmada. URL atual: {page.url}")
        return

    if not wait_for_operational_traderoom(page):
        log("Analise abortada porque a traderoom nao saiu do estado de carregamento.")
        return

    close_save_password_prompt(page)
    page.wait_for_timeout(3000)

    asset = detect_current_asset(page) or "desconhecido"
    payout = detect_main_payout(page)
    market_open = detect_market_open(page)
    visible_samples = collect_visible_text_samples(page)
    visual = analyze_traderoom_visual(page)
    if payout is None and visual.get("payout_value") is not None:
        payout = float(visual["payout_value"])
    if not market_open and visual.get("up_box") is not None and visual.get("down_box") is not None:
        market_open = True

    payout_ok = payout is not None and payout >= min_payout
    payout_text = f"{payout:.2f}%" if payout is not None else "nao detectado"
    log(f"Traderoom confirmada. Ativo atual: {asset}")
    log(f"Mercado operavel agora: {'SIM' if market_open else 'NAO'}")
    log(f"Payout detectado: {payout_text}")
    log(f"Payout acima de {min_payout:.0f}%: {'SIM' if payout_ok else 'NAO'}")
    if payout is None:
        log_dom_diagnostics(page)
        log_frame_diagnostics(page)
        log(f"Amostra de textos visiveis: {visible_samples[:25]}")


def ensure_login_page(page: Page) -> None:
    current_url = page.url
    if "/traderoom" in current_url.lower():
        log(f"Traderoom ja aberta: {current_url}")
        return
    if "login.iqoption.com" in current_url and "redirect_url=traderoom" in current_url:
        log(f"Pagina de login ja aberta: {current_url}")
        return
    log(f"Navegando para login a partir de {current_url}")
    page.goto(LOGIN_URL, wait_until="domcontentloaded")
    try:
        page.wait_for_load_state("networkidle", timeout=10000)
    except TimeoutError:
        pass


def open_context() -> BrowserContext:
    PROFILE_DIR.mkdir(parents=True, exist_ok=True)
    playwright = sync_playwright().start()
    try:
        context = playwright.chromium.launch_persistent_context(
            user_data_dir=str(PROFILE_DIR),
            channel="chrome",
            headless=False,
            no_viewport=True,
            args=[
                "--start-maximized",
                "--disable-session-crashed-bubbl