#!/bin/bash

# Default image
IMAGE=docker.io/ttool/nginx

# New genarations of container
# name
NAME=nginx
# volume
HTTPD=~/running/nginx
mkdir -p ${HTTPD} || exit 1

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 3 --network=host --name ${NAME} -v ${HTTPD}:/etc/nginx/http.d -v /etc/localtime:/etc/localtime:ro ${IMAGE} || exit 1

echo "Info: Need set sysctl 'net.ipv4.ip_unprivileged_port_start = 443' for https"
