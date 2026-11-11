@echo off
title Creador de Instalador del Host
color 0B
cd /d "%~dp0"

echo ========================================================
echo       GENERAR INSTALADOR DEL SERVIDOR (HOST)
echo ========================================================
echo.
echo [*] Auto-escaneo de requisitos para compilar instalador...

:: 1. Deteccion de Python (Portable local o Sistema)
set "PYTHON_EXE=%~dp0Motor_Servidor\Server\bin\python\python-3.10.11\python.exe"

if not exist "%PYTHON_EXE%" (
    python --version >nul 2>&1
    if not errorlevel 1 (
        set "PYTHON_EXE=python"
    ) else (
        echo [ERROR] No se encontro Python Portable ni Python en el sistema.
        echo Se requiere Python para generar el instalador.
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
    echo Por favor, instala WinRAR y vuelve a intentar.
    pause
    exit /b 1
)
echo  [OK] WinRAR detectado correctamente.
echo.
echo [*] Todos los requisitos aprobados. Iniciando empaquetado...
echo.

cd "Empaquetador_Instalador"
"%PYTHON_EXE%" crear_instalador_host.py

echo.
pause
exit
