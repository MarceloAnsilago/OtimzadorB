from __future__ import annotations

import importlib
import queue
import threading
import time
from pathlib import Path
from typing import Any

import customtkinter as ctk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
from tkinter import messagebox

try:
    import bridge as bridge_module
except ModuleNotFoundError:  # pragma: no cover
    from OpBinBridge import bridge as bridge_module

bridge_module = importlib.reload(bridge_module)
CONFIG_PATH = bridge_module.CONFIG_PATH
IQOptionBridge = bridge_module.IQOptionBridge
ensure_runtime_dirs = bridge_module.ensure_runtime_dirs
load_config = bridge_module.load_config
setup_logging = bridge_module.setup_logging

HISTORY_LIMIT = 180
LOG_TAIL_LINES = 50


def load_bridge() -> tuple[IQOptionBridge | None, str | None]:
    try:
        config = load_config(CONFIG_PATH)
        ensure_runtime_dirs(config)
        return IQOptionBridge(config), None
    except Exception as exc:
        return None, str(exc)


class AssetCard(ctk.CTkFrame):
    def __init__(self, master: Any, symbol: str) -> None:
        super().__init__(master, corner_radius=16, fg_color="#121826")
        self.symbol = symbol

        self.grid_columnconfigure((0, 1, 2, 3), weight=1)

        self.title_label = ctk.CTkLabel(self, text=symbol, font=ctk.CTkFont(size=20, weight="bold"))
        self.title_label.grid(row=0, column=0, sticky="w", padx=16, pady=(14, 4))

        self.meta_label = ctk.CTkLabel(self, text="", text_color="#8fa3bf")
        self.meta_label.grid(row=0, column=1, columnspan=3, sticky="e", padx=16, pady=(14, 4))

        self.setup_label = ctk.CTkLabel(self, text="", text_color="#9bb0cf")
        self.setup_label.grid(row=1, column=0, columnspan=4, sticky="w", padx=16, pady=(0, 6))

        self.strategy_label = ctk.CTkLabel(self, text="", text_color="#f0c66e", justify="left")
        self.strategy_label.grid(row=2, column=0, columnspan=4, sticky="w", padx=16, pady=(0, 6))

        self.signal_label = ctk.CTkLabel(self, text="", text_color="#8fa3bf")
        self.signal_label.grid(row=3, column=0, columnspan=4, sticky="w", padx=16, pady=(0, 8))

        self.mt5_label = ctk.CTkLabel(self, text="MT5: -", font=ctk.CTkFont(size=15, weight="bold"))
        self.mt5_label.grid(row=4, column=0, sticky="w", padx=16)

        self.iq_label = ctk.CTkLabel(self, text="IQ: -", font=ctk.CTkFont(size=15, weight="bold"))
        self.iq_label.grid(row=4, column=1, sticky="w", padx=16)

        self.diff_label = ctk.CTkLabel(self, text="Dif.: -", text_color="#c9d5e6")
        self.diff_label.grid(row=4, column=2, sticky="w", padx=16)

        self.score_label = ctk.CTkLabel(self, text="Semelhanca: -", text_color="#c9d5e6")
        self.score_label.grid(row=4, column=3, sticky="w", padx=16)

        self.progress = ctk.CTkProgressBar(self, height=14, corner_radius=8, progress_color="#2fbf71")
        self.progress.grid(row=5, column=0, columnspan=4, sticky="ew", padx=16, pady=(10, 6))
        self.progress.set(0.0)

        self.progress_text = ctk.CTkLabel(self, text="Sem leitura", text_color="#8fa3bf")
        self.progress_text.grid(row=6, column=0, columnspan=2, sticky="w", padx=16)

        self.error_label = ctk.CTkLabel(self, text="", text_color="#ff7a7a")
        self.error_label.grid(row=6, column=2, columnspan=2, sticky="e", padx=16)

        self.figure = Figure(figsize=(7.2, 2.3), dpi=100, facecolor="#121826")
        self.ax_price = self.figure.add_subplot(111)
        self.ax_score = self.ax_price.twinx()
        self.figure.subplots_adjust(left=0.06, right=0.99, top=0.92, bottom=0.22)
        self._style_axes()
        self.canvas = FigureCanvasTkAgg(self.figure, master=self)
        self.canvas.get_tk_widget().grid(row=7, column=0, columnspan=4, sticky="nsew", padx=10, pady=(10, 14))

    def _style_axes(self) -> None:
        self.ax_price.clear()
        self.ax_score.clear()
        self.ax_price.set_facecolor("#0e1420")
        self.ax_price.tick_params(colors="#91a4c2", labelsize=8)
        for spine in self.ax_price.spines.values():
            spine.set_color("#243247")
        self.ax_price.grid(color="#243247", alpha=0.4, linewidth=0.6)
        self.ax_score.set_facecolor("none")
        self.ax_score.set_ylim(0, 100)
        self.ax_score.tick_params(colors="#91a4c2", labelsize=8)
        for spine in self.ax_score.spines.values():
            spine.set_visible(False)

    def set_tab_title(self, title: str) -> None:
        self.title_label.configure(text=title)

    def update_card(self, row: dict[str, Any], history: list[dict[str, Any]], signal_stats: dict[str, int]) -> None:
        self.meta_label.configure(
            text=f"{row.get('strategy', '')} | {row.get('timeframe', '')} | MT5 {row.get('mt5_timestamp_text', '')}"
        )
        self.setup_label.configure(
            text=(
                f"Aporte {row.get('ea_tipo_aporte', '')} | Valor {float(row.get('ea_valor_aporte') or 0.0):.2f} | "
                f"Hint {float(row.get('ea_amount_hint') or 0.0):.2f} | MG {int(row.get('ea_max_martingale') or 0)} | "
                f"Modo MG {row.get('ea_entrar_martingale', '')} | Exp {int(row.get('ea_bridge_expiration_minutes') or 0)}m | "
                f"Payout {float(row.get('ea_payout_hint') or 0.0):.2f}%"
            )
        )
        self.strategy_label.configure(
            text=(
                f"Ops {int(row.get('ea_total_operacoes') or 0)} | Entradas {int(row.get('ea_total_entradas_executadas') or 0)} | "
                f"Wins {int(row.get('ea_total_wins') or 0)} | Losses {int(row.get('ea_total_losses') or 0)} | "
                f"Winrate {float(row.get('ea_winrate_pct') or 0.0):.2f}% | "
                f"G0 {int(row.get('ea_win_g0') or 0)} G1 {int(row.get('ea_win_g1') or 0)} "
                f"G2 {int(row.get('ea_win_g2') or 0)} G3 {int(row.get('ea_win_g3') or 0)}\n"
                f"Banca {float(row.get('ea_banca_inicial') or 0.0):.2f} -> {float(row.get('ea_banca_final') or 0.0):.2f} | "
                f"Lucro {float(row.get('ea_lucro_total') or 0.0):.2f} | Maior gale {float(row.get('ea_maior_gale') or 0.0):.2f} | "
                f"DD {float(row.get('ea_max_drawdown') or 0.0):.2f} ({float(row.get('ea_max_drawdown_pct') or 0.0):.2f}%) | "
                f"1a quebra {int(row.get('ea_primeira_quebra_apos_entradas') or 0)} | "
                f"Media/sem {float(row.get('ea_media_entradas_semana') or 0.0):.2f} | "
                f"Score {float(row.get('ea_score_otimizacao') or 0.0):.4f}"
            )
        )
        self.signal_label.configure(
            text=(
                f"Sinais: recebidos {signal_stats.get('received', 0)} | enviados {signal_stats.get('sent', 0)} | "
                f"dry {signal_stats.get('dry_run', 0)} | falhas {signal_stats.get('failed', 0)} | pendentes {signal_stats.get('pending', 0)}"
            )
        )
        self.mt5_label.configure(text=f"MT5: {float(row.get('mt5_quote') or 0.0):.5f}")
        iq_value = row.get("iq_close")
        self.iq_label.configure(text=f"IQ: {float(iq_value):.5f}" if iq_value is not None else "IQ: -")
        self.diff_label.configure(
            text=f"Dif.: {float(row.get('diff_points') or 0.0):.2f} pts | {float(row.get('diff_pct') or 0.0):.4f}%"
        )
        score = float(row.get("similarity_score") or 0.0)
        self.score_label.configure(text=f"Semelhanca: {score:.2f}%")
        self.progress.set(min(max(score / 100.0, 0.0), 1.0))
        self.progress_text.configure(text=f"Nivel: {row.get('similarity_label', 'Indefinida')}")

        iq_error = str(row.get("iq_error") or "")
        self.error_label.configure(text=f"IQ error: {iq_error}" if iq_error else "")
        if score >= 90:
            self.progress.configure(progress_color="#28c76f")
        elif score >= 70:
            self.progress.configure(progress_color="#f5b700")
        else:
            self.progress.configure(progress_color="#ef5350")

        self._draw_history(history)

    def _draw_history(self, history: list[dict[str, Any]]) -> None:
        self._style_axes()
        if not history:
            self.ax_price.text(0.5, 0.5, "Sem historico", ha="center", va="center", color="#91a4c2")
            self.canvas.draw_idle()
            return

        tail = history[-60:]
        x_values = list(range(len(tail)))
        mt5_values = [float(item.get("mt5_quote") or 0.0) for item in tail]
        iq_values = [float(item.get("iq_close") or 0.0) if item.get("iq_close") is not None else None for item in tail]
        similarity_values = [float(item.get("similarity_score") or 0.0) for item in tail]

        self.ax_price.plot(x_values, mt5_values, color="#4cc9f0", linewidth=1.7, label="MT5")
        if any(value is not None for value in iq_values):
            iq_plot_values = [value if value is not None else float("nan") for value in iq_values]
            self.ax_price.plot(x_values, iq_plot_values, color="#f72585", linewidth=1.5, label="IQ")

        if mt5_values:
            ymin = min(mt5_values + [value for value in iq_values if value is not None])
            ymax = max(mt5_values + [value for value in iq_values if value is not None])
            padding = max((ymax - ymin) * 0.25, 0.00002)
            self.ax_price.set_ylim(ymin - padding, ymax + padding)

        self.ax_price.legend(loc="upper left", facecolor="#0e1420", edgecolor="#243247", labelcolor="#c9d5e6", fontsize=8)
        self.ax_price.set_title("Cotacao MT5 x IQ", color="#dce7f5", fontsize=10, loc="left")

        self.ax_score.plot(x_values, similarity_values, color="#ffd166", linewidth=1.0, alpha=0.75, linestyle="--")

        if len(x_values) > 1:
            tick_positions = [0, len(x_values) // 2, len(x_values) - 1]
            tick_labels = [tail[pos].get("sample_time", "") for pos in tick_positions]
            self.ax_price.set_xticks(tick_positions, tick_labels)
        self.canvas.draw_idle()


class OpBinBridgeApp(ctk.CTk):
    def __init__(self) -> None:
        super().__init__()
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")

        self.title("OpBinBridge")
        self.geometry("1440x940")
        self.minsize(1220, 860)
        self.configure(fg_color="#0b1220")

        setup_logging()
        bridge, error = load_bridge()
        if error or bridge is None:
            messagebox.showerror("OpBinBridge", error or "Falha ao carregar a bridge.")
            raise SystemExit(1)

        self.bridge = bridge
        self.history: dict[str, list[dict[str, Any]]] = {}
        self.cards: dict[str, AssetCard] = {}
        self.card_tabs: dict[str, str] = {}
        self.task_queue: queue.Queue[tuple[str, Any]] = queue.Queue()
        self.fetch_in_flight = False
        self.last_refresh_epoch = 0.0

        self.auto_refresh_var = ctk.BooleanVar(value=True)
        self.refresh_seconds_var = ctk.IntVar(value=1)
        self.dry_run_switch_var = ctk.BooleanVar(value=self.bridge.config.dry_run)
        self.otc_switch_var = ctk.BooleanVar(value=self.bridge.config.use_otc_symbols)
        self.status_message_var = ctk.StringVar(value="Pronto.")
        self.last_refresh_var = ctk.StringVar(value="Sem leitura ainda.")
        self.balance_mode_var = ctk.StringVar(value=self.bridge.config.balance_mode.upper())
        self.mode_value_var = ctk.StringVar(value=self.bridge.config.balance_mode.upper())
        self.dry_run_value_var = ctk.StringVar(value="Sim" if self.bridge.config.dry_run else "Nao")
        self.otc_value_var = ctk.StringVar(value="Sim" if self.bridge.config.use_otc_symbols else "Nao")
        self.account_value_var = ctk.StringVar(
            value="Simulada" if self.bridge.config.balance_mode.upper() == "PRACTICE" else "Real"
        )
        self.iq_balance_var = ctk.StringVar(value="-")
        self.iq_currency_var = ctk.StringVar(value="-")
        self.multiplier_percent_var = ctk.StringVar(value="5")
        self.multiplier_result_var = ctk.StringVar(value="-")
        self.total_signals_var = ctk.StringVar(value="0")
        self.total_sent_var = ctk.StringVar(value="0")
        self.readiness_title_var = ctk.StringVar(value="Prontidao: verificando")
        self.readiness_body_var = ctk.StringVar(value="Aguardando primeira leitura.")

        self._build_layout()
        self._recalculate_multiplier()
        self._start_periodic_tasks()
        self._start_fetch(force=True)

    def _build_layout(self) -> None:
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(2, weight=1)

        header = ctk.CTkFrame(self, corner_radius=18, fg_color="#111a2c")
        header.grid(row=0, column=0, sticky="ew", padx=18, pady=(18, 12))
        header.grid_columnconfigure(0, weight=1)
        ctk.CTkLabel(header, text="OpBinBridge", font=ctk.CTkFont(size=28, weight="bold")).grid(
            row=0, column=0, sticky="w", padx=18, pady=(16, 4)
        )
        ctk.CTkLabel(
            header,
            text="Monitor nativo entre MT5 e IQ Option com atualizacao continua, historico curto e semelhança em tempo real.",
            text_color="#9bb0cf",
        ).grid(row=1, column=0, sticky="w", padx=18, pady=(0, 16))

        top = ctk.CTkFrame(self, corner_radius=18, fg_color="#10192a")
        top.grid(row=1, column=0, sticky="ew", padx=18, pady=(0, 12))
        top.grid_columnconfigure(0, weight=1)
        top.grid_columnconfigure(1, weight=0)

        self._build_summary(top)
        self._build_controls(top)

        body = ctk.CTkFrame(self, corner_radius=18, fg_color="transparent")
        body.grid(row=2, column=0, sticky="nsew", padx=18, pady=(0, 18))
        body.grid_columnconfigure(0, weight=3)
        body.grid_columnconfigure(1, weight=1)
        body.grid_rowconfigure(0, weight=1)

        self.asset_panel = ctk.CTkFrame(body, corner_radius=18, fg_color="#10192a")
        self.asset_panel.grid(row=0, column=0, sticky="nsew", padx=(0, 10))
        self.asset_panel.grid_columnconfigure(0, weight=1)
        self.asset_panel.grid_rowconfigure(1, weight=1)
        ctk.CTkLabel(self.asset_panel, text="EAs Operando", font=ctk.CTkFont(size=18, weight="bold")).grid(
            row=0, column=0, sticky="w", padx=16, pady=(14, 8)
        )
        self.asset_tabs = ctk.CTkTabview(self.asset_panel, corner_radius=14, fg_color="#10192a", segmented_button_fg_color="#162238")
        self.asset_tabs.grid(row=1, column=0, sticky="nsew", padx=12, pady=(0, 12))

        side = ctk.CTkFrame(body, corner_radius=18, fg_color="#10192a")
        side.grid(row=0, column=1, sticky="nsew")
        side.grid_columnconfigure(0, weight=1)
        side.grid_rowconfigure(2, weight=1)

        self.monitor_box = ctk.CTkFrame(side, corner_radius=14, fg_color="#121d31", height=120)
        self.monitor_box.grid(row=0, column=0, sticky="ew", padx=14, pady=14)
        self.monitor_box.grid_columnconfigure((0, 1), weight=1)
        self.monitor_box.grid_propagate(False)
        ctk.CTkLabel(self.monitor_box, text="Monitor", font=ctk.CTkFont(size=18, weight="bold")).grid(
            row=0, column=0, columnspan=2, sticky="w", padx=14, pady=(14, 10)
        )
        ctk.CTkLabel(self.monitor_box, textvariable=self.status_message_var, justify="left", wraplength=280).grid(
            row=1, column=0, columnspan=2, sticky="w", padx=14, pady=(0, 8)
        )
        ctk.CTkLabel(self.monitor_box, textvariable=self.last_refresh_var, text_color="#8fa3bf").grid(
            row=2, column=0, columnspan=2, sticky="w", padx=14, pady=(0, 14)
        )

        self.readiness_box = ctk.CTkFrame(side, corner_radius=14, fg_color="#121d31")
        self.readiness_box.grid(row=1, column=0, sticky="ew", padx=14, pady=(0, 14))
        self.readiness_box.grid_columnconfigure(0, weight=1)
        ctk.CTkLabel(self.readiness_box, text="Prontidao Operacional", font=ctk.CTkFont(size=18, weight="bold")).grid(
            row=0, column=0, sticky="w", padx=14, pady=(14, 8)
        )
        self.readiness_title = ctk.CTkLabel(
            self.readiness_box, textvariable=self.readiness_title_var, font=ctk.CTkFont(size=16, weight="bold")
        )
        self.readiness_title.grid(row=1, column=0, sticky="w", padx=14)
        ctk.CTkLabel(
            self.readiness_box,
            textvariable=self.readiness_body_var,
            justify="left",
            wraplength=290,
            text_color="#c9d5e6",
        ).grid(row=2, column=0, sticky="w", padx=14, pady=(4, 14))

        self.log_box = ctk.CTkTextbox(side, corner_radius=14, fg_color="#121d31", wrap="word")
        self.log_box.grid(row=2, column=0, sticky="nsew", padx=14, pady=(0, 14))
        self.log_box.insert("1.0", "Aguardando log...")
        self.log_box.configure(state="disabled")

    def _build_summary(self, parent: ctk.CTkFrame) -> None:
        summary = ctk.CTkFrame(parent, fg_color="#10192a")
        summary.grid(row=0, column=0, sticky="nsew", padx=(0, 12), pady=14)
        summary.grid_columnconfigure((0, 1, 2, 3, 4, 5, 6), weight=1)

        mode_text = self.bridge.config.balance_mode.upper()
        dry_run_text = "Sim" if self.bridge.config.dry_run else "Nao"
        account_text = "Simulada" if mode_text == "PRACTICE" else "Real"

        self._metric(summary, 0, "Modo", self.mode_value_var)
        self._metric(summary, 1, "Dry run", self.dry_run_value_var)
        self._metric(summary, 2, "Conta", self.account_value_var)
        self._metric(summary, 3, "Banca IQ", self.iq_balance_var)
        self._metric(summary, 4, "Sinais Recebidos", self.total_signals_var)
        self._metric(summary, 5, "Sinais Enviados", self.total_sent_var)
        self._metric(summary, 6, "Operar OTC", self.otc_value_var)

        status_path = getattr(self.bridge.config, "status_path", self.bridge.config.bridge_root_path / "status")
        details = [
            ("Email", self.bridge.config.email),
            ("Inbox MT5", str(self.bridge.config.inbox_path)),
            ("Status MT5", str(status_path)),
            ("URL IQ Option", self.bridge.config.browser_url),
        ]
        for index, (label, value) in enumerate(details, start=1):
            ctk.CTkLabel(summary, text=label, text_color="#8fa3bf").grid(
                row=index * 2, column=0, columnspan=7, sticky="w", padx=16, pady=(8, 0)
            )
            entry = ctk.CTkEntry(summary, fg_color="#162238", border_width=0)
            entry.grid(row=index * 2 + 1, column=0, columnspan=7, sticky="ew", padx=16, pady=(4, 0))
            entry.insert(0, value)
            entry.configure(state="disabled")

        calc_row = 11
        ctk.CTkLabel(summary, text="Calculadora Percentual da Banca", font=ctk.CTkFont(size=16, weight="bold")).grid(
            row=calc_row, column=0, columnspan=7, sticky="w", padx=16, pady=(12, 4)
        )
        ctk.CTkLabel(summary, text="Moeda").grid(row=calc_row + 1, column=0, sticky="w", padx=16)
        ctk.CTkLabel(summary, textvariable=self.iq_currency_var, text_color="#9bb0cf").grid(
            row=calc_row + 1, column=1, sticky="w"
        )
        ctk.CTkLabel(summary, text="Multiplicador (%)").grid(row=calc_row + 1, column=2, sticky="w", padx=(16, 0))
        multiplier_entry = ctk.CTkEntry(summary, textvariable=self.multiplier_percent_var, width=100)
        multiplier_entry.grid(row=calc_row + 1, column=3, sticky="ew", padx=(0, 8))
        multiplier_entry.bind("<KeyRelease>", lambda _event: self._recalculate_multiplier())
        ctk.CTkLabel(summary, text="Resultado").grid(row=calc_row + 1, column=4, sticky="w", padx=(16, 0))
        ctk.CTkLabel(summary, textvariable=self.multiplier_result_var, font=ctk.CTkFont(size=16, weight="bold")).grid(
            row=calc_row + 1, column=5, sticky="w"
        )

    def _build_controls(self, parent: ctk.CTkFrame) -> None:
        controls = ctk.CTkFrame(parent, corner_radius=14, fg_color="#121d31")
        controls.grid(row=0, column=1, sticky="ns", pady=14)
        controls.grid_columnconfigure(0, weight=1)

        ctk.CTkLabel(controls, text="Controles", font=ctk.CTkFont(size=18, weight="bold")).grid(
            row=0, column=0, sticky="w", padx=16, pady=(16, 10)
        )

        mode_row = ctk.CTkFrame(controls, fg_color="transparent")
        mode_row.grid(row=1, column=0, sticky="ew", padx=16, pady=(0, 10))
        mode_row.grid_columnconfigure(1, weight=1)
        ctk.CTkLabel(mode_row, text="Conta IQ").grid(row=0, column=0, sticky="w")
        self.balance_mode_menu = ctk.CTkOptionMenu(
            mode_row,
            values=["PRACTICE", "REAL"],
            variable=self.balance_mode_var,
            command=self._change_balance_mode,
        )
        self.balance_mode_menu.grid(row=0, column=1, sticky="e")

        ctk.CTkButton(controls, text="Fazer conexao", command=self._connect_action).grid(
            row=2, column=0, sticky="ew", padx=16, pady=6
        )
        ctk.CTkButton(controls, text="Abrir IQ Option", command=self._open_browser_action).grid(
            row=3, column=0, sticky="ew", padx=16, pady=6
        )
        ctk.CTkButton(controls, text="Processar sinais pendentes", command=self._process_signals_action).grid(
            row=4, column=0, sticky="ew", padx=16, pady=6
        )
        ctk.CTkButton(controls, text="Atualizar agora", command=lambda: self._start_fetch(force=True)).grid(
            row=5, column=0, sticky="ew", padx=16, pady=6
        )

        self.auto_switch = ctk.CTkSwitch(
            controls,
            text="Atualizar automaticamente",
            variable=self.auto_refresh_var,
            onvalue=True,
            offvalue=False,
        )
        self.auto_switch.grid(row=6, column=0, sticky="w", padx=16, pady=(12, 6))

        self.dry_run_switch = ctk.CTkSwitch(
            controls,
            text="Dry run / sem enviar ordem",
            variable=self.dry_run_switch_var,
            onvalue=True,
            offvalue=False,
            command=self._toggle_dry_run,
        )
        self.dry_run_switch.grid(row=7, column=0, sticky="w", padx=16, pady=(0, 6))

        self.otc_switch = ctk.CTkSwitch(
            controls,
            text="Operar em OTC",
            variable=self.otc_switch_var,
            onvalue=True,
            offvalue=False,
            command=self._toggle_otc_mode,
        )
        self.otc_switch.grid(row=8, column=0, sticky="w", padx=16, pady=(0, 6))

        interval_row = ctk.CTkFrame(controls, fg_color="transparent")
        interval_row.grid(row=9, column=0, sticky="ew", padx=16, pady=(4, 16))
        interval_row.grid_columnconfigure(1, weight=1)
        ctk.CTkLabel(interval_row, text="Intervalo (s)").grid(row=0, column=0, sticky="w")
        interval_menu = ctk.CTkOptionMenu(
            interval_row,
            values=[str(item) for item in range(1, 11)],
            variable=ctk.StringVar(value=str(self.refresh_seconds_var.get())),
            command=self._set_refresh_seconds,
        )
        interval_menu.grid(row=0, column=1, sticky="e")

    def _metric(self, parent: ctk.CTkFrame, column: int, label: str, value: ctk.StringVar) -> None:
        box = ctk.CTkFrame(parent, corner_radius=14, fg_color="#121d31")
        box.grid(row=0, column=column, sticky="ew", padx=8, pady=(0, 6))
        ctk.CTkLabel(box, text=label, text_color="#8fa3bf").pack(anchor="w", padx=14, pady=(12, 4))
        ctk.CTkLabel(box, textvariable=value, font=ctk.CTkFont(size=20, weight="bold")).pack(anchor="w", padx=14, pady=(0, 12))

    def _set_refresh_seconds(self, value: str) -> None:
        self.refresh_seconds_var.set(max(int(value), 1))

    def _recalculate_multiplier(self) -> None:
        try:
            percent = float(str(self.multiplier_percent_var.get()).replace(",", "."))
            balance_text = self.iq_balance_var.get().split(" ")[0]
            balance = float(balance_text.replace(",", ".")) if balance_text not in {"-", ""} else 0.0
            result = balance * (percent / 100.0)
            currency = self.iq_currency_var.get() if self.iq_currency_var.get() != "-" else ""
            self.multiplier_result_var.set(f"{result:.2f} {currency}".strip())
        except Exception:
            self.multiplier_result_var.set("-")

    def _change_balance_mode(self, value: str) -> None:
        selected = value.upper().strip()
        previous = self.bridge.config.balance_mode.upper()

        def job() -> tuple[str, str, str]:
            self.bridge.set_balance_mode(selected, persist=True)
            return "success", f"Modo da conta alterado para {selected}.", selected

        def runner() -> None:
            try:
                self.task_queue.put(("balance_mode", job()))
            except Exception as exc:
                self.task_queue.put(("balance_mode_error", (previous, str(exc))))

        threading.Thread(target=runner, daemon=True).start()

    def _toggle_dry_run(self) -> None:
        selected = bool(self.dry_run_switch_var.get())

        def runner() -> None:
            try:
                self.bridge.set_dry_run(selected, persist=True)
                self.task_queue.put(("dry_run", selected))
            except Exception as exc:
                self.task_queue.put(("dry_run_error", (not selected, str(exc))))

        threading.Thread(target=runner, daemon=True).start()

    def _toggle_otc_mode(self) -> None:
        selected = bool(self.otc_switch_var.get())

        def runner() -> None:
            try:
                self.bridge.set_use_otc_symbols(selected, persist=True)
                self.task_queue.put(("otc_mode", selected))
            except Exception as exc:
                self.task_queue.put(("otc_mode_error", (not selected, str(exc))))

        threading.Thread(target=runner, daemon=True).start()

    def _connect_action(self) -> None:
        def job() -> tuple[str, str]:
            self.bridge.ensure_connection()
            if self.bridge.config.dry_run:
                return "info", "Dry run ativo. Nao foi necessario conectar na IQ Option."
            return "success", "Conexao com a IQ Option estabelecida."

        self._run_background_action(job)

    def _open_browser_action(self) -> None:
        def job() -> tuple[str, str]:
            return (
                ("success", "Pagina da IQ Option aberta no navegador.")
                if self.bridge.open_browser()
                else ("warning", "Nao foi possivel abrir automaticamente. Verifique o navegador padrao.")
            )

        self._run_background_action(job)

    def _process_signals_action(self) -> None:
        def job() -> tuple[str, str]:
            self.bridge.process_pending_signals()
            return "success", "Leitura da inbox concluida."

        self._run_background_action(job)

    def _run_background_action(self, func: Any) -> None:
        def runner() -> None:
            try:
                self.task_queue.put(("message", func()))
            except Exception as exc:
                self.task_queue.put(("message", ("error", str(exc))))

        threading.Thread(target=runner, daemon=True).start()

    def _start_periodic_tasks(self) -> None:
        self.after(250, self._poll_queue)
        self.after(250, self._scheduler_tick)

    def _scheduler_tick(self) -> None:
        if self.auto_refresh_var.get():
            interval = max(self.refresh_seconds_var.get(), 1)
            due = (time.time() - self.last_refresh_epoch) >= interval
            if due:
                self._start_fetch()
        self.after(250, self._scheduler_tick)

    def _start_fetch(self, force: bool = False) -> None:
        if self.fetch_in_flight:
            return
        if not force and not self.auto_refresh_var.get():
            return

        self.fetch_in_flight = True
        self.status_message_var.set("Atualizando cotacoes MT5 x IQ...")

        def worker() -> None:
            try:
                snapshot = self.bridge.get_dashboard_snapshot()
                self.task_queue.put(("dashboard", snapshot))
            except Exception as exc:
                self.task_queue.put(("fetch_error", str(exc)))

        threading.Thread(target=worker, daemon=True).start()

    def _poll_queue(self) -> None:
        while True:
            try:
                kind, payload = self.task_queue.get_nowait()
            except queue.Empty:
                break

            if kind == "dashboard":
                self.fetch_in_flight = False
                self._handle_dashboard(payload)
            elif kind == "fetch_error":
                self.fetch_in_flight = False
                self.status_message_var.set(f"Falha na leitura: {payload}")
            elif kind == "message":
                level, message = payload
                self.status_message_var.set(message)
                if level == "error":
                    messagebox.showerror("OpBinBridge", message)
            elif kind == "balance_mode":
                _, message, selected = payload
                self.mode_value_var.set(selected)
                self.account_value_var.set("Simulada" if selected == "PRACTICE" else "Real")
                self.status_message_var.set(message)
            elif kind == "balance_mode_error":
                previous, message = payload
                self.balance_mode_var.set(previous)
                self.status_message_var.set(f"Falha ao alterar modo: {message}")
                messagebox.showerror("OpBinBridge", message)
            elif kind == "dry_run":
                selected = bool(payload)
                self.dry_run_switch_var.set(selected)
                self.dry_run_value_var.set("Sim" if selected else "Nao")
                self.status_message_var.set("Dry run ativo." if selected else "Envio real habilitado na bridge.")
                self._refresh_readiness()
            elif kind == "dry_run_error":
                previous, message = payload
                self.dry_run_switch_var.set(bool(previous))
                self.status_message_var.set(f"Falha ao alterar dry run: {message}")
                messagebox.showerror("OpBinBridge", message)
            elif kind == "otc_mode":
                selected = bool(payload)
                self.otc_switch_var.set(selected)
                self.otc_value_var.set("Sim" if selected else "Nao")
                self.status_message_var.set("Modo OTC ativado." if selected else "Modo OTC desativado.")
                self._start_fetch(force=True)
            elif kind == "otc_mode_error":
                previous, message = payload
                self.otc_switch_var.set(bool(previous))
                self.status_message_var.set(f"Falha ao alterar modo OTC: {message}")
                messagebox.showerror("OpBinBridge", message)
        self.after(250, self._poll_queue)

    def _handle_dashboard(self, snapshot: dict[str, Any]) -> None:
        account = dict(snapshot.get("account") or {})
        comparisons = list(snapshot.get("comparisons") or [])
        readiness = dict(snapshot.get("readiness") or {})
        signal_stats = dict(snapshot.get("signal_stats") or {})

        self.last_refresh_epoch = time.time()
        self.last_refresh_var.set(
            "Ultima leitura: " + time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(self.last_refresh_epoch))
        )
        if account:
            balance = float(account.get("balance") or 0.0)
            currency = str(account.get("currency") or "")
            mode = str(account.get("balance_mode") or self.bridge.config.balance_mode).upper()
            self.iq_balance_var.set(f"{balance:.2f} {currency}".strip())
            self.iq_currency_var.set(currency or "-")
            self.mode_value_var.set(mode)
            self.account_value_var.set("Simulada" if mode == "PRACTICE" else "Real")
            self.balance_mode_var.set(mode)
            self._recalculate_multiplier()
        totals = dict(signal_stats.get("totals") or {})
        self.total_signals_var.set(str(int(totals.get("received", 0))))
        self.total_sent_var.set(str(int(totals.get("sent", 0))))
        self._append_history(comparisons)
        self._render_cards(comparisons, signal_stats)
        self._refresh_log()
        self._refresh_readiness(readiness)

        if comparisons:
            self.status_message_var.set(f"{len(comparisons)} ativo(s) monitorado(s).")
        else:
            self.status_message_var.set(
                "Nenhum ativo ativo encontrado no status do MT5. Deixe o robo rodando com a bridge ativa no grafico."
            )

    def _append_history(self, comparisons: list[dict[str, Any]]) -> None:
        now_text = time.strftime("%H:%M:%S", time.localtime(self.last_refresh_epoch))
        active_keys: set[str] = set()
        for row in comparisons:
            key = self._row_key(row)
            if not key:
                continue
            active_keys.add(key)
            samples = self.history.setdefault(key, [])
            samples.append(
                {
                    "sample_time": now_text,
                    "mt5_quote": row.get("mt5_quote"),
                    "iq_close": row.get("iq_close"),
                    "similarity_score": row.get("similarity_score"),
                    "diff_points": row.get("diff_points"),
                    "iq_error": row.get("iq_error", ""),
                }
            )
            if len(samples) > HISTORY_LIMIT:
                del samples[:-HISTORY_LIMIT]

        for key in list(self.history):
            if key not in active_keys:
                continue

    def _render_cards(self, comparisons: list[dict[str, Any]], signal_stats: dict[str, Any]) -> None:
        active_keys = {self._row_key(row) for row in comparisons}
        for key in list(self.cards):
            if key not in active_keys:
                tab_name = self.card_tabs.get(key)
                if tab_name:
                    self.asset_tabs.delete(tab_name)
                    del self.card_tabs[key]
                del self.cards[key]

        if not comparisons:
            if not hasattr(self, "empty_label"):
                tab = self._ensure_placeholder_tab()
                self.empty_label = ctk.CTkLabel(
                    tab,
                    text="Sem ativos no monitor. Ative a bridge no EA e aguarde o heartbeat do MT5.",
                    text_color="#8fa3bf",
                )
                self.empty_label.grid(row=0, column=0, sticky="w", padx=16, pady=16)
            return

        if hasattr(self, "empty_label"):
            placeholder_name = getattr(self, "placeholder_tab_name", None)
            if placeholder_name:
                self.asset_tabs.delete(placeholder_name)
                self.placeholder_tab_name = None
            self.empty_label.destroy()
            del self.empty_label

        for row in comparisons:
            key = self._row_key(row)
            tab_name = self._tab_name(row)
            if key not in self.cards:
                tab = self.asset_tabs.add(tab_name)
                tab.grid_columnconfigure(0, weight=1)
                tab.grid_rowconfigure(0, weight=1)
                card = AssetCard(tab, str(row.get("symbol") or ""))
                card.grid(row=0, column=0, sticky="nsew", padx=8, pady=8)
                self.cards[key] = card
                self.card_tabs[key] = tab_name
            card = self.cards[key]
            card.set_tab_title(str(row.get("symbol") or ""))
            symbol = str(row.get("symbol") or "").upper()
            per_symbol = dict(signal_stats.get("by_symbol", {}).get(symbol, {}))
            card.update_card(row, self.history.get(key, []), per_symbol)

    def _refresh_log(self) -> None:
        log_path = Path(__file__).resolve().parent / "logs" / "bridge.log"
        if not log_path.exists():
            return
        last_lines = log_path.read_text(encoding="utf-8").splitlines()[-LOG_TAIL_LINES:]
        self.log_box.configure(state="normal")
        self.log_box.delete("1.0", "end")
        self.log_box.insert("1.0", "\n".join(last_lines))
        self.log_box.configure(state="disabled")

    def _refresh_readiness(self, report: dict[str, Any] | None = None) -> None:
        if report is None:
            report = self.bridge.build_readiness_report()
        self.mode_value_var.set(self.bridge.config.balance_mode.upper())
        self.dry_run_value_var.set("Sim" if self.bridge.config.dry_run else "Nao")
        self.otc_value_var.set("Sim" if self.bridge.config.use_otc_symbols else "Nao")
        self.account_value_var.set("Simulada" if self.bridge.config.balance_mode.upper() == "PRACTICE" else "Real")

        if report["ready_for_live"]:
            self.readiness_title_var.set("Pronto para ordem real")
            self.readiness_title.configure(text_color="#28c76f")
        elif self.bridge.config.dry_run:
            self.readiness_title_var.set("Pronto para teste em pratica")
            self.readiness_title.configure(text_color="#f5b700")
        else:
            self.readiness_title_var.set("Ainda nao pronto")
            self.readiness_title.configure(text_color="#ef5350")

        lines = [f"- {item['name']}: {item['message']}" for item in report["checks"]]
        lines.append(f"- Operar OTC: {'Sim' if self.bridge.config.use_otc_symbols else 'Nao'}")
        if report["symbols"]:
            lines.append("- Ativos ativos: " + ", ".join(report["symbols"]))
        self.readiness_body_var.set("\n".join(lines))

    def _row_key(self, row: dict[str, Any]) -> str:
        return f"{row.get('strategy', '')}::{row.get('symbol', '')}::{row.get('timeframe', '')}"

    def _tab_name(self, row: dict[str, Any]) -> str:
        return f"{row.get('strategy', 'EA')} | {row.get('symbol', '')}"

    def _ensure_placeholder_tab(self) -> ctk.CTkFrame:
        if not getattr(self, "placeholder_tab_name", None):
            self.placeholder_tab_name = "Sem ativos"
            tab = self.asset_tabs.add(self.placeholder_tab_name)
            tab.grid_columnconfigure(0, weight=1)
            return tab
        return self.asset_tabs.tab(self.placeholder_tab_name)


def main() -> None:
    app = OpBinBridgeApp()
    app.mainloop()


if __name__ == "__main__":
    main()
