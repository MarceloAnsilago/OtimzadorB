# IQ Payout Scanner

Script minimo para conectar na IQ Option e listar ativos com payout acima do minimo configurado.

## O que faz

- conecta na IQ Option
- usa `get_all_profit`
- lista ativos com payout maior ou igual ao minimo
- opcionalmente inclui OTC

## O que nao faz

- nao envia ordens
- nao integra com MT5
- nao usa bridge

## Setup

1. Copie `config.example.json` para `config.json` se necessario.
2. Preencha `email` e `password`.
3. Ative a `.venv`.
4. Rode `pip install -r requirements.txt`.
5. Execute `run_ctk.cmd`.
