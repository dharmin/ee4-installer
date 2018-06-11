#!/bin/bash
wget get.docker.com -O docker-setup.sh
sh docker-setup.sh

curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

readonly ee_linux_distro=$(lsb_release -i | awk '{print $3}')

# Checking linux distro
if [ "$ee_linux_distro" != "Ubuntu" ]; then
    apt-get install -y software-properties-common
    add-apt-repository -y ppa:ondrej/php
    apt-get update
    apt-get -y install php7.2-cli php7.2-curl php7.2-sqlite3
elif [ "$ee_linux_distro" != "Debian" ]; then
    apt-get update
    apt-get install apt-transport-https lsb-release ca-certificates language-pack-en-base -y
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
    apt-get update
    apt-get install php7.2-cli php7.2-curl php7.2-sqlite3 -y
fi