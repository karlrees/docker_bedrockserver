#!/bin/bash

###########################################
#
# Update script for bedrock_server
# 
# This script is intended to be copied to and run 
# from within the docker container only
#
###########################################

USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/85 Version/11.1.1 Safari/605.1.15"

if [ -n "$1" ]
then
	INSTALL_VERSION=$1
else
        LATEST_VERSION=$( \
            curl -A "$USER_AGENT" -v --silent  https://www.minecraft.net/en-us/download/server/bedrock 2>&1 | \
            grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' | \
            sed 's#.*/bedrock-server-##' | sed 's/.zip//') && \
	echo "Latest VERSION is $LATEST_VERSION" && \
	INSTALL_VERSION=$LATEST_VERSION
fi

CURRENT_VERSION=$(<$MCSERVERFOLDER/.CURRENTVERSION)
echo "Currently installed server version is: $CURRENT_VERSION"

if [ "$CURRENT_VERSION" != "$INSTALL_VERSION" ]
then
        echo "Attempting to install VERSION $INSTALL_VERSION" && \
	$MCSERVERFOLDER/installbedrockserver.sh $INSTALL_VERSION && \
	echo -e "Server updated. If the server is already running, restart the container to apply the update."
	#echo "quit\n" > /tmp/mc-input
else
	echo "Server is already $INSTALL_VERSION."
fi


