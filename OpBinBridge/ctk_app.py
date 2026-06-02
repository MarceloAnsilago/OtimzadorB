from __future__ import annotations

import json
import threading
import time
import tkinter as tk
from dataclasses import dataclass
from pathlib import Path
from tkinter import messagebox, ttk
from typing import Any

from iqoptionapi.stable_api import IQ_Option


ROOT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = ROOT_DIR / "config.json"


@dataclass
class AppConfig:
    email: str
    password: str
    balance_mode: str
    min_payout_percent: float
    use_otc_symbols: bool


def load_config(path: Path) -> AppConfig:
    if not path.exists():
        raise FileNotFoundError(f"Config ausente em {path}.")
    raw = json.loads(path.read_text(encoding="utf-8"))
    return AppConfig(
        email=str(raw.get("email", "")).strip(),
        password=str(raw.get("password", "")).strip(),
        balance_mode=str(raw.get("balance_mode", "PRACTICE")).upper().strip() or "PRACTICE",
        min_payout_percent=float(raw.get("min_payout_percent", 80.0)),
        use_otc_symbols=bool(raw.get("use_otc_symbols", False)),
    )


def save_config(path: Path, config: AppConfig) -> None:
    raw: dict[str, Any] = {}
    if path.exists():
        raw = json.loads(path.read_text(encoding="utf-8"))
    raw.update(
        {
            "email": config.email,
            "password": config.password,
            "balance_mode": config.balance_mode,
            "min_payout_percent": config.min_payout_percent,
            "use_otc_symbols": config.use_otc_symbols,
        }
    )
    path.write_text(json.dumps(raw, indent=2, ensure_ascii=True), encoding="utf-8")


class IQPayoutScanner:
    def __init__(self, config: AppConfig) -> None:
        self.config = config
        self.client: IQ_Option | None = None

    def connect(self) -> None:
        if self.client is not None:
            try:
                if self.client.check_connect():
                    return
            except Exception:
                self.client = None

        client = IQ_Option(self.config.email, self.config.password)
        result = client.connect()
        if isinstance(result, tuple):
            ok = bool(result[0])
            reason = str(result[1] if len(result) > 1 else "")
        else:
            ok = bool(result)
            reason = ""
        if not ok:
            raise RuntimeError(f"Falha ao conectar na IQ Option. {reason}".strip())

        client.change_balance(self.config.balance_mode)
        self.client = client

    def scan(self, min_payout_percent: float, include_otc: bool) -> list[dict[str, Any]]:
        self.connect()
        assert self.client is not None
        all_profit = dict(self.client.get_all_profit() or {})
        rows: list[dict[str, Any]] = []

        for symbol, profit_data in all_profit.items():
            normalized_symbol = str(symbol).upper()
            if not include_otc and normalized_symbol.endswith("-OTC"):
                continue

            turbo = self._to_percent((profit_data or {}).get("turbo"))
            binary = self._to_percent((profit_data or {}).get("binary"))
            best = max(turbo, binary)
            if best < min_payout_percent:
                continue

            if binary >= turbo:
                best_kind = "BINARY"
            else:
                best_kind = "TURBO"

            rows.append(
                {
                    "symbol": normalized_symbol,
                    "turbo": turbo,
                    "binary": binary,
                    "best": best,
                    "best_kind": best_kind,
                }
            )

        rows.sort(key=lambda item: (-float(item["best"]), item["symbol"]))
        return rows

    def _to_percent(self, value: Any) -> float:
        if value is None:
            return 0.0
        try:
            return round(float(value) * 100.0, 2)
        except Exception:
            return 0.0


