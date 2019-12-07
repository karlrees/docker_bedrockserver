#!/bin/bash

###########################################
#
# Setup script for docker bedrock_server
# Multiple server / Docker-Compose version
#
# May need to run under sudo
# Also, be sure to install docker and docker-compose
#
###########################################


echo -e "\n\n------------------------------------------------------------------\nDocker Bedrock Server Multi-Server Setup script\n------------------------------------------------------------------\n"
echo -e "This script copies the example files to the appropriate locations to start running multiple bedrock server containers using docker-compose with externally mounted data.\n"

R=`realpath .`

# Copy ENV file
if ! [ -f .env ] 
then
	cp templates/.env .env

	# Insert absolute path of MCDATA folder and default network interface info
	I=`ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//"`
	sed -i -e "s|.*NETWORKINTERFACE\=.*|NETWORKINTERFACE\=${I}|g" .env
	I=`ip route | grep default | sed -e "s/^.*via.//" -e "s/\.[0-9][0-9]*.dev.*//"`
	sed -i -e "s|.*IPPREFIX\=.*|IPPREFIX\=${I}|g" .env
	sed -i -e "s|.*MCVOLUME\=.*|MCVOLUME\=${R}/mcdata|g" .env
else
	echo -e "------------------------------------------------------------------\nWARNING: The .env file already exists.  To avoid inadvertently \nlosing your changes, this script will not overwrite \nit.  Please edit it manually, or delete .env and run this script again.\n------------------------------------------------------------------\n"
fi


# Copy Docker Compose file
if ! [ -f docker-compose.yml ] 
then
	cp templates/docker-compose.yml docker-compose.yml
else
	echo -e "------------------------------------------------------------------\nWARNING: The docker-compose.yml file already exists. To avoid \ninadvertently losing your changes, this script will not overwrite it.\nPlease edit docker-compose.yml manually, or delete docker-compose.yml and run this script again.\n------------------------------------------------------------------\n"
fi


# Copy MCDATA example world and set permissions
if ! [ -f mcdata/world.server.properties ] 
then
	cp -R templates/mcdata/* mcdata/
	chmod -R 777 mcdata
else
	echo -e "------------------------------------------------------------------\nWARNING: The example server properties in mcdata is already found.\nTo avoid inadvertently losing your data, this script will not \noverwrite it.  Please delete it if you want to overwrite it.\n------------------------------------------------------------------\n"
fi



echo -e "\nEverything is now in place to run the docker bedrock servers.\n------------------------------------------------------------------\n"
echo -e "To start the servers:\n\n   cd ${R}\n   docker-compose up -d\n\n\nTo stop the servers:\n\n   cd ${R}\n   docker-compose down\n\n\nTo configure your own servers, edit the docker-compose.yml file.  See the README file for more information.\n\n"
