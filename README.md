# Práctica Bash Scripting - Primer Parcial DevOps

**Nombre:** Ernesto  
**Codigo:** 68763  
**Sistema:** Ubuntu LTS

---

## Nivel 1: Verificación de Servicios
- `check_service.sh`: Verifica estado con `systemctl`, log con timestamp, alerta por correo si falla.
- **Bonus**: Timestamp + notificación por `mail`.

---

## Nivel 2: Limpieza de Logs
- `cleanup_logs.sh`: Busca archivos >7 días, comprime en `.tar.gz`, elimina originales.
- **Bonus**: Configurado en `cron` para las **2:00 AM**.

---

## Nivel 3: Despliegue Automatizado
- `deploy_app.sh`: Clona o actualiza repo GitHub, reinicia `nginx`, log detallado.
- **Bonus**: Control de errores + notificación por **webhook (Discord/Slack)**.

---

## Nivel 4: Monitoreo y Alertas
- `monitor_system.sh`: Mide CPU, RAM, disco. Alerta si >80%.
- **Bonus**: Colores en terminal + histórico diario `metrics_YYYYMMDD.log`.

---

## Ejecución
```bash
# Nivel 1
./level_1/check_service.sh nginx

# Nivel 2 (prueba)
./level_2/cleanup_logs.sh

# Nivel 3 (con sudo)
sudo ./level_3/deploy_app.sh

# Nivel 4
./level_4/monitor_system.sh