#!/bin/bash

# Default image
IMAGE=docker.io/ttool/qbittorrent

# New genarations of container
# name
NAME=qbittorrent
# volume
DOWNLOAD=/main/dl
mkdir -p ${DOWNLOAD} || exit 1
# mapped port, host:container
m_PORT1=8088:8080/tcp # webui port
m_PORT2=10301:10301/tcp # listen port

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 3 --userns=keep-id --name ${NAME} -v ${DOWNLOAD}:/home/qb/Downloads -v /etc/localtime:/etc/localtime:ro -p ${m_PORT1} -p ${m_PORT2} ${IMAGE} || exit 1
