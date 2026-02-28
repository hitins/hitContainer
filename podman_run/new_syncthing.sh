#!/bin/bash

# Default image
IMAGE=docker.io/syncthing/syncthing

# New genarations of container
# name
NAME=syncthing
# volume
MAIN=/main/syncthing
mkdir -p ${MAIN}|| exit 1
# mapped port, host:container
m_TCP_PORT1=8384:8384/tcp # http service
m_TCP_PORT2=22000:22000/tcp # listen tcp port
m_UDP_PORT1=21027:21027/udp # dicovery port
m_UDP_PORT2=22000:22000/udp # optional, listen udp port

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
## Service use static IP, dicovery port is optional
podman run -d --restart on-failure --stop-timeout 3 --name ${NAME} --userns=keep-id -v ${MAIN}:/var/syncthing  -v /etc/localtime:/etc/localtime:ro -p ${m_TCP_PORT1} -p ${m_TCP_PORT2} -hostname=my-syncthing  ${IMAGE} || exit 1
