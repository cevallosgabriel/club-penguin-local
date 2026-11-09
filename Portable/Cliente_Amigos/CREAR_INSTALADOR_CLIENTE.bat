@echo off
title Construir Instalador del Cliente
color 0B
cd /d "%~dp0"

echo ========================================================
echo     CONSTRUYENDO INSTALADOR DEL CLIENTE (WinRAR SFX)
echo ========================================================
echo.
echo [*] Auto-escaneo de requisitos para compilar instalador del cliente...

:: 1. Deteccion de Python (Portable local o Sistema)
set "PYTHON_EXE=%~dp0..\Host\Motor_Servidor\Server\bin\python\python-3.10.11\python.exe"

if not exist "%PYTHON_EXE%" (
    python --version >nul 2>&1
    if not errorlevel 1 (
        set "PYTHON_EXE=python"
    ) else (
        echo [ERROR] No se encontro Python Portable ni Python en el sistema.
        pause
        exit /b 1
    )
)
echo  [OK] Python detectado: %PYTHON_EXE%

:: 2. Deteccion de WinRAR
set "WINRAR_FOUND=0"
if exist "C:\Program Files\WinRAR\WinRAR.exe" set "WINRAR_FOUND=1"
if exist "C:\Program Files (x86)\WinRAR\WinRAR.exe" set "WINRAR_FOUND=1"
where winrar >nul 2>&1
if not errorlevel 1 set "WINRAR_FOUND=1"

if "%WINRAR_FOUND%"=="0" (
    echo [ERROR] No se encontro WinRAR instalado en el equipo.
    echo WinRAR es necesario para crear los instaladores SFX.
    pause
    exit /b 1
)
echo  [OK] WinRAR detectado correctamente.

:: 3. Verificacion de archivos del cliente
if not exist "%~dp0Chrome-Portable\GoogleChromePortable.exe" (
    echo [ERROR] No se encontro la carpeta Chrome-Portable en el cliente.
    pause
    exit /b 1
)
if not exist "%~dp01-JUGAR-CLIENTE.bat" (
    echo [ERROR] No se encontro 1-JUGAR-CLIENTE.bat en la carpeta del cliente.
    pause
    exit /b 1
)
echo  [OK] Archivos del cliente verificados e integros.
echo.
echo [*] Todos los requisitos aprobados. Compilando instalador...
echo.

"%PYTHON_EXE%" "%~dp0Herramientas_Compilacion\crear_instalador_cliente.py"
pause
exit
