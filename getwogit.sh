#!/bin/bash

function get_dcupdater() {
    echo -e "Downloading Docker Compose Updater"
    curl -s -L --create-dirs -o ./update-compose.sh "https://raw.githubusercontent.com/vmstan/unifi-config/master/update-compose.sh?token=GHSAT0AAAAAABQTASPZ34CHL3FDJ5TR7ANMYRSDGAQ"
    chmod +x update-compose.sh
}

function get_dcbedrock() {
    echo -e "Downloading Bedrock Docker Compose"
    curl -s -L --create-dirs -o ./bedrock/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/mc-bedrock/docker-compose.yml?token=GHSAT0AAAAAABQTASPZNHPYMUSEM6TPASP6YRSDIBA"
}

function get_dcminecraft() {
    echo -e "Downloading Minecraft Java Docker Compose"
    curl -s -L --create-dirs -o ./minecraft/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/mc-java/docker-compose.yml?token=GHSAT0AAAAAABQTASPZGGGG6NWRVFWUGITIYRSDMFQ"
}

function get_dcdnsproxy() {
    echo -e "Downloading DNSPROXY Docker Compose"
    curl -s -L --create-dirs -o ./dnsproxy/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/dnsproxy/docker-compose.yml?token=GHSAT0AAAAAABQTASPYA2ZK7BG5TUEI77ZIYRSDLFQ"
}

function get_dchomebridge() {
    echo -e "Downloading Homebridge Docker Compose"
    curl -s -L --create-dirs -o ./homebridge/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/homebridge/docker-compose.yml?token=GHSAT0AAAAAABQTASPZN7EYNRWFZOP3J7YUYRSDOGA"
}

function get_dcpihole() {
    echo -e "Downloading Pihole Docker Compose"
    curl -s -L --create-dirs -o ./pihole/docker-compose.yml "https://raw.githubusercontent.com/vmstan/unifi-config/master/docker/pihole/docker-compose.yml?token=GHSAT0AAAAAABQTASPZAFRUGWUQWWWFAZW4YRSDOWQ"
}

function get_unboundconf() {
    echo -e "Downloading Unbound Configuration"
    curl -s -L --create-dirs -o /usr/local/etc/unbound/unbound.conf "https://raw.githubusercontent.com/vmstan/unifi-config/master/unbound/unbound.conf?token=GHSAT0AAAAAABQTASPYUEL7IPXJ5U6N66LCYRSD4SA"

}

get_dcupdater
get_dcbedrock
get_dcminecraft
get_dcdnsproxy
get_dchomebridge
get_dcpihole
get_unboundconf