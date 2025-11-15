#!/bin/bash

REPO_URL="https://github.com/rayner-villalba-coderoad-com/clash-of-clan"
APP_DIR="/var/www/clash-of-clan"
LOG_FILE="/home/ernesto/Practica-BASH---Primer-Parcial-Dev-Ops/level_3/deploy.log"
SERVICE="nginx"
BRANCH="main"

[ "$(id -u)" -eq 0 ] || {
    echo "[ERROR] Este script debe ejecutarse con sudo" | tee -a "$LOG_FILE"
    exit 1
}

DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "===== Despliegue iniciado: $DATE =====" | tee -a "$LOG_FILE"

mkdir -p "$(dirname "$APP_DIR")"

if [ ! -d "$APP_DIR" ]; then
    echo "[INFO] Clonando repositorio en $APP_DIR..." | tee -a "$LOG_FILE"
    git clone "$REPO_URL" "$APP_DIR" 2>&1 | tee -a "$LOG_FILE"
    CLONE_EXIT=${PIPESTATUS[0]}
    if [ $CLONE_EXIT -ne 0 ]; then
        echo "[ERROR] Falló git clone (código: $CLONE_EXIT)" | tee -a "$LOG_FILE"
        exit 1
    fi
else
    echo "[INFO] Actualizando repositorio en $APP_DIR..." | tee -a "$LOG_FILE"
    cd "$APP_DIR" || {
        echo "[ERROR] No se pudo entrar a $APP_DIR" | tee -a "$LOG_FILE"
        exit 1
    }

    git rev-parse --git-dir > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "[ERROR] $APP_DIR no es un repositorio Git válido" | tee -a "$LOG_FILE"
        exit 1
    fi

    git fetch origin 2>&1 | tee -a "$LOG_FILE"
    git checkout "$BRANCH" 2>&1 | tee -a "$LOG_FILE"
    git pull origin "$BRANCH" 2>&1 | tee -a "$LOG_FILE"
    PULL_EXIT=${PIPESTATUS[2]}
    if [ $PULL_EXIT -ne 0 ]; then
        echo "[ERROR] Falló git pull (código: $PULL_EXIT)" | tee -a "$LOG_FILE"
        exit 1
    fi
fi

echo "[INFO] Ajustando permisos para www-data..." | tee -a "$LOG_FILE"
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 "$APP_DIR"

echo "[INFO] Reiniciando servicio: $SERVICE..." | tee -a "$LOG_FILE"
systemctl restart "$SERVICE" 2>&1 | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
    systemctl is-active --quiet "$SERVICE" && {
        echo "[OK] Servicio $SERVICE reiniciado y activo." | tee -a "$LOG_FILE"
        EXIT_MSG="Despliegue exitoso en $(hostname) - $(date '+%H:%M')"
    } || {
        echo "[ERROR] Servicio reiniciado pero no está activo." | tee -a "$LOG_FILE"
        EXIT_MSG="Falló: servicio $SERVICE no activo tras reinicio"
    }
else
    echo "[ERROR] Falló el reinicio del servicio $SERVICE" | tee -a "$LOG_FILE"
    EXIT_MSG="Falló: no se pudo reiniciar $SERVICE"
fi

DATE_END=$(date '+%Y-%m-%d %H:%M:%S')
echo "===== Despliegue finalizado: $DATE_END =====" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "$EXIT_MSG"
