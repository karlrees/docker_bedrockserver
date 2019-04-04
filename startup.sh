#!/bin/bash

# if world folder does not exist, create it
if [ ! -d "${MCVOLUME}/worlds/${WORLD}" ]
then
 mkdir -p -- "${MCVOLUME}/worlds/${WORLD}"
fi

echo -e "server-port=19132\nlevel-name=world" > ${MCVOLUME}/server.properties
for P in `printenv | grep '^MCPROP_'`
do
	echo $P
	NAME=${P%%=*}
	NAME=${NAME#*_}
	NAME=`echo ${NAME} | tr '[:upper:]' '[:lower:]'`
	NAME=`echo ${NAME} | tr "_" "-"`
	TEMP=${P##*=}
	echo "${NAME}=${TEMP}" >> ${MCVOLUME}/server.properties
done

ln -s ${MCVOLUME}/server.properties ${MCSERVERFOLDER}/server.properties

if ! [ -f "${MCVOLUME}/permissions.json" ]
then
	echo "[]" > ${MCVOLUME}/permissions.json
fi
ln -s ${MCVOLUME}/permissions.json ${MCSERVERFOLDER}/permissions.json

if ! [ -f "${MCVOLUME}/whitelist.json" ]
then
	echo "[]" > ${MCVOLUME}/whitelist.json
fi
ln -s ${MCVOLUME}/whitelist.json ${MCSERVERFOLDER}/whitelist.json

echo "STARTING BEDROCKSERVER: ${WORLD} on ${HOSTNAME}:${MCPORT} ..."

cd /${MCSERVERFOLDER}/
LD_LIBRARY_PATH=. exec ./bedrock_server
