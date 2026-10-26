<#
.SYNOPSIS
    Arranca todos los servicios de Club Penguin en modo nativo (sin Docker)
#>
param(
    [string]$SSD_ROOT = "C:\cpps",
    [string]$HDD_ROOT = "E:\Users\Gener\Desktop\Gabriel_",
    [switch]$HoudiniOnly,
    [switch]$TimelineOnly
)

$ErrorActionPreference = "Continue"

function Write-Status {
    param([string]$Service, [string]$Status, [ConsoleColor]$Color = "Green")
    Write-Host "[$Service] $Status" -ForegroundColor $Color
}

Write-Host "Arrancando Servicios Locales..." -ForegroundColor Cyan

$redisProcess = Get-Process -Name "redis-server", "memurai" -ErrorAction SilentlyContinue
if (-not $redisProcess) {
    Write-Status "Redis" "No detectado. Necesitas Redis o Memurai corriendo." Yellow
} else {
    Write-Status "Redis" "Corriendo" Green
}

$pgProcess = Get-Process -Name "postgres" -ErrorAction SilentlyContinue
if (-not $pgProcess) {
    Write-Status "Postgres" "No detectado." Yellow
} else {
    Write-Status "Postgres" "Corriendo" Green
}

if (-not $TimelineOnly) {
    $houdiniDir = "$SSD_ROOT\houdini\houdini"
    if (Test-Path "$houdiniDir\bootstrap.py") {
        Write-Status "Houdini" "Iniciando..."
        Start-Process -FilePath "python" -ArgumentList "bootstrap.py" -WorkingDirectory $houdiniDir -WindowStyle Normal
    }
    
    $dashDir = "$SSD_ROOT\houdini\dash"
    if (Test-Path "$dashDir\bootstrap.py") {
        Write-Status "Dash" "Iniciando..."
        Start-Process -FilePath "python" -ArgumentList "bootstrap.py" -WorkingDirectory $dashDir -WindowStyle Normal
    }
}

if (-not $HoudiniOnly) {
    $timelineDir = "$SSD_ROOT\timeline\Timeline"
    if (Test-Path "$timelineDir\Timeline.py") {
        Write-Status "Timeline" "Iniciando..."
        Start-Process -FilePath "python" -ArgumentList "Timeline.py" -WorkingDirectory $timelineDir -WindowStyle Normal
    }
}

Write-Host "Listo." -ForegroundColor Green
