#!/bin/bash

# Default image
IMAGE=docker.io/ttool/jupyterlab

# New genarations of container
# name
NAME=jupyterlab
# volume
MAIN=~/running/jupyterlab
mkdir -p ${MAIN} || exit 1
# mapped port, host:container
m_PORT=8988:8988/tcp # webui port

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 3 --name ${NAME} --userns=keep-id --network podman -v ${MAIN}:/home/master  -v /etc/localtime:/etc/localtime:r -p ${m_PORT} ${IMAGE} || exit 1

# Config
function config_jupyterlab() {
  # Check container
  podman container ls -a -f "name=^${NAME}$" | grep ${NAME} || (exit 1 && echo "No container $NAME")
  # Init jupyterlab configuration
  read -p "Type \"y\" to init jupyterlab on container $NAME: " -r YN
  if [[ $YN == "y" ]];then
    podman exec -it ${NAME} sh -c '''
    cp /usr/local/etc/jupyter/jupyter_server_config.json ~/.jupyter/jupyter_server_config.json
    jupyter-lab password
    '''
  else
    exit 0 
  fi
  podman exec ${NAME} sh -c '''
  find ~ -depth -type f -a -name .ipynb_checkpoints -exec rm -rf '{}' +
  '''
  # Finally, restart container
  podman stop --time 1 ${NAME} && sleep 1 && podman start ${NAME}
}

config_jupyterlab