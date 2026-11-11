@echo off
setlocal EnableDelayedExpansion
title Club Penguin Portable - Lanzador Maestro
color 0B
cd /d "%~dp0"

echo =========================================================
echo             CLUB PENGUIN PORTABLE - HOST
echo =========================================================
echo.

:: ---------------------------------------------------------
:: 1. AUTO-ESCANEO DE INTEGRIDAD Y REQUISITOS DEL SISTEMA
:: ---------------------------------------------------------
echo [*] Ejecutando auto-escaneo de componentes del servidor...

set "ROOT=%~dp0Motor_Servidor\"
set "PYDIR=%ROOT%Server\bin\python\python-3.10.11"
set "PYTHON_EXE=%PYDIR%\python.exe"

if not exist "%PYTHON_EXE%" (
    python --version >nul 2>&1
    if not errorlevel 1 (
        set "PYTHON_EXE=python"
    ) else (
        echo.
        echo [ERROR] No se encontro Python Portable en:
        echo        %PYDIR%
        echo Ni tampoco una instalacion de Python en el PATH del sistema.
        echo.
        echo Por favor, verifica que la carpeta 'Motor_Servidor' no este danada.
        echo.
        pause
        exit /b 1
    )
)
echo  [OK] Motor Python detectado.

if not exist "%ROOT%Server\bin\nginx\nginx-1.28.2\nginx.exe" (
    echo.
    echo [ERROR] No se encontro el servidor web Nginx en:
    echo        %ROOT%Server\bin\nginx\nginx-1.28.2\nginx.exe
    echo.
    pause
    exit /b 1
)
echo  [OK] Servidor Web (Nginx) listo.

if not exist "%ROOT%Server\bin\redis\redis-x64-5.0.14.1\redis-server.exe" (
    echo.
    echo [ERROR] No se encontro Redis Server en:
    echo        %ROOT%Server\bin\redis\redis-x64-5.0.14.1\redis-server.exe
    echo.
    pause
    exit /b 1
)
echo  [OK] Servidor de Memoria (Redis) listo.

if not exist "%ROOT%Server\bin\postgresql\postgresql\bin\pg_ctl.exe" (
    echo.
    echo [ERROR] No se encontro PostgreSQL en:
    echo        %ROOT%Server\bin\postgresql\postgresql\bin\pg_ctl.exe
    echo.
    pause
    exit /b 1
)
echo  [OK] Base de Datos (PostgreSQL) lista.

if not exist "%ROOT%Server\www\houdini\bootstrap.py" (
    echo.
    echo [ERROR] No se encontro el emulador Houdini en:
    echo        %ROOT%Server\www\houdini\bootstrap.py
    echo.
    pause
    exit /b 1
)
echo  [OK] Emulador de Salas y Mundo (Houdini) listo.

echo.
echo [OK] Auto-escaneo completado con exito. Todos los modulos estan listos.
echo.

:: ---------------------------------------------------------
:: 2. CONFIGURACION DE RED Y ENLACES (IP)
:: ---------------------------------------------------------
set "PREV_IP="
if exist "%~dp0current_ip.txt" (
    set /p PREV_IP=<"%~dp0current_ip.txt"
)

echo Ingresa la IP de Radmin VPN o Red Local que vas a usar para jugar con amigos.
if defined PREV_IP (
    echo [IP anterior detectada: !PREV_IP!]
    echo Presiona Enter directamente para reutilizarla, o escribe una nueva:
) else (
    echo (Si vas a jugar tu solo sin conexion o en red local, escribe: localhost)
)
echo.
set /p USER_IP="IP del Servidor (o Enter para !PREV_IP!): "

if "!USER_IP!"=="" (
    if defined PREV_IP (
        set "TARGET_IP=!PREV_IP!"
    ) else (
        set "TARGET_IP=localhost"
    )
) else (
    set "TARGET_IP=!USER_IP!"
)
:: Eliminar posibles espacios en blanco accidentales de la IP
set "TARGET_IP=!TARGET_IP: =!"

echo.
echo =========================================================
echo [*] Configurando red y enlaces hacia IP: !TARGET_IP! ...
echo =========================================================

"%PYTHON_EXE%" "%~dp0Empaquetador_Instalador\patch_ips.py" "!TARGET_IP!"
echo !TARGET_IP!> "%~dp0current_ip.txt"
echo [OK] Red y enlaces actualizados.
echo.

