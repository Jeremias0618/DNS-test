#!/bin/bash
# Comandos para ejecutar en el servidor Ubuntu 22.04

echo "=== Configurando dominio local fiberops.com.pe ==="

# 1. Editar archivo hosts
echo "1. Configurando archivo hosts..."
sudo cp /etc/hosts /etc/hosts.backup
echo "10.80.80.104 fiberops.com.pe" | sudo tee -a /etc/hosts
echo "10.80.80.104 www.fiberops.com.pe" | sudo tee -a /etc/hosts

# 2. Crear configuración de Virtual Host
echo "2. Creando Virtual Host para Apache..."
sudo tee /etc/apache2/sites-available/fiberops.com.pe.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName fiberops.com.pe
    ServerAlias www.fiberops.com.pe
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/fiberops_error.log
    CustomLog \${APACHE_LOG_DIR}/fiberops_access.log combined
</VirtualHost>
EOF

# 3. Activar el sitio
echo "3. Activando sitio en Apache..."
sudo a2ensite fiberops.com.pe.conf
sudo systemctl reload apache2

# 4. Verificar configuración
echo "4. Verificando configuración..."
echo "Archivo hosts:"
cat /etc/hosts | grep fiberops

echo "Sitios activos en Apache:"
sudo a2ensite

echo "Estado de Apache:"
sudo systemctl status apache2 --no-pager

echo "=== Configuración completada ==="
echo "Ahora puedes acceder a http://fiberops.com.pe desde las máquinas de la red local"
