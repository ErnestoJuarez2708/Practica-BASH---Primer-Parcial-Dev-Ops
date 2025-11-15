#!/bin/bash

# Verificar si se proporcionó un parámetro
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
    # Enviar notificación por correo (cambia el email)
    echo "ALERTA: $SERVICE no está activo en $TIMESTAMP" | mail -s "Alerta de Servicio" ernestojuarezgutierrez03@gmail.com
fi

# Guardar en log con timestamp
echo "[$TIMESTAMP] $SERVICE: $RESULT" >> service_status.log



