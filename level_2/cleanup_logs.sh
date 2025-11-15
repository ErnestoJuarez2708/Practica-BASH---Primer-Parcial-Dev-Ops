#!/bin/bash

SOURCE_DIR="/home/ernesto/Practica-BASH---Primer-Parcial-Dev-Ops/level_2"
BACKUP_DIR="/home/ernesto/Practica-BASH---Primer-Parcial-Dev-Ops/level_2/backup/logs"
LOG_FILE="/home/ernesto/Practica-BASH---Primer-Parcial-Dev-Ops/level_2/logs_test.log"
DAYS_OLD=7

DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$DATE] Iniciando limpieza de logs..." >> "$LOG_FILE"

mkdir -p "$BACKUP_DIR" || {
    echo "[$DATE] ERROR: No se pudo crear $BACKUP_DIR" >> "$LOG_FILE"
    exit 1
}

[ -d "$SOURCE_DIR" ] || {
    echo "[$DATE] ERROR: $SOURCE_DIR no existe" >> "$LOG_FILE"
    exit 1
}


mapfile -t FILES < <(find "$SOURCE_DIR" -type f -mtime +$DAYS_OLD -print)

if [ ${#FILES[@]} -eq 0 ]; then
    echo "[$DATE] No se encontraron logs antiguos (más de $DAYS_OLD días)." >> "$LOG_FILE"
    echo "[$DATE] Limpieza completada: nada que hacer." >> "$LOG_FILE"
    echo "-------------------------------------------" >> "$LOG_FILE"
    exit 0
fi

BACKUP_NAME="logs_backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

echo "[$DATE] Comprimiendo ${#FILES[@]} archivos antiguos..." >> "$LOG_FILE"

printf '%s\0' "${FILES[@]}" | tar -czf "$BACKUP_PATH" --null -T - 2>>"$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "[$DATE] Logs comprimidos exitosamente en: $BACKUP_PATH" >> "$LOG_FILE"
    
    printf '%s\0' "${FILES[@]}" | xargs -0 rm -f
    echo "[$DATE] Archivos originales eliminados (${#FILES[@]} archivos)." >> "$LOG_FILE"
else
    echo "[$DATE] ERROR: Falló la compresión. No se eliminaron los archivos." >> "$LOG_FILE"
    echo "[$DATE] Verifica permisos y espacio en disco." >> "$LOG_FILE"
    exit 1
fi

echo "[$DATE] Limpieza completada con éxito." >> "$LOG_FILE"
echo "-------------------------------------------" >> "$LOG_FILE"
