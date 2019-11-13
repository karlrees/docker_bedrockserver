#!/bin/bash

# if world folder does not exist, create it
if [ ! -d "${MCVOLUME}/worlds/${WORLD}" ]
then
 mkdir -p -- "${MCVOLUME}/worlds/${WORLD}"
fi

echo "Generating server configuration:"
# create base for server.properties
echo -e "server-port=19132\nlevel-name=world" > ${MCSERVERFOLDER}/server.properties
echo -e "\tserver-port=19132\n\tlevel-name=world"
# Parse all environment variables beginning with MCPROP to generate server.properties
# For each matching line
#  - Get property name from beggining to first = sign
#    - Remove MCPROP_ from beginning
#    - Switch to lowercase
#    - Convert _ to -
#  - Get property value from everything after first = sign
# Examples
#  - MCPROP_ALLOW_CHEATS=true
#    allow-cheats=true
for P in `printenv | grep '^MCPROP_'`
do
	PROP_NAME=${P%%=*}
  PROP_VALUE=${P##${PROP_NAME}=}
	PROP_NAME=${PROP_NAME#*_}
	PROP_NAME=`echo ${PROP_NAME} | tr '[:upper:]' '[:lower:]'`
	PROP_NAME=`echo ${PROP_NAME} | tr "_" "-"`
  echo -e "\t${PROP_NAME}=${PROP_VALUE}"
	echo "${PROP_NAME}=${PROP_VALUE}" >> ${MCSERVERFOLDER}/server.properties
done

# Link permission and whilelist
for f in permissions.json whitelist.json
do
  # If file doesn't exist create from minecraft default
	if ! [ -f "${MCVOLUME}/${f}" ]
	then
		cp ${MCSERVERFOLDER}/default/${f} ${MCVOLUME}/${f}
	fi
	ln -s ${MCVOLUME}/${f} ${MCSERVERFOLDER}/${f}
done

# Link Debug_Log and valid_known_packs
for f in Debug_Log.txt valid_known_packs.json
do
  # If file doesn't exist create empty
	if ! [ -f "${MCVOLUME}/${f}" ]
	then
		touch ${MCVOLUME}/${f}
	fi
	ln -s ${MCVOLUME}/${f} ${MCSERVERFOLDER}/${f}
done

# Link directories with defaults
for d in behavior_packs definitions resource_packs structures worlds
do
  # if directory doesn't exist create from minecraft default
	if ! [ -d "${MCVOLUME}/${d}" ]
	then
		cp -a ${MCSERVERFOLDER}/default/${d} ${MCVOLUME}/${d}
	fi
	ln -s ${MCVOLUME}/${d} ${MCSERVERFOLDER}/${d}
done

# Link directories without defaults
for d in development_behavior_packs development_resource_packs premium_cache treamtemts world_templates
do
  # if diretory doesn't exist create empty
	if ! [ -d "${MCVOLUME}/${d}" ]
	then
		mkdir ${MCVOLUME}/${d}
		chmod g=u ${MCVOLUME}/${d}
	fi
	ln -s ${MCVOLUME}/${d} ${MCSERVERFOLDER}/${d}
done

echo "STARTING BEDROCKSERVER: ${WORLD} on ${HOSTNAME}:${MCPORT} ..."

# cd to bin folder and exec to bedrock_server
cd /${MCSERVERFOLDER}/
LD_LIBRARY_PATH=. exec ./bedrock_server