# BinRobo

Base inicial de um desktop app para automacao e analise de trading com `Python + Flask + PyWebView`.

## Stack

- Backend: Flask, Flask-SocketIO, python-dotenv
- Desktop: pywebview
- Frontend: Bootstrap 5, Bootstrap Icons, HTML, CSS, JS
- Integracao futura: iqoptionapi
- Persistencia inicial: SQLite

## Estrutura

```text
project/
├── app.py
├── requirements.txt
├── .env
├── .gitignore
├── start.bat
├── README.md
├── core/
├── data/
├── desktop/
├── logs/
├── web/
└── venv/
```

## Como executar

### Opcao 1: Windows

```bat
start.bat
```

### Opcao 2: PowerShell

```powershell
.\venv\Scripts\Activate.ps1
python app.py
```

## Fluxo atual

- Login com autenticacao basica na IQ Option
- Dashboard inicial para download de candles historicos
- Persistencia local dos lotes em `data/market/*.csv`

## Observacoes

- A tela inicial agora pode autenticar na IQ Option.
- O submit faz autenticacao basica e devolve status para a interface.
- A primeira pagina operacional baixa candles historicos e salva em CSV local, mas ainda nao executa operacoes, streaming ou estrategia.
- `eventlet` esta instalado para crescimento futuro, mas o modo padrao do `Flask-SocketIO` foi deixado como `threading` para maior estabilidade inicial no desktop Windows. Se quiser, altere `SOCKETIO_ASYNC_MODE` no `.env`.
- Caso a conta exija verificacao adicional, captcha ou fluxo nao suportado pela biblioteca, a autenticacao pode falhar mesmo com credenciais corretas.
