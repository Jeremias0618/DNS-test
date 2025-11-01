#!/bin/bash
# Script para agregar nuevos dominios al servidor DNS local

echo "=== Agregando nuevo dominio al DNS local ==="

# Solicitar información del nuevo dominio
read -p "Ingresa el nuevo dominio (ej: mipagina.com): " NEW_DOMAIN
read -p "Ingresa la IP de destino (ej: 192.168.1.100): " NEW_IP

# Verificar que se ingresaron los datos
if [ -z "$NEW_DOMAIN" ] || [ -z "$NEW_IP" ]; then
    echo "Error: Debes ingresar tanto el dominio como la IP"
    exit 1
fi

echo "Agregando: $NEW_DOMAIN -> $NEW_IP"

# 1. Hacer backup de la configuración actual
echo "1. Haciendo backup de configuración..."
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup.$(date +%Y%m%d_%H%M%S)

# 2. Agregar el nuevo dominio a la configuración
echo "2. Agregando nuevo dominio..."
echo "# Dominio agregado: $NEW_DOMAIN" | sudo tee -a /etc/dnsmasq.conf
echo "address=/$NEW_DOMAIN/$NEW_IP" | sudo tee -a /etc/dnsmasq.conf
echo "address=/www.$NEW_DOMAIN/$NEW_IP" | sudo tee -a /etc/dnsmasq.conf

# 3. Reiniciar dnsmasq
echo "3. Reiniciando dnsmasq..."
sudo systemctl restart dnsmasq

# 4. Verificar que esté funcionando
echo "4. Verificando configuración..."
sudo systemctl status dnsmasq --no-pager

# 5. Probar resolución del nuevo dominio
echo "5. Probando resolución del nuevo dominio..."
nslookup $NEW_DOMAIN 127.0.0.1
nslookup www.$NEW_DOMAIN 127.0.0.1

echo "=== Dominio agregado exitosamente ==="
echo "El dominio $NEW_DOMAIN ahora resuelve a $NEW_IP"
echo "Las máquinas cliente pueden acceder a http://$NEW_DOMAIN"
