# Local DNS Test

[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%2B-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Linux](https://img.shields.io/badge/Linux-Clients-000000?logo=linux&logoColor=white)](https://www.kernel.org/)
[![Windows](https://img.shields.io/badge/Windows-Clients-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![dnsmasq](https://img.shields.io/badge/dnsmasq-2.x-2D2D2D)](https://thekelleys.org.uk/dnsmasq/doc.html)
[![Apache](https://img.shields.io/badge/Apache-HTTP%20Server-D22128?logo=apache&logoColor=white)](https://httpd.apache.org/)
[![Repo Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FJeremias0618%2FDNS-test&title=Repo%20Hits&edge_flat=false)](https://hits.seeyoufarm.com)

Plataforma de pruebas para un resolver DNS local autoritativo apoyado en `dnsmasq`, enfocada en publicar `fiberops.com.pe` dentro de un segmento LAN controlado y validar la resolución desde estaciones Linux y Windows.

## Arquitectura de referencia

- **Servidor Ubuntu** (10.80.80.104): ejecuta `dnsmasq` como cache y autoridad para `fiberops.com.pe`; opcionalmente sirve contenido HTTP mediante Apache usando `fiberops_virtualhost.conf`.
- **Clientes Linux/Windows**: consumen el DNS local vía configuración del resolver o edición de hosts, apuntando al puerto UDP/TCP 53 del servidor.
- **DNS upstream**: Google (8.8.8.8, 8.8.4.4) y Cloudflare (1.1.1.1) actúan como resolvers recursivos para dominios externos.

## Requisitos previos

- Ubuntu Server 20.04+ con privilegios sudo, `ufw` habilitado y acceso a Internet para instalación de paquetes.
- Clientes con permisos de administrador para modificar DNS (`netplan`, `NetworkManager`, `Set-DnsClientServerAddress`, etc.).
- Puerto 53 libre o gestionado mediante el script `fix_dnsmasq_conflict.sh` en caso de coexistir `systemd-resolved`.

## Alcance funcional

- **Provisioning**: instalación end-to-end de `dnsmasq`, hardening de firewall, habilitación de logging y caché.
- **Automatización**: alta interactiva de dominios A y WWW adicionales en `dnsmasq.conf` con control de versiones mediante backups incrementales.
- **Documentación operacional**: guías prescriptivas para configurar resolvers en Linux/Windows, validar conectividad y depurar conflictos de puertos.

## Recursos clave

- `dns_server_setup.sh`: instala dependencias, genera `/etc/dnsmasq.conf`, abre puertos `ufw` y ejecuta smoke tests (`nslookup`).
- `fix_dnsmasq_conflict.sh`: deshabilita `systemd-resolved`, reconfigura `/etc/resolv.conf` y reprovisiona la configuración DNS local.
- `add_new_domain.sh`: appends controlado de registros `address=/dominio/IP` al `dnsmasq.conf` con reinicio controlado del servicio.
- `fiberops_virtualhost.conf`: VirtualHost Apache listo para habilitar vía `a2ensite`, apuntando a `/var/www/html`.
- `hosts_config.txt`: plantilla para garantizar que el servidor resuelva el dominio de forma interna al bootstrap.

## Operación paso a paso

1. Ejecutar `sudo bash dns_server_setup.sh` y confirmar estado `systemctl status dnsmasq` sin errores.
2. Si existe conflicto en 53, lanzar `sudo bash fix_dnsmasq_conflict.sh` para liberar el puerto y regenerar la configuración.
3. (Opcional) Instalar Apache y aplicar `fiberops_virtualhost.conf` (`sudo a2ensite`, `sudo systemctl reload apache2`).
4. Propagar registro de dominio adicional con `sudo bash add_new_domain.sh` cuando sea necesario.
5. Distribuir guías correspondientes a los clientes y establecer el DNS local como primario.

## Configuración de clientes

- Linux (`dns_client_config_linux.txt`): incluye métodos con Netplan (`/etc/netplan/*.yaml`), `resolv.conf` estático y `nmcli`/NetworkManager. Cada procedimiento finaliza con `netplan apply` o reinicio de la conexión.
- Windows (`dns_client_config_windows.txt`): describe interfaz gráfica, comandos PowerShell `Set-DnsClientServerAddress` y comandos de validación (`ipconfig`, `nslookup`).
- Edición directa de hosts (`client_config_windows.txt`): alternativa para laboratorios sin cambiar DNS global.

## Validación y observabilidad

- `dns_verification_commands.txt` consolida pruebas: `nslookup`, `dig`, `host`, `ping`, `telnet`, `nmap`, así como seguimiento de logs con `tail -f /var/log/dnsmasq.log` y captura de paquetes (`tcpdump -i any port 53`).
- Confirmar que `dnsmasq --test` retorne `syntax check OK` antes de reinicios.
- Verificar apertura de puertos con `sudo ss -tulpn | grep :53`.

## Solución de problemas

- Conflictos de servicio: detener `systemd-resolved` y reenlazar `/etc/resolv.conf` al archivo generado.
- Errores NXDOMAIN: revisar logs de `dnsmasq`, validar la existencia de entradas `address=/dominio/IP` y flushear caché cliente (`ipconfig /flushdns` o `systemd-resolve --flush-caches`).
- Conectividad: comprobar reachability con `ping 10.80.80.104` y analizar latencia mediante `traceroute` o `pathping`.

## Métricas del proyecto

- Scripts de automatización: 3
- Guías de configuración cliente: 4
- Archivos de soporte (Apache + hosts + verificación): 3

