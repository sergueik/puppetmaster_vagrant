#!/bin/bash

BOXES=( default centos-66-x64 debian-78-x64 debian-82-x64 ubuntu-1404-x64 ubuntu-1604-x64 )

for BOX in "${BOXES[@]}"
do
  PUPPET_INSTALL_TYPE="agent" BEAKER_set="${BOX}" bundle exec rake beaker
done
