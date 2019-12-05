#!/bin/bash

###########################################
#
# Setup script for docker bedrock_server
# Single server version
#
# May need to run under sudo
# Also, be sure to install docker
#
###########################################


echo -e "\n\n-----------------------------------------------------------------\nDocker Bedrock Server Single-Server Setup script\n-----------------------------------------------------------------"
echo -e "\nThis script copies the example files to the appropriate locations to start running the\
	bedrock server container with an externally mounted mcdata folder.\n"


# Copy MCDATA example world and set permissions
if ! [ -f mcdata/world.server.properties ] 
then
	cp -R templates/mcdata/* mcdata/
	chmod -R 777 mcdata
else
	echo -e "------------------------------------------------------------------\nWARNING: The example server properties in mcdata is already found.\nTo avoid inadvertently losing your data, this script will not\noverwrite it.  Please delete it if you want to overwrite it.\n------------------------------------------------------------------\n"
fi

# Stopping and removing container
echo "Stopping and removing container, if it already exists ..."
docker stop minecraft >/dev/null 2>&1
docker rm minecraft >/dev/null 2>&1

# Building image
echo -e "Building image ..."
docker build  -t karlrees/docker_bedrockserver .

# Starting container
echo -e "Starting container ..."
I=`realpath mcdata`
docker run -dit --name='minecraft' --network='host' -v ${I}:/mcdata karlrees/docker_bedrockserver


echo -e "\nThe Docker Bedrock Server shoud be set up and running.\n------------------------------------------------------------------\n"
echo -e "To stop the server:\n\n   docker stop minecraft\n\n\nTo start the server:\n\n   docker start minecraft\n\n\nThe mcdata/world.server.properties file may be used to configure the server.  See the README file for advanced configuration information.\n\n"

exit 1
