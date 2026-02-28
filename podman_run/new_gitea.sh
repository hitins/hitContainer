#!/bin/bash

# Default image
IMAGE=docker.io/gitea/gitea

# New genarations of container
# name
NAME=gitea
# volume
MAIN=~/running/gitea
mkdir -p ${MAIN}|| exit 1
# mapped port, host:container
m_PORT=3001:3000/tcp # http service
# ENV
ENV1="USER_UID=1000"
ENV2="USER_GID=1000"

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 3 --name ${NAME} -e $ENV1 -e $ENV2 -v ${MAIN}:/data -v /etc/localtime:/etc/localtime:ro -p ${m_PORT} ${IMAGE} || exit 1
