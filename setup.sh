#!/bin/bash

###########################################
#
# Setup script for docker bedrock_server
# 
#
# Be sure to run under sudo
# Also, be sure to install docker and docker-compose
#
###########################################


echo -e "\n\n-----------------------------------\nDocker Bedrock Server setup script\n-----------------------------------"
echo -e "\nThis script copies the example files to the appropriate locations to start running the \
	bedrock server with an externally mounted mcdata folder and/or using docker-compose.\n"

if ! [ -f .env ] 
then
	cp example.env .env
else
	echo -e "- Error: The .env file already exists.  To avoid inadvertently losing your changes, this script will not overwrite it.  Please edit it manually, or delete the file.\n"
fi
if ! [ -f docker-compose.yml ] 
then
	cp example.docker-compose.yml docker-compose.yml
else
	echo -e "- Error: The docker-compose.yml file already exists.  To avoid inadvertently losing your changes, this script will not overwrite it.  Please edit it manually, or delete the file.\n"
fi
if ! [ -d mcdata ] 
then
	cp -R example.mcdata mcdata
	chmod -R 777 mcdata
else
	echo -e "- Error: The mcdata folder already exists.  To avoid inadvertently losing your data, this script will not overwrite it.  Please delete it if you want to overwrite it.\n"
fi

echo -e "Everything is now in place to run the Docker Bedrock Server."
echo -e "To get started Try running 'docker-compose up' to bring up the example servers.  Or edit the docker-compose.yml and .env files to configure your own servers.  See the README file for more information.\n\n"
