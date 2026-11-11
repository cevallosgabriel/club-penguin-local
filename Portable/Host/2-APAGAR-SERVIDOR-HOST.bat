@echo off
title Club Penguin Portable - Detener Servidor
color 0C
cd /d "%~dp0"

echo =========================================================
echo             DETENIENDO SERVICIOS DE CLUB PENGUIN
echo =========================================================
echo.
echo [*] Deteniendo procesos de Python, Dash y Snowflake...
taskkill /F /IM python.exe 2>nul
taskkill /F /IM pythonw.exe 2>nul

echo [*] Deteniendo servidor de base de datos Redis...
taskkill /F /IM redis-server.exe 2>nul

echo [*] Deteniendo Base de Datos PostgreSQL...
"%~dp0Motor_Servidor\Server\bin\postgresql\postgresql\bin\pg_ctl.exe" stop -D "%~dp0Motor_Servidor\Server\data\postgresql" -m fast >nul 2>&1
taskkill /F /IM postgres.exe 2>nul

echo [*] Deteniendo servidor web Nginx...
taskkill /F /IM nginx.exe 2>nul

echo.
echo =========================================================
echo [OK] Todos los servicios han sido detenidos con exito.
echo =========================================================
ping 127.0.0.1 -n 3 >nul
exit
