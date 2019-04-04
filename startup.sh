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

for f in permissions.json whitelist.json
do
	if ! [ -f "${MCVOLUME}/${f}" ]
	then
		cp ${MCSERVERFOLDER}/default/${f} ${MCVOLUME}/${f}
	fi
	ln -s ${MCVOLUME}/${f} ${MCSERVERFOLDER}/${f}
done

for f in Debug_Log.txt valid_known_packs.json
do
	if ! [ -f "${MCVOLUME}/${f}" ]
	then
		touch ${MCVOLUME}/${f}
	fi
	ln -s ${MCVOLUME}/${f} ${MCSERVERFOLDER}/${f}
done

for d in behavior_packs definitions resource_packs structures worlds
do
	if ! [ -d "${MCVOLUME}/${d}" ]
	then
		cp -a ${MCSERVERFOLDER}/default/${d} ${MCVOLUME}/${d}
	fi
	ln -s ${MCVOLUME}/${d} ${MCSERVERFOLDER}/${d}
done

for d in development_behavior_packs development_resource_packs premium_cache treamtemts world_templates
do
	if ! [ -d ${MCVOLUME}/${d}" ]
	then
		mkdir ${MCVOLUME}/${d}
		chmod g=u ${MCVOLUME}/${d}
	fi
	ln -s ${MCVOLUME}/${d} ${MCSERVERFOLDER}/${d}
done

echo "STARTING BEDROCKSERVER: ${WORLD} on ${HOSTNAME}:${MCPORT} ..."

cd /${MCSERVERFOLDER}/
LD_LIBRARY_PATH=. exec ./bedrock_server
