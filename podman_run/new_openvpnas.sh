#!/bin/bash

# Default image
IMAGE=docker.io/ttool/openvpnas

# New genarations of container
# name
NAME=openvpnas
# mapped port, host:container
m_PORT1=1943:943 # tcp web port
m_PORT2=1194:1194 # udp and tcp vpn port

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 5 --name ${NAME} -v /etc/localtime:/etc/localtime:ro -p ${m_PORT1} -p ${m_PORT2}/tcp -p ${m_PORT2}/udp --privileged ${IMAGE} || exit 1

echo " 1. Get password, Command 'cat /usr/local/openvpn_as/init.log'"
echo " 2. Init password, Command '/usr/local/openvpn_as/bin/ovpn-init'"
