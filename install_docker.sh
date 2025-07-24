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

# Actualiza e instala dependencias
apt update && apt upgrade -y || error "Failed to update packages."
apt install -y ca-certificates curl gnupg lsb-release || error "Failed to install dependencies."

# Agrega la clave GPG de Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg || error "Failed to add Docker GPG key."
chmod a+r /etc/apt/keyrings/docker.gpg

# Agrega el repositorio estable de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null || error "Failed to add Docker repo."

# Instala Docker Engine y Compose plugin
apt update || error "Failed to update package list after adding Docker repo."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error "Failed to install Docker."

# Crea el grupo docker si no existe
if ! getent group docker > /dev/null 2>&1; then
  groupadd docker || error "Failed to create 'docker' group."
fi

# Agrega al usuario actual al grupo docker
usermod -aG docker $(logname) || error "Failed to add user to the Docker usergroup."

echo -e "\\e[92mDocker and Docker Compose were installed successfully.\\e[39m"
echo -e "\\e[93mRemember to log out or reboot for the group changes to take effect.\\e[39m"
