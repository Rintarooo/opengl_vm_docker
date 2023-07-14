#!/bin/bash
# install
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install docker-compose -y
# https://heppoko-room.net/archives/1892
VER=v2.20.0
docker-compose -v
echo "install ${VER}"
sudo rm -rf /usr/bin/docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/$VER/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose -v