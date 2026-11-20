#!/bin/bash
# Boot script for the get-ip VM: install Docker, open 8080, run the image.
set -eu
fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
netfilter-persistent save || true
apt-get update
apt-get install -y docker.io
echo '${token}' | docker login ${registry} -u '${username}' --password-stdin
docker run -d --name get-ip --restart=always --network host -e APP_ENV=production ${image}
