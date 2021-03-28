#!/bin/sh
# based on: https://medium.com/nuances-of-programming/%D0%BA%D0%B0%D0%BA-%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B8%D1%82%D1%8C-docker-%D0%B8-windows-subsystem-for-linux-wsl-%D0%B8%D1%81%D1%82%D0%BE%D1%80%D0%B8%D1%8F-%D0%BE-%D0%BB%D1%8E%D0%B1%D0%B2%D0%B8-5259c1e90589 (in Russian)

# This script uses VirtualBox NAT port forwarding to make all Docker services
# available on Windows host under `localhost`
DEFAULT_VIRTUALBOX_PATH='c:\\Program Files\\Oracle\\VirtualBox'
WINDOWS_VIRTUALBOX_PATH=${1:-$DEFAULT_VIRTUALBOX_PATH}


BASH_VIRTULBOX_PATH=$(echo $WINDOWS_VIRTULBOX_PATH| sed 's|\\|/|g;s|^\([a-z]\):|/\1|i' )
VBXMGMT="${BASH_VIRTULBOX_PATH}/VBoxManage.exe"
if [ ! -e $VBOXMGMT ] ; then
  echo "VBoxManage.exe not found under specified path ${WINDOWS_VIRTUALBOX_PATH}"
  exit 1
fi
# List running containers
docker ps -q | while read -r CONTAINER_ID; do
  # List ports bound by specific container
  for PORT in $(docker port $CONTAINER_ID | cut -d '-' -f 1 ); do
    PORT_NUM=$(echo $PORT | cut -d '/' -f 1 )
    PORT_TYPE=$(echo $PORT | cut -d '/' -f 2 )
    echo "Create rule natpf1 for ${PORT_TYPE} port ${PORT_NUM}"
    $VBXMGMT controlvm 'default' natpf1 "${PORT_TYPE}-port${PORT_NUM},${PORT_TYPE},,${PORT_NUM},,${PORT_NUM}"
  done
done

