#!/bin/bash

# Default image
IMAGE=docker.io/jellyfin/jellyfin

# New genarations of container
# name
NAME=jellyfin
# volume
MAIN=~/running/jellyfin
CONF=${MAIN}/config 
CACHE=${MAIN}/cache 
MEDIA=/main/media
mkdir -p ${CONF} ${CACHE} ${MEDIA} || exit 1
# mapped port, host:container
m_PORT=8096:8096/tcp # http service
# Device
DEVICE=/dev/dri/renderD128 # GPU hardware acceleration

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 3 --name ${NAME} --userns=keep-id -v ${CONF}:/config -v ${CACHE}:/cache --mount type=bind,source=${MEDIA},destination=/media,ro=true --publish ${m_PORT} --device ${DEVICE} ${IMAGE} || exit 1

# Config
function config_jellyfin() {
  # Check container
  podman container ls -a -f "name=^${NAME}$" | grep ${NAME} || (exit 1 && echo "No container $NAME")
  podman exec --user root ${NAME} sh -c "apt -y update && apt -y dist-upgrade && apt -y install fonts-noto-cjk && apt -y autoremove && apt -y autoclean && apt -y clean all"
  echo "Important Info: podman owner user need add group 'render' for hardware, eg 'usermod -aG render jellyfin'"
  # Finally, restart container
  podman stop --time 1 ${NAME} && sleep 1 && podman start ${NAME}
}

config_jellyfin
