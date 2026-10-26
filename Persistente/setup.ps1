<#
.SYNOPSIS
    Club Penguin Local Environment - Script de Inicializacion Completa
.DESCRIPTION
    Automatiza la clonacion, configuracion de symlinks, preparacion de bases de datos
    y arranque de los emuladores de Club Penguin.
#>

param(
    [string]$SSD_ROOT = "C:\cpps",
    [string]$HDD_ROOT = "$PSScriptRoot\..",
    [string]$PG_USER = "cpps_admin",
    [string]$PG_PASS = "cpps_local_2024",
    [switch]$SkipHoudini,
    [switch]$SkipTimeline,
    [switch]$SkipOpenCPI,
    [switch]$SkipDocker,
    [switch]$SkipSymlinks,
    [switch]$SkipClone
)

$ProgressPreference = "SilentlyContinue"

function Write-Phase {
    param([string]$Phase, [string]$Message)
    Write-Host ""
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "  [$Phase] $Message" -ForegroundColor Cyan
    Write-Host "===================================================" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Message)
    Write-Host "  -> $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  ! $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "  x $Message" -ForegroundColor Red
}

Write-Phase "FASE 0" "Verificando prerrequisitos del sistema"

try {
    $gitVersion = git --version
    Write-Step "Git encontrado: $gitVersion"
} catch {
    Write-Err "Git no esta instalado. Descargalo de https://git-scm.com"
    exit 1
}

try {
    $pyVersion = python --version 2>&1
    Write-Step "Python encontrado: $pyVersion"
} catch {
    Write-Warn "Python no encontrado."
}

if (-not $SkipDocker) {
    try {
        $dockerVersion = docker --version
        Write-Step "Docker encontrado: $dockerVersion"
    } catch {
        Write-Err "Docker no esta instalado."
        exit 1
    }
}

if (-not (Test-Path $HDD_ROOT)) {
    Write-Warn "La ruta del HDD no existe: $HDD_ROOT"
    Write-Step "Creando estructura en el HDD..."
    New-Item -ItemType Directory -Force -Path $HDD_ROOT | Out-Null
}

Write-Phase "FASE 1" "Creando estructura de directorios"

$directories = @(
    "$SSD_ROOT",
    "$SSD_ROOT\houdini",
    "$SSD_ROOT\timeline",
    "$SSD_ROOT\opencpi",
    "$SSD_ROOT\nginx",
    "$SSD_ROOT\init-db",
    "$HDD_ROOT\media\houdini",
    "$HDD_ROOT\media\houdini\play",
    "$HDD_ROOT\media\timeline",
    "$HDD_ROOT\media\timeline\play",
    "$HDD_ROOT\media\opencpi",
    "$HDD_ROOT\cache"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Step "Creado: $dir"
    } else {
        Write-Step "Existe: $dir"
    }
}

if (-not $SkipClone) {
    Write-Phase "FASE 2" "Clonando repositorios desde GitHub"

    function Clone-Repo {
        param([string]$Url, [string]$Dest, [string]$Name)
        if (Test-Path "$Dest\.git") {
            Write-Step "$Name ya clonado en $Dest - actualizando..."
            Push-Location $Dest
            git pull --ff-only 2>&1 | Out-Null
            Pop-Location
        } else {
            Write-Step "Clonando $Name -> $Dest"
            git clone $Url $Dest 2>&1
        }
    }

    if (-not $SkipHoudini) {
        Clone-Repo "https://github.com/solero/houdini.git" "$SSD_ROOT\houdini\houdini" "Houdini"
        Clone-Repo "https://github.com/solero/dash.git" "$SSD_ROOT\houdini\dash" "Dash"
        Clone-Repo "https://github.com/solero/wand.git" "$SSD_ROOT\houdini\wand" "Wand"
    }

    if (-not $SkipTimeline) {
        Clone-Repo "https://github.com/Times-0/Timeline.git" "$SSD_ROOT\timeline\Timeline" "Timeline"
    }
} else {
    Write-Phase "FASE 2" "Clonacion saltada"
}

if (-not $SkipSymlinks) {
    Write-Phase "FASE 3" "Creando symlinks de media (SSD -> HDD)"

    function New-Symlink {
        param([string]$Link, [string]$Target, [string]$Name)
        if (Test-Path $Link) {
            $existing = Get-Item $Link
            if ($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                Write-Step "Symlink $Name ya existe"
                return
            } else {
                Rename-Item $Link "$Link.bak" -Force
            }
        }
        try {
            cmd /c mklink /D "$Link" "$Target" 2>&1 | Out-Null
            Write-Step "Symlink creado: $Name"
        } catch {
            Write-Err "No se pudo crear symlink para $Name."
        }
    }

    if (-not $SkipHoudini) {
        New-Symlink "$SSD_ROOT\houdini\media" "$HDD_ROOT\media\houdini" "Houdini Media"
    }
    if (-not $SkipTimeline) {
        New-Symlink "$SSD_ROOT\timeline\media" "$HDD_ROOT\media\timeline" "Timeline Media"
    }
}

Write-Phase "FASE 4" "Preparando bases de datos"

$initSQL = @"
SELECT 'CREATE DATABASE houdini'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'houdini')\gexec

SELECT 'CREATE DATABASE timeline'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'timeline')\gexec

GRANT ALL PRIVILEGES ON DATABASE houdini TO $PG_USER;
GRANT ALL PRIVILEGES ON DATABASE timeline TO $PG_USER;
"@
$initSQL | Out-File -FilePath "$SSD_ROOT\init-db\01-init-databases.sql" -Encoding ascii -Force
Write-Step "Script de init DB creado"

Write-Phase "FASE 5" "Preparando configuracion de Docker"

$envContent = @"
CPPS_ROOT=$SSD_ROOT
CPPS_MEDIA_ROOT=$HDD_ROOT
POSTGRES_PORT=5432
POSTGRES_USER=$PG_USER
POSTGRES_PASSWORD=$PG_PASS
POSTGRES_DB_HOUDINI=houdini
POSTGRES_DB_TIMELINE=timeline
REDIS_HOST=localhost
REDIS_PORT=6379
HOUDINI_LOGIN_PORT=6112
HOUDINI_WORLD_PORT=9875
HOUDINI_GAME_ADDRESS=localhost
HOUDINI_WEB_PORT=3000
TIMELINE_LOGIN_PORT=6113
TIMELINE_WORLD_PORT=9876
OPENCPI_SERVER_PORT=9933
NGINX_HTTP_PORT=8080
COMPOSE_PROJECT_NAME=cpps-local
"@
$envContent | Out-File -FilePath "$SSD_ROOT\.env" -Encoding ascii -Force

$scriptDir = $PSScriptRoot
if (Test-Path "$scriptDir\docker-compose.yml") {
    Copy-Item "$scriptDir\docker-compose.yml" "$SSD_ROOT\docker-compose.yml" -Force
}
if (Test-Path "$scriptDir\nginx\nginx.conf") {
    New-Item -ItemType Directory -Force -Path "$SSD_ROOT\nginx" | Out-Null
    Copy-Item "$scriptDir\nginx\nginx.conf" "$SSD_ROOT\nginx\nginx.conf" -Force
}

Write-Host ""
Write-Host "===================================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETADO" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Ahora puedes ir a la carpeta C:\cpps y levantar docker:"
Write-Host "  cd C:\cpps"
Write-Host "  docker compose up -d"
Write-Host ""
