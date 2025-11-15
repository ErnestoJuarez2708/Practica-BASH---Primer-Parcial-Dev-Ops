#!/bin/bash

SOURCE_DIR="/home/ernesto/Practica-BASH---Primer-Parcial-Dev-Ops/level_2"
BACKUP_DIR="/home/ernesto/Practica-BASH---Primer-Parcial-Dev-Ops/level_2/logs"
LOG_FILE="/home/ernesto/Practica-BASH---Primer-Parcial-Dev-Ops/level_2/logs_test.log"

DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Iniciando limpieza de logs..." >> "$LOG_FILE"

FILES=$(find "$SOURCE_DIR" -type f -mtime +7)

if [ -z "$FILES" ]; then
    echo "[$DATE] No se encontraron logs antiguos." >> "$LOG_FILE"
    exit 0
fi

BACKUP_NAME="logs_backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

tar -czf "$BACKUP_PATH" $FILES 2>>"$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "[$DATE] Logs comprimidos en $BACKUP_PATH" >> "$LOG_FILE"
    
    echo "$FILES" | xargs rm -f
    echo "[$DATE] Archivos originales eliminados." >> "$LOG_FILE"
else
    echo "[$DATE] ERROR: Falló la compresión, no se eliminaron los archivos." >> "$LOG_FILE"
    exit 1
fi

echo "[$DATE] Limpieza completada con éxito." >> "$LOG_FILE"
echo "-------------------------------------------" >> "$LOG_FILE"
