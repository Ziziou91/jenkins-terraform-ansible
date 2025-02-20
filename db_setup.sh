#!/bin/bash

# update
echo updating...
sudo apt update -y
echo DONE update
 
# upgrade
echo upgrade packages...
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
echo DONE upgrade


# Install mongodb 7.0.6
sudo apt-get install gnupg curl -y
echo installing mongodb
sudo curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor --yes


echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list


sudo apt update -y


sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh=2.2.4 mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6
echo DONE installing mongodb 7.0.6


# Hold version of mongodb
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-database hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-mongosh hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections
echo HOLD version of mongodb


# bind ip
sudo sed -i "s,\\(^[[:blank:]]*bindIp:\\) .*,\\1 0.0.0.0," /etc/mongod.conf
echo BIND ip to 0.0.0.0


# Start mongodb
sudo systemctl restart mongod
echo RESTART mongodb


# Enable mongodb so it's start when vm restarts
sudo systemctl enable mongod
echo ENABLE mongodb
