#!/bin/bash

# list of FQDN
CHECK_NODES=$(cat <<EOF
google.com
github.com
microsoft.com
EOF
)

for NODE in $CHECK_NODES ; do
  # echo "Pinging $NODE"
  # NOTE: the options of ping command is different on mingw/github shell on Windows
  ping -c 1 $NODE 2>&1 | tee /tmp/a.txt > /dev/null
  # ping -n 1 $NODE 2>&1 | tee /tmp/a.txt > /dev/null
  cat /tmp/a.txt
  # NOTE: the format of ping output is different on mingw/github shell on Windows
  TARGET_IP=$(sed -n 's|Pinging \([^ ]*\) \[\([0-9.][0-9.]*\)\] .*$|\2|p' /tmp/a.txt  )
  # echo "TARGET_IP=${TARGET_IP}"
  if [ "$TARGET_IP" == "" ] ; then
    TARGET_IP=$(sed -n 's|PING \([^ ]*\) (\([0-9.][0-9.]*\)) .*$|\2|p' /tmp/a.txt  )
  fi
  TARGET_HOSTNAME=$(echo $NODE|sed 's|\..*$||g')
  echo -e "$TARGET_HOSTNAME\t$TARGET_IP"
done  