class App(tk.Tk):
    def __init__(self, scanner: IQPayoutScanner, config: AppConfig) -> None:
        super().__init__()
        self.scanner = scanner
        self.config_model = config

        self.title("IQ Payout Scanner")
        self.geometry("980x700")
        self.minsize(860, 620)
        self.configure(bg="#101820")

        self.status_var = tk.StringVar(value="Pronto para buscar payouts.")
        self.updated_var = tk.StringVar(value="-")
        self.balance_mode_var = tk.StringVar(value=config.balance_mode)
        self.min_payout_var = tk.StringVar(value=f"{config.min_payout_percent:.0f}")
        self.otc_var = tk.BooleanVar(value=config.use_otc_symbols)

        self._configure_style()
        self._build_layout()

    def _configure_style(self) -> None:
        style = ttk.Style(self)
        try:
            style.theme_use("clam")
        except tk.TclError:
            pass
        style.configure("Root.TFrame", background="#101820")
        style.configure("Card.TFrame", background="#142235")
        style.configure("Head.TLabel", background="#142235", foreground="#f3f7fb", font=("Segoe UI", 24, "bold"))
        style.configure("Body.TLabel", background="#142235", foreground="#d1d9e4", font=("Segoe UI", 10))
        style.configure("MetricValue.TLabel", background="#142235", foreground="#f3f7fb", font=("Segoe UI", 18, "bold"))
        style.configure("MetricLabel.TLabel", background="#142235", foreground="#8ea3bb", font=("Segoe UI", 9))
        style.configure("Treeview", rowheight=28, font=("Consolas", 10))
        style.configure("Treeview.Heading", font=("Segoe UI", 9, "bold"))

    def _build_layout(self) -> None:
        root = ttk.Frame(self, style="Root.TFrame", padding=14)
        root.pack(fill="both", expand=True)
        root.columnconfigure(0, weight=1)
        root.rowconfigure(2, weight=1)

        header = ttk.Frame(root, style="Card.TFrame", padding=18)
        header.grid(row=0, column=0, sticky="ew")
        header.columnconfigure(0, weight=1)
        ttk.Label(header, text="IQ Payout Scanner", style="Head.TLabel").grid(row=0, column=0, sticky="w")
        ttk.Label(header, textvariable=self.status_var, style="Body.TLabel").grid(row=1, column=0, sticky="w", pady=(6, 0))
        ttk.Label(header, textvariable=self.updated_var, style="Body.TLabel").grid(row=1, column=1, sticky="e")

        top = ttk.Frame(root, style="Root.TFrame")
        top.grid(row=1, column=0, sticky="ew", pady=(12, 12))
        top.columnconfigure(0, weight=0)
        top.columnconfigure(1, weight=1)

        controls = ttk.Frame(top, style="Card.TFrame", padding=16)
        controls.grid(row=0, column=0, sticky="nsw", padx=(0, 10))
        controls.columnconfigure(0, weight=1)

        ttk.Label(controls, text="Controles", style="Head.TLabel").grid(row=0, column=0, sticky="w", pady=(0, 12))
        ttk.Label(controls, text="Conta", style="Body.TLabel").grid(row=1, column=0, sticky="w", pady=(0, 4))
        balance_combo = ttk.Combobox(controls, textvariable=self.balance_mode_var, state="readonly", values=("PRACTICE", "REAL"))
        balance_combo.grid(row=2, column=0, sticky="ew", pady=(0, 10))
        balance_combo.bind("<<ComboboxSelected>>", lambda _event: self._persist_config())

        ttk.Label(controls, text="Payout minimo (%)", style="Body.TLabel").grid(row=3, column=0, sticky="w", pady=(0, 4))
        payout_entry = ttk.Entry(controls, textvariable=self.min_payout_var)
        payout_entry.grid(row=4, column=0, sticky="ew", pady=(0, 10))

        ttk.Checkbutton(
            controls,
            text="Incluir OTC",
            variable=self.otc_var,
            command=self._persist_config,
        ).grid(row=5, column=0, sticky="w", pady=(0, 12))

        ttk.Button(controls, text="Buscar payouts", command=self._scan_in_background).grid(row=6, column=0, sticky="ew", pady=4)
        ttk.Button(controls, text="Salvar config", command=self._persist_config).grid(row=7, column=0, sticky="ew", pady=4)

        help_card = ttk.Frame(top, style="Card.TFrame", padding=16)
        help_card.grid(row=0, column=1, sticky="nsew")
        help_card.columnconfigure(0, weight=1)
        ttk.Label(help_card, text="Escopo", style="Head.TLabel").grid(row=0, column=0, sticky="w", pady=(0, 12))
        self.help_text = tk.Text(help_card, wrap="word", height=8, bg="#142235", fg="#d1d9e4", bd=0, highlightthickness=0)
        self.help_text.grid(row=1, column=0, sticky="nsew")
        self._replace_text(
            self.help_text,
            "Este script apenas conecta na IQ Option e lista ativos com payout acima do minimo definido.\n"
            "Nao envia ordens.\n"
            "Nao integra com MT5.\n"
            "A conexao com MT5 fica para a proxima etapa.",
        )

        table_frame = ttk.Frame(root, style="Card.TFrame", padding=14)
        table_frame.grid(row=2, column=0, sticky="nsew")
        table_frame.columnconfigure(0, weight=1)
        table_frame.rowconfigure(0, weight=1)

        columns = ("symbol", "turbo", "binary", "best", "kind")
        self.tree = ttk.Treeview(table_frame, columns=columns, show="headings")
        headings = {
            "symbol": "Ativo",
            "turbo": "Turbo %",
            "binary": "Binary %",
            "best": "Melhor %",
            "kind": "Melhor tipo",
        }
        widths = {
            "symbol": 220,
            "turbo": 140,
            "binary": 140,
            "best": 140,
            "kind": 160,
        }
        for column in columns:
            self.tree.heading(column, text=headings[column])
            self.tree.column(column, width=widths[column], anchor="w", stretch=True)
        self.tree.grid(row=0, column=0, sticky="nsew")

        scrollbar = ttk.Scrollbar(table_frame, orient="vertical", command=self.tree.yview)
        scrollbar.grid(row=0, column=1, sticky="ns")
        self.tree.configure(yscrollcommand=scrollbar.set)

    def _scan_in_background(self) -> None:
        try:
            min_payout = float(self.min_payout_var.get().replace(",", "."))
        except ValueError:
            messagebox.showerror("IQ Payout Scanner", "Payout minimo invalido.")
            return

        self.status_var.set("Buscando payouts na IQ Option...")
        self._persist_config(show_message=False)

        def worker() -> None:
            try:
                rows = self.scanner.scan(min_payout, self.otc_var.get())
            except Exception as exc:
                self.after(0, lambda: messagebox.showerror("IQ Payout Scanner", str(exc)))
                self.after(0, lambda: self.status_var.set(f"Falha: {exc}"))
                return

            def apply() -> None:
                for item in self.tree.get_children():
                    self.tree.delete(item)
                for row in rows:
                    self.tree.insert(
                        "",
                        "end",
                        values=(
                            row["symbol"],
                            f"{row['turbo']:.2f}",
                            f"{row['binary']:.2f}",
                            f"{row['best']:.2f}",
                            row["best_kind"],
                        ),
                    )
                self.updated_var.set(f"Ultima leitura: {time.strftime('%Y-%m-%d %H:%M:%S')}")
                self.status_var.set(f"{len(rows)} ativo(s) encontrados com payout >= {min_payout:.2f}%.")

            self.after(0, apply)

        threading.Thread(target=worker, daemon=True).start()

    def _persist_config(self, show_message: bool = False) -> None:
        try:
            min_payout = float(self.min_payout_var.get().replace(",", "."))
        except ValueError:
            if show_message:
                messagebox.showerror("IQ Payout Scanner", "Payout minimo invalido.")
            return

        self.config_model.balance_mode = self.balance_mode_var.get().upper().strip() or "PRACTICE"
        self.config_model.min_payout_percent = min_payout
        self.config_model.use_otc_symbols = bool(self.otc_var.get())
        save_config(CONFIG_PATH, self.config_model)
        self.scanner.config = self.config_model
        if self.scanner.client is not None:
            try:
                self.scanner.client.change_balance(self.config_model.balance_mode)
            except Exception:
                self.scanner.client = None
        if show_message:
            messagebox.showinfo("IQ Payout Scanner", "Config salva.")

    def _replace_text(self, widget: tk.Text, value: str) -> None:
        widget.configure(state="normal")
        widget.delete("1.0", "end")
        widget.insert("1.0", value)
        widget.configure(state="disabled")


def main() -> None:
    config = load_config(CONFIG_PATH)
    if not config.email or not config.password:
        raise SystemExit("Preencha email e password em config.json.")

    app = App(IQPayoutScanner(config), config)
    app.mainloop()


if __name__ == "__main__":
    main()
