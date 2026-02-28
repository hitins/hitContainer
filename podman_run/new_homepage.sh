#!/bin/bash

# Default image
IMAGE=ghcr.io/gethomepage/homepage

# New genarations of container
# name
NAME=homepage
# volume
MAIN=~/running/homepage
CONFIG=${MAIN}/config
ICONS=${MAIN}/public/icons
IMAGES=${MAIN}/public/images
mkdir -p ${CONFIG} ${ICONS} ${IMAGES} || exit 1
# mapped port, host:container
m_PORT=3000:3000/tcp # http service
# ENV
read -p "Set homepage http URL or not:" -r URL
if [[ -n $URL ]]; then
    ENV="HOMEPAGE_ALLOWED_HOSTS=$URL"
else
    ENV="HOMEPAGE_ALLOWED_HOSTS=localhost:3000"
fi

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 3 --name ${NAME} -e $ENV -v ${CONFIG}:/app/config -v ${ICONS}:/app/public/icons -v ${IMAGES}:/app/public/images -v /etc/localtime:/etc/localtime:ro -p ${m_PORT} ${IMAGE} || exit 1
