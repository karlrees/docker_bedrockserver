#!/bin/bash

# if world folder does not exist, create it
if [ ! -d "${MCSERVERFOLDER}/worlds/${WORLD}" ]
then
 mkdir -p -- "${MCSERVERFOLDER}/worlds/${WORLD}"
fi

echo -e "server-port=19132\nlevel-name=world" > ${MCSERVERFOLDER}/server.properties
for P in `printenv | grep '^MCPROP_'`
do
	echo $P
	NAME=${P%%=*}
	NAME=${NAME#*_}
	NAME=`echo ${NAME} | tr '[:upper:]' '[:lower:]'`
	NAME=`echo ${NAME} | tr "_" "-"`
	TEMP=${P##*=}
	echo "${NAME}=${TEMP}" >> ${MCSERVERFOLDER}/server.properties
done

echo "STARTING BEDROCKSERVER: ${WORLD} on ${HOSTNAME}:${MCPORT} ..."


cd /${MCSERVERFOLDER}/
exec LD_LIBRARY_PATH=. ./bedrock_server
