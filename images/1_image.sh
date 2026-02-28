#!/bin/bash

# Choose image
echo "Built image list"
IMGS=([1]=adguardhome [2]=jupyterlab [3]=nginx [4]=openvpnas [5]=python3 [6]=qbittorrent [7]=samba)
for key in ${!IMGS[*]};do
    echo "$key : ${IMGS[$key]}"
done
read -p "Choose new image serial number: " -r SN
([[ -v IMGS[$SN] ]] && echo "Choose image: ${IMGS[$SN]}") || (echo "No serial number: $SN, and exit.";exit 0)

# Check image build tool
if [[ $(ls /bin/buildah) ]];then	
	BUD=buildah
elif [[ $(ls /bin/podman) ]];then
	BUD=podman
else
	echo "No container image build tool"
	exit 1
fi

# Build image
$BUD build -f ${IMGS[$SN]}_Dockerfile --no-cache --squash -t docker.io/ttool/${IMGS[$SN]}:latest
