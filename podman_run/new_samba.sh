#!/bin/bash

# Default image
IMAGE=docker.io/ttool/samba

# New genarations of container
# name
NAME=samba
# volume
MAIN=~/running/samba
CLOUD=/main
mkdir -p ${MAIN} ${CLOUD} || exit 1
# mapped port, host:container
m_PORT=445:445/tcp

# Del existed container $NAME 
podman container ls -a -f "name=^${NAME}$" | grep ${NAME} && (podman rm -f --time 1 ${NAME}  && sleep 1 || exit 1) || echo "No existed container $NAME"
# New container
podman run -d --restart on-failure --stop-timeout 3 --name ${NAME} -v ${MAIN}:/smbd/ -v ${CLOUD}:/smbd/cloud/ -v /etc/localtime:/etc/localtime:ro -p ${m_PORT} ${IMAGE} || exit 1

echo "Info: Need set sysctl 'net.ipv4.ip_unprivileged_port_start = 445' for samba"

# Config
#!/bin/bash

function config_samba() {
  # Check container
  podman container ls -a -f "name=^${NAME}$" | grep ${NAME} || (exit 1 && echo "No container $NAME")
  # Set default manager "cloud" password
  read -p "Type \"y\" to set samba user \"cloud\" password: " -r CLOUD
  ([[ $CLOUD == "y" ]] && podman exec -it ${NAME} ash -c "pdbedit -L |grep cloud || /usr/bin/smbpasswd -a cloud") || exit 0
  # Set container users
  podman exec ${NAME} ash -c '''
  apk --no-cache upgrade
  # Set smbd users
  mkdir -p /smbd/user.bak && chmod 0750 /smbd/user.bak
  [[ -f "/var/lib/samba/private/passdb.tdb" ]] || touch /var/lib/samba/private/passdb.tdb
  [[ -f "/smbd/user.bak/passdb.tdb" ]] || mv /var/lib/samba/private/passdb.tdb /smbd/user.bak/ 
  ln -sf /smbd/user.bak/passdb.tdb /var/lib/samba/private/passdb.tdb
  [[ -f "/var/lib/samba/private/secrets.tdb" ]] || touch /var/lib/samba/private/secrets.tdb
  [[ -f "/smbd/user.bak/secrets.tdb" ]] || mv /var/lib/samba/private/secrets.tdb /smbd/user.bak/ 
  ln -sf /smbd/user.bak/secrets.tdb /var/lib/samba/private/secrets.tdb
  [[ -f "/smbd/user.bak/passwd" ]] || mv /etc/passwd /smbd/user.bak/
  ln -sf /smbd/user.bak/passwd /etc/
  [[ -f "/smbd/user.bak/group" ]] || mv /etc/group /smbd/user.bak/
  ln -sf /smbd/user.bak/group /etc/
  '''

  # Finally, restart and tips
  podman stop --time 1 $NAME && sleep 1 && podman start $NAME
  
  echo 'Info: Linux client with password eg: "mount -t cifs //SAMBA/SHARE /MOUNT -o username=xx,password=xx,uid=USER,gid=USER"'
  echo 'Info: Linux client with cred eg: mount -t cifs -o "rw,credentials=/works/smb.cred,uid=work,gid=work,file_mode=0644,dir_mode=0755" //SAMBA/SHARE /MOUNT'
}

config_samba
