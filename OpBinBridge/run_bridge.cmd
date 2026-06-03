@echo off
setlocal

set "ROOT=%~dp0"
set "VENV=%ROOT%.venv"

if not exist "%VENV%\Scripts\python.exe" (
  echo Ambiente virtual nao encontrado em %VENV%
  exit /b 1
)

"%VENV%\Scripts\python.exe" "%ROOT%bridge_worker.py"
