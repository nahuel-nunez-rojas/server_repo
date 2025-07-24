#!/bin/bash
set -e

function error {
  echo -e "\e[91m$1\e[39m"
  exit 1
}

function check_internet() {
  printf "Checking if you are online... "
  wget -q --spider http://github.com
  if [ $? -eq 0 ]; then
    echo "Online. Continuing."
  else
    error "Offline. Go connect to the internet then run the script again."
  fi
}

function check_docker() {
  if ! command -v docker &> /dev/null; then
    error "Docker is not installed. Please install Docker first."
  fi
}

check_internet
check_docker

if [ "$(docker ps -aq -f name=^portainer$)" ]; then
  error "A container named 'portainer' already exists. Remove it first or use a different name."
fi

# Carpeta de configuración en el home
CONFIG_PATH="$HOME/docker/portainer"
mkdir -p "$CONFIG_PATH" || error "Failed to create the Portainer Config Folder"

docker pull portainer/portainer-ce:latest || error "Failed to pull latest Portainer docker image!"
docker run -d -p 9000:9000 -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$CONFIG_PATH":/data \
  portainer/portainer-ce:latest \