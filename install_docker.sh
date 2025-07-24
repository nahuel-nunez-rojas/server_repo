#!/bin/bash

function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

function check_internet() {
  printf "Checking if you are online..."
  wget -q --spider http://github.com
  if [ $? -eq 0 ]; then
    echo "Online. Continuing."
  else
    error "Offline. Go connect to the internet then run the script again."
  fi
}
# Verifica que se ejecute como root
if [ "$EUID" -ne 0 ]; then
  error "Please run this script as root (e.g., with sudo)."
fi

check_internet

curl -sSL https://get.docker.com | sh || error "Failed to install Docker."

# Crea el grupo docker si no existe
if ! getent group docker > /dev/null 2>&1; then
  groupadd docker || error "Failed to create 'docker' group."
fi

# Agrega al usuario actual al grupo docker
usermod -aG docker $(logname) || error "Failed to add user to the Docker usergroup."

echo "Remember to log off or reboot for the changes to take effect."