#!/bin/bash
# Script para resolver conflicto de puerto 53 con systemd-resolved

echo "=== Resolviendo conflicto de puerto DNS ==="

# 1. Verificar qué está usando el puerto 53
echo "1. Verificando qué servicios usan el puerto 53..."
sudo netstat -tulpn | grep :53
sudo ss -tulpn | grep :53

# 2. Verificar estado de systemd-resolved
echo "2. Verificando estado de systemd-resolved..."
sudo systemctl status systemd-resolved --no-pager

# 3. Detener systemd-resolved temporalmente
echo "3. Deteniendo systemd-resolved..."
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# 4. Crear enlace simbólico para /etc/resolv.conf
echo "4. Configurando /etc/resolv.conf..."
sudo rm /etc/resolv.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# 5. Configurar dnsmasq para usar el puerto 53
echo "5. Configurando dnsmasq..."
sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
# Configuración DNS local para fiberops.com.pe

# Puerto de escucha
port=53

# Interfaz de red donde escuchar
interface=ens33

# Configuración de dominio local
address=/fiberops.com.pe/10.80.80.104
address=/www.fiberops.com.pe/10.80.80.104

# Servidores DNS upstream
server=8.8.8.8
server=8.8.4.4
server=1.1.1.1

# Cache DNS
cache-size=1000

# Log para debugging
log-queries
log-facility=/var/log/dnsmasq.log
EOF

# 6. Reiniciar dnsmasq
echo "6. Reiniciando dnsmasq..."
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq

# 7. Verificar estado
echo "7. Verificando configuración..."
sudo systemctl status dnsmasq --no-pager

# 8. Probar resolución
echo "8. Probando resolución DNS..."
nslookup fiberops.com.pe 127.0.0.1
nslookup www.fiberops.com.pe 127.0.0.1

echo "=== Configuración completada ==="
echo "dnsmasq está funcionando en el puerto 53"
echo "Configura las máquinas cliente para usar 10.80.80.104 como DNS"
