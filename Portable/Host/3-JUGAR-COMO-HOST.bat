@echo off
title Club Penguin Portable - Jugar
cd /d "%~dp0"

set "TARGET_IP=localhost"
if exist "%~dp0current_ip.txt" (
    set /p TARGET_IP=<"%~dp0current_ip.txt"
)

set "CHROME=%~dp0Motor_Servidor\-Extras\3-Chrome-Portable [Flash]\Chrome-Portable\GoogleChromePortable.exe"
if not exist "%CHROME%" (
    set "CHROME=%~dp0..\Cliente_Amigos\Chrome-Portable\GoogleChromePortable.exe"
)

if not exist "%CHROME%" (
    echo [AVISO] Abriendo en tu navegador por defecto...
    start "" "http://%TARGET_IP%/play/"
    exit
)

echo Iniciando Navegador Flash en http://%TARGET_IP%/play/ ...
start "" "%CHROME%" "http://%TARGET_IP%/play/"
exit
