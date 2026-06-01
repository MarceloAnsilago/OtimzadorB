# OpBinBridge

Bridge local entre `OpBin.mq5` e a API da IQ Option via Python.

## Fluxo

1. O MT5 gera um arquivo JSON em `Common\Files\OpBinBridge\signals_in`.
2. `bridge.py` consome o arquivo.
3. A bridge envia a ordem para a IQ Option via `stable_api`.
4. O arquivo vai para `signals_processed` ou `signals_failed`.
5. O recibo fica em `receipts`.
6. O EA tambem pode exportar um heartbeat por ativo em `Common\Files\OpBinBridge\status`.
7. A interface em `customtkinter` compara a ultima cotacao do MT5 com a ultima vela retornada pela IQ Option e mantem historico curto por ativo.
8. Opcionalmente, a bridge abre a pagina da IQ Option ao iniciar.

## Setup

1. Copie `config.example.json` para `config.json`.
2. Preencha email, senha e modo de conta.
3. Crie o ambiente virtual e instale dependencias.
4. Ative `InpBridgeAtivo = true` no EA.
5. Recompile o EA e deixe o robo anexado aos graficos que deseja monitorar.
6. Execute `run_bridge.cmd`.
7. Se quiser a interface grafica nativa com monitor ao vivo, execute `run_ctk.cmd`.

## Observacoes

- `dry_run: true` nao envia ordem real; apenas consome e registra.
- `allowed_symbols` vazio aceita qualquer ativo recebido do MT5.
- `status_freshness_seconds` define por quantos segundos um heartbeat do MT5 ainda conta como ativo.
- `iq_symbol_map` permite mapear simbolos do MT5 para nomes diferentes na IQ Option.
- A dependencia usada e a `iqoptionapi` comunitaria via `stable_api`.
- `open_browser_on_start: true` abre a pagina configurada em `browser_url`, mas o envio continua sendo por API.
- A interface usa `customtkinter` e `matplotlib`, sem dependencia de navegador.
