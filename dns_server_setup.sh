#!/bin/bash
# Script para configurar servidor DNS local con dnsmasq

echo "=== Configurando Servidor DNS Local ==="

# 1. Actualizar sistema e instalar dnsmasq
echo "1. Instalando dnsmasq..."
sudo apt update
sudo apt install -y dnsmasq

# 2. Hacer backup de la configuración original
echo "2. Haciendo backup de configuración..."
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup

# 3. Configurar dnsmasq
echo "3. Configurando dnsmasq..."
sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
# Configuración DNS local para fiberops.com.pe

# Puerto de escucha (por defecto 53)
port=53

# Interfaz de red donde escuchar
interface=ens33
# Interfaz configurada para tu servidor Ubuntu

# No leer /etc/hosts automáticamente (opcional)
# no-hosts

# Configuración de dominio local
# Resolver fiberops.com.pe a 10.80.80.104
address=/fiberops.com.pe/10.80.80.104
address=/www.fiberops.com.pe/10.80.80.104

# Servidores DNS upstream (para otros dominios)
server=8.8.8.8
server=8.8.4.4
server=1.1.1.1

# Cache DNS
cache-size=1000

# Log para debugging
log-queries
log-facility=/var/log/dnsmasq.log
EOF

# 4. Configurar firewall (opcional pero recomendado)
echo "4. Configurando firewall..."
sudo ufw allow 53/udp
sudo ufw allow 53/tcp

# 5. Reiniciar dnsmasq
echo "5. Reiniciando dnsmasq..."
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq

# 6. Verificar estado
echo "6. Verificando configuración..."
sudo systemctl status dnsmasq --no-pager

# 7. Probar resolución local
echo "7. Probando resolución DNS..."
nslookup fiberops.com.pe 127.0.0.1
nslookup www.fiberops.com.pe 127.0.0.1

echo "=== Configuración DNS completada ==="
echo "El servidor DNS está configurado en la IP: $(hostname -I | awk '{print $1}')"
echo "Configura las máquinas cliente para usar esta IP como servidor DNS"
