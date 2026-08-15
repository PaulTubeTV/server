#!/bin/bash
set -e

# Alte Docker-Pakete entfernen
apt remove -y docker.io docker-compose docker-doc docker-buildx podman-docker containerd runc || true

# Paketquellen aktualisieren und Voraussetzungen installieren
apt update
apt install -y ca-certificates curl

# Docker-Keyring anlegen
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

# Docker-Repository hinzufügen
tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Paketquellen aktualisieren
apt update

# Docker installieren
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Docker beim Booten starten und jetzt starten
systemctl enable --now docker

# Installation testen
docker --version
docker compose version
docker run --rm hello-world
