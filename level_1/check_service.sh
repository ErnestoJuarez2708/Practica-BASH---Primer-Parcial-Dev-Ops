#!/bin/bash

if [ -z "$1" ]; then
    echo "Uso: ./check_service.sh <nombre_servicio>"
    exit 1
fi

SERVICE=$1
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
STATUS=$(systemctl is-active $SERVICE)

if [ "$STATUS" == "active" ]; then
    echo "El servicio $SERVICE está activo."
    RESULT="activo"
else
    echo "ALERTA: El servicio $SERVICE no está activo!"
    RESULT="inactivo"
    echo "ALERTA: $SERVICE no está activo en $TIMESTAMP" | mail -s "Alerta de Servicio" ernestojuarezgutierrez03@gmail.com
fi

echo "[$TIMESTAMP] $SERVICE: $RESULT" >> service_status.log



