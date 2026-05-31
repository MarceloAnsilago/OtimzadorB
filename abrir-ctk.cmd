@echo off
setlocal

set "CTK_DIR=%~dp0Advisors\CTK"

if not exist "%CTK_DIR%" (
  echo Pasta do CTK nao encontrada:
  echo %CTK_DIR%
  exit /b 1
)

where code >nul 2>nul
if %errorlevel%==0 (
  code "%CTK_DIR%"
  exit /b 0
)

start "" "%CTK_DIR%"
