#!/bin/bash

function get_dcupdater() {
    echo -e "Downloading Docker Compose Updater"
    curl -s -L --create-dirs -o ./update-compose.sh "https://raw.githubusercontent.com/vmstan/unifi-config/master/update-compose.sh"
    chmod +x update-compose.sh
}

function get_dcbedrock() {
    echo -e "Downloading Bedrock Docker Compose"
    curl -s -L --create-dirs -o ./bedrock/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/mc-bedrock/docker-compose.yml"
}

function get_dcminecraft() {
    echo -e "Downloading Minecraft Java Docker Compose"
    curl -s -L --create-dirs -o ./minecraft/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/mc-java/docker-compose.yml"
}

function get_dcdnsproxy() { 
    echo -e "Downloading DNSPROXY Docker Compose"
    curl -s -L --create-dirs -o ./dnsproxy/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/dnsproxy/docker-compose.yml"
}

function get_dchomebridge() {
    echo -e "Downloading Homebridge Docker Compose"
    curl -s -L --create-dirs -o ./homebridge/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/homebridge/docker-compose.yml"
}

function get_dcpihole() {
    echo -e "Downloading Pihole Docker Compose"
    curl -s -L --create-dirs -o ./pihole/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/pihole/docker-compose.yml"
}

function get_unboundconf() {
    echo -e "Downloading Unbound Configuration"
    curl -s -L --create-dirs -o /usr/local/etc/unbound/unbound.conf "https://raw.githubusercontent.com/vmstan/unifi-config/master/unbound/unbound.conf"
}

get_dcupdater
get_dcbedrock
get_dcminecraft
get_dcdnsproxy
get_dchomebridge
get_dcpihole
get_unboundconf