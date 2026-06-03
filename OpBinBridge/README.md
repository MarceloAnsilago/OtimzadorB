# IQ Payout Scanner + MT5 Bridge

Bridge minima para conectar na IQ Option, listar ativos e consumir sinais exportados pelo EA do MT5.

## O que faz

- conecta na IQ Option
- usa `get_all_profit`
- lista ativos com payout maior ou igual ao minimo
- opcionalmente inclui OTC
- consome sinais JSON em `Common\Files\OpBinBridge\signals_in`
- grava status da bridge, recibos e arquivos processados/falhos

## O que nao faz

- nao faz gerenciamento avancado de fila
- nao confirma resultado da opcao apos o envio

## Setup

1. Copie `config.example.json` para `config.json` se necessario.
2. Preencha `email` e `password`.
3. Ative a `.venv`.
4. Rode `pip install -r requirements.txt`.
5. Execute `run_ctk.cmd` para o modo manual.
6. Execute `run_bridge.cmd` para o modo automatico por arquivos.

## Bridge por arquivos

Pastas usadas sob `mt5_common_files_dir\bridge_root_folder`:

- `signals_in`: inbox dos sinais exportados pelo EA
- `signals_processed`: sinais aceitos e processados
- `signals_failed`: sinais rejeitados ou com erro
- `receipts`: recibos JSON do processamento
- `status`: heartbeat da bridge

Formato esperado do sinal de entrada:

```json
{
  "source": "mt5",
  "strategy": "NomeEstrategia",
  "symbol": "EURJPY",
  "timeframe": "PERIOD_M1",
  "signal_time": 1717360000,
  "signal_time_text": "2026.06.02 21:00:00",
  "direction": "CALL",
  "direction_value": 1,
  "expiration_minutes": 15,
  "amount_hint": 2.0
}
```

Comportamento do worker:

- resolve o simbolo IQ a partir de `symbol` e de `iq_symbol_map`
- prefere regular ou OTC conforme `use_otc_symbols`
- valida payout minimo por `min_payout_percent`
- escolhe `TURBO` para `1-5` min e `BINARY` acima disso
- grava `receipt_*.json` com `order_symbol`, `option_kind`, expiracao e `order_id`
