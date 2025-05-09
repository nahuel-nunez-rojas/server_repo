#!/bin/bash

echo "🛑 Deteniendo contenedor Portainer..."
docker stop portainer

echo "🧼 Eliminando contenedor Portainer..."
docker rm portainer

echo "⬇️ Descargando última imagen de Portainer..."
docker pull portainer/portainer-ce:latest

echo "🚀 Iniciando nuevo contenedor Portainer..."
docker run -d \
  -p 8000:8000 \
  -p 9000:9000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/administrator/docker/portainer:/data \
  portainer/portainer-ce:latest

echo "✅ Portainer actualizado y corriendo."
