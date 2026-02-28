#!/bin/bash

# Default image
IMAGE=docker.io/library/postgres

# New genarations of container
# name
NAME=postgres
# volume
DATA=~/running/postgres
mkdir -p ${DATA} || exit 1
# mapped port, host:container
m_PORT=5432:5432 # db port
# ENV
ENV='POSTGRES_PASSWORD="postgres"'

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 3 --name ${NAME} -v ${DATA}:/var/lib/postgresql/data -v /etc/localtime:/etc/localtime:ro -e $ENV -p ${m_PORT} ${IMAGE} || exit 1

# Config
function config_postgres() {
  # Check container
  podman container ls -a -f "name=^${NAME}$" | grep ${NAME} || (exit 1 && echo "No container $NAME")
  # Set default password
  read -p "Type \"y\" to change default user \"postgres\" password: " -r YN
  if [[ $YN == "y" ]];then
    read -p "Type user \"postgres\" password:" -r pw_postgres
    podman exec ${NAME} psql -U postgres --command  "alter user postgres with password '${pw_postgres}';"
  else
    exit 0  
  fi  
  # Finally, restart container
  podman stop --time 3 ${NAME} && sleep 1 && podman start ${NAME}
}

config_postgres