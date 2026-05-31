from __future__ import annotations

from pathlib import Path

import streamlit as st

from bridge import CONFIG_PATH, IQOptionBridge, ensure_runtime_dirs, load_config, setup_logging


def load_bridge() -> tuple[IQOptionBridge | None, str | None]:
    try:
        config = load_config(CONFIG_PATH)
        ensure_runtime_dirs(config)
        return IQOptionBridge(config), None
    except Exception as exc:
        return None, str(exc)


def render_config_summary(config_path: Path, bridge: IQOptionBridge) -> None:
    st.caption(f"Config: {config_path}")
    col1, col2 = st.columns(2)
    col1.metric("Modo", bridge.config.balance_mode.upper())
    col2.metric("Dry run", "Sim" if bridge.config.dry_run else "Nao")

    st.text_input("Email", value=bridge.config.email, disabled=True)
    st.text_input("Inbox MT5", value=str(bridge.config.inbox_path), disabled=True)
    st.text_input("URL IQ Option", value=bridge.config.browser_url, disabled=True)


def main() -> None:
    setup_logging()
    st.set_page_config(page_title="OpBinBridge", page_icon="O", layout="centered")
    st.title("OpBinBridge")
    st.write("Interface para conectar a bridge da IQ Option e abrir a plataforma no navegador.")

    bridge, error = load_bridge()
    if error:
        st.error(error)
        st.info("Crie ou ajuste o arquivo config.json antes de usar a interface.")
        return

    render_config_summary(CONFIG_PATH, bridge)

    col1, col2 = st.columns(2)

    with col1:
        if st.button("Fazer conexao", use_container_width=True):
            try:
                bridge.ensure_connection()
                st.success("Conexao com a IQ Option estabelecida.")
            except Exception as exc:
                st.error(f"Falha na conexao: {exc}")

    with col2:
        if st.button("Abrir IQ Option", use_container_width=True):
            try:
                if bridge.open_browser():
                    st.success("Pagina aberta no navegador.")
                else:
                    st.warning("Nao foi possivel abrir automaticamente. Verifique o navegador padrao.")
            except Exception as exc:
                st.error(f"Falha ao abrir a pagina: {exc}")

    if st.button("Processar sinais pendentes", use_container_width=True):
        try:
            bridge.process_pending_signals()
            st.success("Leitura da inbox concluida.")
        except Exception as exc:
            st.error(f"Falha ao processar sinais: {exc}")

    log_path = Path(__file__).resolve().parent / "logs" / "bridge.log"
    if log_path.exists():
        st.subheader("Ultimo log")
        st.code(log_path.read_text(encoding="utf-8")[-4000:], language="text")


if __name__ == "__main__":
    main()
