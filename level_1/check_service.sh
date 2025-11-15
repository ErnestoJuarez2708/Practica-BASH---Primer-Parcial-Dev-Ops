#!/bin/bash

# Verificar si se proporcionó un parámetro
if [ -z "$1" ]; then
    echo "Uso: ./check_service.sh <nombre_servicio>"
    exit 1
fi

SERVICE=$1
STATUS=$(systemctl is-active $SERVICE)

if [ "$STATUS" == "active" ]; then
    echo "El servicio $SERVICE está activo."
    RESULT="activo"
else
    echo "ALERTA: El servicio $SERVICE no está activo!"
    RESULT="inactivo"
fi

# Guardar en log
echo "$SERVICE: $RESULT" >> service_status.log
