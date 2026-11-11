@echo off
setlocal EnableDelayedExpansion
title Conectar a Club Penguin
color 0B
cd /d "%~dp0"

echo ========================================================
echo             CONECTAR A CLUB PENGUIN MULTIJUGADOR
echo ========================================================
echo.

:: ---------------------------------------------------------
:: 1. AUTO-ESCANEO DE COMPONENTES DEL CLIENTE
:: ---------------------------------------------------------
set "CHROME=%~dp0Chrome-Portable\GoogleChromePortable.exe"
if exist "%CHROME%" (
    echo [OK] Navegador Flash Portable detectado.
) else (
    echo [AVISO] Navegador Flash Portable no encontrado en la carpeta.
    echo        Se intentara abrir en el navegador web predeterminado.
)
echo.

:: ---------------------------------------------------------
:: 2. DETECCION Y SOLICITUD DE IP DEL HOST
:: ---------------------------------------------------------
set "SAVED_IP="
if exist "%~dp0ip_servidor.txt" (
    set /p SAVED_IP=<"%~dp0ip_servidor.txt"
)

if defined SAVED_IP (
    echo [IP anterior detectada: !SAVED_IP!]
    echo Presiona Enter para usarla directamente, o escribe la nueva IP:
) else (
    echo Ingresa la IP de Radmin VPN o LAN del anfitrion (Host):
)
echo.
set /p USER_INPUT="IP del Servidor (o Enter para !SAVED_IP!): "

if "!USER_INPUT!"=="" (
    if defined SAVED_IP (
        set "HOST_IP=!SAVED_IP!"
    ) else (
        echo.
        echo [ERROR] Debes ingresar una IP valida para poder conectarte.
        pause
        exit /b 1
    )
) else (
    set "HOST_IP=!USER_INPUT!"
    echo !HOST_IP!> "%~dp0ip_servidor.txt"
)
:: Eliminar posibles espacios accidentales
set "HOST_IP=!HOST_IP: =!"

echo.
echo ========================================================
echo Conectando a Club Penguin en: http://!HOST_IP!/play/
echo ========================================================

if exist "%CHROME%" (
    start "" "%CHROME%" "http://!HOST_IP!/play/"
) else (
    start "" "http://!HOST_IP!/play/"
)

ping 127.0.0.1 -n 2 >nul
exit
