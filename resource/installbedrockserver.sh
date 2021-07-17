#!/bin/bash

###########################################
#
# Install script for bedrock_server
# 
# This script is intended to be copied to and run 
# from within the docker container only
#
###########################################

if [ -n "$1" ]
then
	curl $INSTALLERBASE$1.zip --output $MCSERVERFOLDER/mc.zip && \
	unzip -o $MCSERVERFOLDER/mc.zip -d $MCSERVERFOLDER && \
	rm $MCSERVERFOLDER/mc.zip && \
	echo $1 > $MCSERVERFOLDER/.CURRENTVERSION && \
	rm -rf $MCSERVERFOLDER/default/* && \
	rm $MCSERVERFOLDER/server.properties && \
	for i in permissions.json whitelist.json behavior_packs definitions resource_packs structures;do mv $MCSERVERFOLDER/$i $MCSERVERFOLDER/default/$i;done
else
	echo -e "No version specified.  Please specify version.  E.g.\n\n\tinstallbedrockserver.sh 1.14.0.9"
fi


