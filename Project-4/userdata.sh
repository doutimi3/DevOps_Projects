#! usr/bin/bash

sudo apt update
sudo apt upgrade
# Add certificates
sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates

# Sets up the Node.js package repository for version 12.x on a Debian-based Linux distribution.
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

# Install NodeJS
sudo apt install -y nodejs

# Install Netstat utility to display network connections (Optional)
sudo apt-get update && sudo apt-get install net-tools


# Install mongodb
# downloads and adds a public key to the system's list of trusted keys, which is used to verify \
# the authenticity of packages during installation or upgrade in a Debian-based Linux distribution.
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
# Adds a new entry to the sources.list.d directory for the MongoDB package repository. 
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
Install MongoDB package
sudo apt install -y mongodb

# Start mongodb server
sudo service mongodb start
# Verify mongodb server is running
sudo systemctl status mongodb

# Install npm package manager
sudo apt install -y npm

# Install body-parser package
sudo npm install body-parser

