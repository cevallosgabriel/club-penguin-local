@echo off
title Instalar y Construir EXE con Python
color 0B
cd /d "%~dp0"

echo ========================================================
echo       GENERAR EJECUTABLE DE CLIENTE CON PYTHON
echo ========================================================
echo.
echo [*] Auto-escaneo de entorno Python...

set "PYTHON_EXE=python"
set "PIP_EXE=pip"

python --version >nul 2>&1
if errorlevel 1 (
    if exist "..\Host\Motor_Servidor\Server\bin\python\python-3.10.11\python.exe" (
        echo [OK] Usando Python Portable del Host...
        set "PYTHON_EXE=..\Host\Motor_Servidor\Server\bin\python\python-3.10.11\python.exe"
        set "PIP_EXE=..\Host\Motor_Servidor\Server\bin\python\python-3.10.11\python.exe -m pip"
    ) else (
        echo [ERROR] No se detecto ninguna instalacion de Python en el sistema.
        pause
        exit /b 1
    )
) else (
    echo [OK] Python detectado en el sistema.
)

echo.
echo [*] Instalando dependencias necesarias (PyInstaller y Pillow)...
cd "Herramientas_Compilacion"
%PIP_EXE% install -r requirements.txt

echo.
echo [*] Construyendo ejecutable empaquetado...
echo [*] Nota: Puede demorar unos instantes al integrar el navegador Flash.
%PYTHON_EXE% construir_con_pyinstaller.py

echo.
echo [*] Limpiando carpetas temporales de compilacion...
if exist "dist\*.exe" move /Y "dist\*.exe" "..\ClubPenguin_Cliente_Python.exe" >nul 2>&1
if exist "build" rd /s /q "build" 2>nul
if exist "dist" rd /s /q "dist" 2>nul

echo.
echo [OK] Compilacion finalizada exitosamente.
pause
exit
