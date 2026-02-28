#!/bin/bash

# Default image
IMAGE=docker.io/ttool/adguardhome

# New genarations of container
# name
NAME=adguardhome
# volume
WORK=~/running/adguardhome
mkdir -p ${WORK} || exit 1
# mapped port, host:container
m_PORT1=3030:3000 # panel port
m_PORT2=5943:443 # doh/https port
<<COMMENT
-p 53:53/tcp -p 53:53/udp: plain DNS.
-p 67:67/udp -p 68:68/tcp -p 68:68/udp: use AdGuard Home as a DHCP server.
-p 80:80/tcp -p 443:443/tcp -p 443:443/udp -p 3000:3000/tcp: use AdGuard Home's admin panel as well as run AdGuard Home as an HTTPS/DNS-over-HTTPS server.
-p 3000:3000/tcp: use AdGuard Home admin panel
-p 853:853/tcp: run AdGuard Home as a DNS-over-TLS server.
-p 784:784/udp -p 853:853/udp -p 8853:8853/udp: run AdGuard Home as a DNS-over-QUIC server. You may only leave one or two of these.
-p 5443:5443/tcp -p 5443:5443/udp: run AdGuard Home as a DNSCrypt server.
COMMENT

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME} && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 3 --name ${NAME} -v ${WORK}:/opt/AdGuardHome/work -v /etc/localtime:/etc/localtime:ro -p ${m_PORT1} -p ${m_PORT2} ${IMAGE} || exit 1
