#!/bin/bash

# === CONFIGURACIÓN ===
CPU_LIMIT=80
RAM_LIMIT=80
DISK_LIMIT=80

# Rutas
BASE_DIR="$(dirname "$(realpath "$0")")"
ALERT_LOG="$BASE_DIR/alerts.log"
DATE=$(date '+%Y%m%d')
METRICS_LOG="$BASE_DIR/metrics_$DATE.log"

# === COLORES ===
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# === FUNCIÓN: Log de alerta ===
log_alert() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ALERTA: $message" >> "$ALERT_LOG"
    echo -e "${RED}ALERTA: $message${NC}"
}

# === CPU (con mpstat - más confiable) ===
check_cpu() {
    # Instala si no tienes: sudo apt install sysstat
    if ! command -v mpstat &> /dev/null; then
        echo "mpstat no encontrado. Instalando..."
        sudo apt update && sudo apt install -y sysstat
    fi

    # %usr + %sys = uso real
    local cpu_usage=$(mpstat 1 1 | tail -1 | awk '{print 100 - $12}')
    cpu_usage=$(printf "%.1f" "$cpu_usage" 2>/dev/null || echo "0.0")

    if (( $(echo "$cpu_usage >= $CPU_LIMIT" | bc -l 2>/dev/null) )); then
        echo -e "${RED}CPU: ${cpu_usage}% (ALERTA)${NC}"
        log_alert "CPU alta: ${cpu_usage}%"
    else
        echo -e "${GREEN}CPU: ${cpu_usage}% (OK)${NC}"
    fi

    echo "$(date '+%H:%M:%S') CPU: ${cpu_usage}%" >> "$METRICS_LOG"
}

# === RAM ===
check_ram() {
    local mem=$(free | grep "Mem:")
    local total=$(echo "$mem" | awk '{print $2}')
    local used=$(echo "$mem" | awk '{print $3}')
    local ram_usage=$(echo "scale=1; $used * 100 / $total" | bc -l 2>/dev/null || echo "0")

    if (( $(echo "$ram_usage >= $RAM_LIMIT" | bc -l) )); then
        echo -e "${RED}RAM: ${ram_usage}% (ALERTA)${NC}"
        log_alert "RAM alta: ${ram_usage}%"
    else
        echo -e "${GREEN}RAM: ${ram_usage}% (OK)${NC}"
    fi

    echo "$(date '+%H:%M:%S') RAM: ${ram_usage}%" >> "$METRICS_LOG"
}

# === DISCO ===
check_disk() {
    local disk_usage=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

    if [ "$disk_usage" -ge "$DISK_LIMIT" ]; then
        echo -e "${RED}DISCO: ${disk_usage}% (ALERTA)${NC}"
        log_alert "Disco lleno: ${disk_usage}%"
    else
        echo -e "${GREEN}DISCO: ${disk_usage}% (OK)${NC}"
    fi

    echo "$(date '+%H:%M:%S') DISCO: ${disk_usage}%" >> "$METRICS_LOG"
}

# === INICIO ===
echo "------ Monitoreo del sistema $(date '+%Y-%m-%d %H:%M:%S') ------" >> "$METRICS_LOG"

check_cpu
check_ram
check_disk

echo "Métricas guardadas en: $METRICS_LOG"