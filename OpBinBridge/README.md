# OpBinBridge

Bridge local entre `OpBin.mq5` e a API da IQ Option via Python.

## Fluxo

1. O MT5 gera um arquivo JSON em `Common\Files\OpBinBridge\signals_in`.
2. `bridge.py` consome o arquivo.
3. A bridge envia a ordem para a IQ Option via `stable_api`.
4. O arquivo vai para `signals_processed` ou `signals_failed`.
5. O recibo fica em `receipts`.
6. Opcionalmente, a bridge abre a pagina da IQ Option ao iniciar.

## Setup

1. Copie `config.example.json` para `config.json`.
2. Preencha email, senha e modo de conta.
3. Crie o ambiente virtual e instale dependencias.
4. Ative `InpBridgeAtivo = true` no EA.
5. Execute `run_bridge.cmd`.
6. Se quiser uma tela simples com botoes, execute `run_streamlit.cmd`.

## Observacoes

- `dry_run: true` nao envia ordem real; apenas consome e registra.
- `allowed_symbols` vazio aceita qualquer ativo recebido do MT5.
- A dependencia usada e a `iqoptionapi` comunitaria via `stable_api`.
- `open_browser_on_start: true` abre a pagina configurada em `browser_url`, mas o envio continua sendo por API.