:: ---------------------------------------------------------
:: 3. LEVANTAMIENTO DE SERVIDORES DE FONDO
:: ---------------------------------------------------------
echo ---------------------------------------------------------
echo Levantando servidores de fondo...
echo ---------------------------------------------------------

set "VBS_SCRIPT=%temp%\run_cp_hidden.vbs"

echo Set objShell = WScript.CreateObject("WScript.Shell") > "%VBS_SCRIPT%"
echo args = WScript.Arguments(0) >> "%VBS_SCRIPT%"
echo objShell.Run args, 0, False >> "%VBS_SCRIPT%"

echo [*] Nginx...
taskkill /F /IM nginx.exe >nul 2>&1
wscript "%VBS_SCRIPT%" "cmd /c cd /d ""%ROOT%Server\bin\nginx\nginx-1.28.2"" && nginx.exe"

echo [*] Redis...
wscript "%VBS_SCRIPT%" "cmd /c cd /d ""%ROOT%Server\bin\redis\redis-x64-5.0.14.1"" && redis-server.exe"

echo [*] Base de Datos (PostgreSQL)...
wscript "%VBS_SCRIPT%" "cmd /c ""%ROOT%Server\bin\postgresql\postgresql\bin\pg_ctl.exe"" start -D ""%ROOT%Server\data\postgresql"""

echo [*] Login Server...
wscript "%VBS_SCRIPT%" "cmd /c cd /d ""%ROOT%Server\www\houdini"" && ""%PYTHON_EXE%"" bootstrap.py login"

echo [*] World Server...
wscript "%VBS_SCRIPT%" "cmd /c cd /d ""%ROOT%Server\www\houdini"" && ""%PYTHON_EXE%"" bootstrap.py world"

echo [*] Snowflake (Dojo Nieve)...
if exist "%ROOT%Server\www\houdini\snowflake\main.py" (
    wscript "%VBS_SCRIPT%" "cmd /c cd /d ""%ROOT%Server\www\houdini\snowflake"" && ""%PYTHON_EXE%"" main.py"
)

echo [*] Dash (API Web)...
if exist "%ROOT%Server\www\dash\bootstrap.py" (
    wscript "%VBS_SCRIPT%" "cmd /c cd /d ""%ROOT%Server\www\dash"" && ""%PYTHON_EXE%"" bootstrap.py -c config.py"
)

echo.
echo =========================================================
echo Servidores en linea en: http://!TARGET_IP!/play/
echo =========================================================

set "CHROME=%~dp0Motor_Servidor\-Extras\3-Chrome-Portable [Flash]\Chrome-Portable\GoogleChromePortable.exe"
if not exist "%CHROME%" (
    set "CHROME=%~dp0..\Cliente_Amigos\Chrome-Portable\GoogleChromePortable.exe"
)

if exist "%CHROME%" (
    start "" "%CHROME%" "http://!TARGET_IP!/play/"
) else (
    echo [AVISO] Navegador Flash integrado no encontrado. Abriendo en navegador por defecto...
    start "" "http://!TARGET_IP!/play/"
)

echo.
echo =========================================================
echo                MONITOREO DEL SERVIDOR (HOST)
echo =========================================================
echo [1] Abrir Panel de Escritorio (Recomendado: Seguro, funciones de ban)
echo [2] Abrir Panel Web (En navegador estilo Club Penguin)
echo [3] Abrir AMBOS paneles a la vez
echo [4] No abrir paneles de monitoreo
echo.
set /p MON_OPT="Selecciona una opcion [1, 2, 3 o 4] (Por defecto 1): "
if "%MON_OPT%"=="" set "MON_OPT=1"

set "PYTHONW_EXE=%PYDIR%\pythonw.exe"
if not exist "%PYTHONW_EXE%" set "PYTHONW_EXE=pythonw"

if "%MON_OPT%"=="1" (
    echo [*] Abriendo Panel de Escritorio del Host...
    start "" "%PYTHONW_EXE%" "%~dp0Panel_Host.py"
)
if "%MON_OPT%"=="2" (
    echo [*] Abriendo Panel Web...
    start "" "http://localhost/online"
)
if "%MON_OPT%"=="3" (
    echo [*] Abriendo Panel de Escritorio y Panel Web...
    start "" "%PYTHONW_EXE%" "%~dp0Panel_Host.py"
    start "" "http://localhost/online"
)

ping 127.0.0.1 -n 3 >nul
exit
