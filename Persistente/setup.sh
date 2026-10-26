#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# CLUB PENGUIN LOCAL ENVIRONMENT — Setup Script (Linux/WSL2/macOS)
# ═══════════════════════════════════════════════════════════════
#
# Uso: chmod +x setup.sh && ./setup.sh
#
# Este script es la alternativa Bash para entornos Linux, WSL2 o macOS.
# Crea la estructura de directorios, clona repos y configura symlinks.
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# VARIABLES CONFIGURABLES — Modifica estas rutas
# ─────────────────────────────────────────────────────────────

# Disco principal (SSD) — Lógica de ejecución
SSD_ROOT="${SSD_ROOT:-/opt/cpps}"

# Disco secundario (HDD) — Assets multimedia pesados
# En WSL2, la unidad E: se monta como /mnt/e/
HDD_ROOT="${HDD_ROOT:-/mnt/e/Users/Gener/Desktop/Gabriel_}"

# Credenciales de PostgreSQL
PG_USER="${PG_USER:-cpps_admin}"
PG_PASS="${PG_PASS:-cpps_local_2024}"

# ─────────────────────────────────────────────────────────────
# Colores
# ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

phase() { echo -e "\n${CYAN}═══════════════════════════════════════════════════${NC}"; echo -e "${CYAN}  [$1] $2${NC}"; echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"; }
step()  { echo -e "  ${GREEN}→ $1${NC}"; }
warn()  { echo -e "  ${YELLOW}⚠ $1${NC}"; }
err()   { echo -e "  ${RED}✗ $1${NC}"; }

# ─────────────────────────────────────────────────────────────
# FASE 0: Prerrequisitos
# ─────────────────────────────────────────────────────────────
phase "FASE 0" "Verificando prerrequisitos"

command -v git >/dev/null 2>&1 || { err "Git no instalado. apt install git"; exit 1; }
step "Git: $(git --version)"

command -v python3 >/dev/null 2>&1 || { err "Python3 no instalado. apt install python3"; exit 1; }
step "Python: $(python3 --version)"

command -v docker >/dev/null 2>&1 && step "Docker: $(docker --version)" || warn "Docker no disponible"
command -v docker-compose >/dev/null 2>&1 || command -v "docker compose" >/dev/null 2>&1 && step "Docker Compose disponible" || warn "Docker Compose no disponible"

# ─────────────────────────────────────────────────────────────
# FASE 1: Directorios
# ─────────────────────────────────────────────────────────────
phase "FASE 1" "Creando estructura de directorios"

dirs=(
    "$SSD_ROOT"
    "$SSD_ROOT/houdini"
    "$SSD_ROOT/timeline"
    "$SSD_ROOT/opencpi"
    "$SSD_ROOT/nginx"
    "$SSD_ROOT/init-db"
    "$HDD_ROOT/media/houdini"
    "$HDD_ROOT/media/houdini/play"
    "$HDD_ROOT/media/timeline"
    "$HDD_ROOT/media/timeline/play"
    "$HDD_ROOT/media/opencpi"
    "$HDD_ROOT/cache"
)

for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
    step "Dir: $dir"
done

# ─────────────────────────────────────────────────────────────
# FASE 2: Clonar Repos
# ─────────────────────────────────────────────────────────────
phase "FASE 2" "Clonando repositorios"

clone_repo() {
    local url="$1" dest="$2" name="$3"
    if [ -d "$dest/.git" ]; then
        step "$name ya existe — git pull"
        git -C "$dest" pull --ff-only 2>/dev/null || warn "Pull falló para $name"
    else
        step "Clonando $name → $dest"
        git clone "$url" "$dest"
    fi
}

# Houdini
clone_repo "https://github.com/solero/houdini.git"        "$SSD_ROOT/houdini/houdini"          "Houdini (Solero)"
clone_repo "https://github.com/solero/dash.git"            "$SSD_ROOT/houdini/dash"             "Dash"
clone_repo "https://github.com/solero/wand.git"            "$SSD_ROOT/houdini/wand"             "Wand"
clone_repo "https://github.com/alotshappening/Houdini.git" "$SSD_ROOT/houdini/houdini-original" "Houdini Original"

# Timeline
clone_repo "https://github.com/Times-0/Timeline.git" "$SSD_ROOT/timeline/Timeline" "Timeline"

# OpenCPIsland
clone_repo "https://github.com/OpenCPIsland/CPI-Project.git" "$SSD_ROOT/opencpi/client-source" "OpenCPI Client"
clone_repo "https://github.com/OpenCPIsland/DumbFox.git"     "$SSD_ROOT/opencpi/server"        "DumbFox" || warn "DumbFox no disponible"

# ─────────────────────────────────────────────────────────────
# FASE 3: Symlinks
# ─────────────────────────────────────────────────────────────
phase "FASE 3" "Creando symlinks (SSD → HDD)"

create_symlink() {
    local link="$1" target="$2" name="$3"
    if [ -L "$link" ]; then
        step "Symlink $name ya existe"
    elif [ -d "$link" ]; then
        warn "$link es un directorio real. Renombrando a ${link}.bak"
        mv "$link" "${link}.bak"
        ln -s "$target" "$link"
        step "Symlink creado: $name"
    else
        ln -s "$target" "$link"
        step "Symlink creado: $name → $target"
    fi
}

create_symlink "$SSD_ROOT/houdini/media"  "$HDD_ROOT/media/houdini"  "Houdini Media"
create_symlink "$SSD_ROOT/timeline/media" "$HDD_ROOT/media/timeline" "Timeline Media"
create_symlink "$SSD_ROOT/opencpi/builds" "$HDD_ROOT/media/opencpi"  "OpenCPI Builds"

# ─────────────────────────────────────────────────────────────
# FASE 4: Dependencias Python
# ─────────────────────────────────────────────────────────────
phase "FASE 4" "Instalando dependencias Python"

install_reqs() {
    local req="$1" name="$2"
    if [ -f "$req" ]; then
        step "Instalando deps de $name..."
        python3 -m pip install -r "$req" --quiet 2>/dev/null || warn "Falló pip install para $name"
    else
        warn "requirements.txt no encontrado para $name"
    fi
}

install_reqs "$SSD_ROOT/houdini/houdini/requirements.txt" "Houdini"
install_reqs "$SSD_ROOT/houdini/dash/requirements.txt"    "Dash"
install_reqs "$SSD_ROOT/timeline/Timeline/requirements.txt" "Timeline"

# ─────────────────────────────────────────────────────────────
# FASE 5: Generar .env
# ─────────────────────────────────────────────────────────────
phase "FASE 5" "Generando configuración"

cat > "$SSD_ROOT/.env" <<EOF
# Auto-generado — $(date +"%Y-%m-%d %H:%M:%S")
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
EOF

step ".env generado en $SSD_ROOT/.env"

# ─────────────────────────────────────────────────────────────
# Resumen
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ SETUP COMPLETADO${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""
echo "  Próximos pasos:"
echo "    1. Descarga Vanilla Media y colócalos en: $HDD_ROOT/media/houdini/"
echo "    2. cd $SSD_ROOT && docker compose up -d"
echo "    3. Descarga Flash Player Standalone para el cliente del juego"
echo "    4. Descarga OpenCPI desde https://opencpisland.itch.io"
echo ""
