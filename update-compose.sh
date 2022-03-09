#!/bin/bash

DOCKER_VERSION=$(docker compose version)
echo -e "Pre:  $DOCKER_VERSION"

DOWNLOAD_ARCH=""
case $(uname -m) in
    x86_64) DOWNLOAD_ARCH="x86_64" ;;
    aarch64) DOWNLOAD_ARCH="aarch64" ;;
esac

DOCKER_PLUGINS=$HOME/.docker/cli-plugins
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/docker/compose/releases/latest \
        | grep browser_download_url \
        | grep docker-compose-linux-$DOWNLOAD_ARCH \
        | grep -v sha256 \
        | cut -d '"' -f 4)
curl -s -L --create-dirs -o $DOCKER_PLUGINS/docker-compose "$DOWNLOAD_URL"
chmod +x $DOCKER_PLUGINS/docker-compose

DOCKER_VERSION=$(docker compose version)
echo -e "Post: $DOCKER_VERSION"