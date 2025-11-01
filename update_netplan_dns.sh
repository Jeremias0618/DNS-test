#!/bin/bash
# Script para actualizar netplan con configuración DNS local

echo "=== Actualizando configuración de red ==="

# 1. Hacer backup de la configuración actual
echo "1. Haciendo backup de netplan..."
sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.backup

# 2. Crear nueva configuración de netplan
echo "2. Creando nueva configuración de netplan..."
sudo tee /etc/netplan/01-netcfg.yaml > /dev/null <<EOF
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        ens33:
            dhcp4: no
            addresses:
              - 10.80.80.104/24   # Dirección IP estática
            routes:
              - to: default
                via: 10.80.80.1   # Dirección IP del gateway
            nameservers:
                addresses:
                  - 127.0.0.1     # DNS local (dnsmasq)
                  - 8.8.8.8       # DNS de respaldo
                  - 1.1.1.1       # DNS alternativo
EOF

# 3. Aplicar configuración
echo "3. Aplicando configuración de red..."
sudo netplan apply

# 4. Verificar configuración
echo "4. Verificando configuración DNS..."
cat /etc/resolv.conf

echo "=== Configuración de red actualizada ==="
echo "El servidor ahora usa dnsmasq como DNS local"
