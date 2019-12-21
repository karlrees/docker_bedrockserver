#!/bin/bash

###########################################
#
# Startup script for bedrock_server
# 
# This script is intended to be copied to and run 
# from within the docker container only
#
###########################################

file_lookup () {
  LOOKUP_FILE=$1
  if [ -e "${MCSERVERFOLDER}/worlds/${WORLD}/${LOOKUP_FILE}" ]
  then
    echo "${MCSERVERFOLDER}/worlds/${WORLD}/${LOOKUP_FILE}"
  elif [ -e "${MCSERVERFOLDER}/worlds/${WORLD}.properties" ] && [ ${LOOKUP_FILE} = "server.properties" ]
  then
    echo "${MCSERVERFOLDER}/worlds/${WORLD}.properties"
  elif [ -e "${MCVOLUME}/worlds/${WORLD}/${LOOKUP_FILE}" ]
  then
    echo "${MCVOLUME}/worlds/${WORLD}/${LOOKUP_FILE}"
  elif [ -e "${MCVOLUME}/${WORLD}.${LOOKUP_FILE}" ]
  then
    echo "${MCVOLUME}/${WORLD}.${LOOKUP_FILE}"
  elif [ -e "${MCVOLUME}/worlds/${WORLD}.${LOOKUP_FILE}" ]
  then
    echo "${MCVOLUME}/worlds/${WORLD}.${LOOKUP_FILE}"
  elif [ -e "${MCVOLUME}/worlds/${WORLD}.properties" ] && [ ${LOOKUP_FILE} = "server.properties" ]
  then
    echo "${MCVOLUME}/worlds/${WORLD}.properties"
  else
    echo "${MCVOLUME}/${LOOKUP_FILE}"
  fi
}

echo -e "Minecraft Bedrock Server startup script"
echo -e "---------------------------------------\n\n"

#update check
if [ -e ${MCSERVERFOLDER}/.AUTOUPDATE ]
then
	${MCSERVERFOLDER}/updatebedrockserver.sh
else
	echo -e "Automatic updates are disabled."
fi


#previous version check
if [[ -d "${MCSERVERFOLDER}/worlds" && ! -L "${MCSERVERFOLDER}/worlds" ]]
then
	echo -e "WARNING: This image may not work correctly, since an existing worlds folder was detected in ${MCSERVERFOLDER}.  This may be because you have upgraded from a pre-1.13.1 version of the docker image.  If you have problems, you can try: a) mounting the parent directory in which your worlds data is stored to /mcdata (preferred going forward, see README); b) 'chmod -R 777 *' in your worlds volume, or 'chown -R ${MCUSER}:${MCGROUP} *'; and/or c) running the karlrees/docker_bedrockserver:legacy image."
	if [[ "${WORLD}" == "world" && -e "${MCSERVERFOLDER}/worlds/default" && ! -e "${MCSERVERFOLDER}/worlds/world" ]]
	then
		export WORLD="default"
	fi
fi


echo "LINKING MINECRAFT DATA ..."

# remove any existing server.properties file or link from MCSERVERFOLDER
if [ -f ${MCSERVERFOLDER}/server.properties ] || [ -L ${MCSERVERFOLDER}/server.properties ]
then
  rm -f -- ${MCSERVERFOLDER}/server.properties
fi
# If file lookup finds existing server.properties file, link to that
SERVER_FILE=`file_lookup "server.properties"`
if [ -f ${SERVER_FILE} ]
then
  ln -s ${SERVER_FILE} ${MCSERVERFOLDER}/server.properties
  echo "Using server config from: ${SERVER_FILE}"
else
  echo "Generating server configuration:"
  # create base for server.properties
  echo -e "server-port=${MCPORT}\nlevel-name=${WORLD}" > ${MCSERVERFOLDER}/server.properties
  echo -e "\tserver-port=${MCPORT}\n\tlevel-name=${WORLD}"
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
fi

# Link/create files
for f in permissions.json whitelist.json Debug_Log.txt valid_known_packs.json
do
  LOOKUP_FILE=`file_lookup "${f}"`
  # If file doesn't exist create from minecraft default
	if ! [ -f "${LOOKUP_FILE}" ]
	then
		if [ -f ${MCSERVERFOLDER}/default/${f} ] 
		then
			cp ${MCSERVERFOLDER}/default/${f} ${LOOKUP_FILE}
		else
		# if default file doesn't exist create empty
			touch ${LOOKUP_FILE}
		fi
	fi
	# (re)link file
	if [ -L ${MCSERVERFOLDER}/${f} ]
	then
		rm -f -- ${MCSERVERFOLDER}/${f}	
	fi
	if [ ! -f ${MCSERVERFOLDER}/${f} ]
	then
		ln -s ${LOOKUP_FILE} ${MCSERVERFOLDER}/${f}
	fi
done

# Link/create directories
for f in behavior_packs definitions resource_packs structures worlds development_behavior_packs development_resource_packs premium_cache treatments world_templates
do
  LOOKUP_FILE=`file_lookup "${f}"`
  # if directory doesn't exist create from minecraft default
	if ! [ -d "${LOOKUP_FILE}" ]
	then
		if [ -d ${MCSERVERFOLDER}/default/${f} ] 
		then
			cp -a ${MCSERVERFOLDER}/default/${f} ${LOOKUP_FILE}
		else
		# if default directory doesn't exist create empty
			mkdir ${LOOKUP_FILE}
			chmod g=u ${LOOKUP_FILE}
		fi
	fi
	# (re)link directory
	if [ -L ${MCSERVERFOLDER}/${f} ]
	then
		rm -f -- ${MCSERVERFOLDER}/${f}	
	fi
	if [ ! -d ${MCSERVERFOLDER}/${f} ]
	then
		ln -s ${LOOKUP_FILE} ${MCSERVERFOLDER}/${f}
	fi
done

# if world folder does not exist, create it
if [ ! -d "${MCSERVERFOLDER}/worlds/${WORLD}" ]
then
 mkdir -p -- "${MCSERVERFOLDER}/worlds/${WORLD}"
fi


echo "STARTING BEDROCKSERVER: ${WORLD} on ${HOSTNAME}:${MCPORT} ..."

if ! [ -e "/tmp/mc-input" ] 
then
	mkfifo /tmp/mc-input
fi

MC_INPUT_PID=$!

########### SIG handler ############
function _int() {
   echo "Stopping container."
   echo "SIGINT received, shutting down server!"
   echo -e "stop\n" > /tmp/mc-input
   while grep ^bedrock_server /proc/*/cmdline > /dev/null 2>&1
   do
     sleep 1
   done
   exit 0
}

# Set SIGINT handler
trap _int SIGINT

# Set SIGTERM handler
trap _int SIGTERM

# Set SIGKILL handler
trap _int SIGKILL

# cd to bin folder and exec to bedrock_server
cd /${MCSERVERFOLDER}/
LD_LIBRARY_PATH=. tail -f /tmp/mc-input | bedrock_server &
childPID=$!
while read line
do
  echo "$line" > /tmp/mc-input
done < /dev/stdin &
wait $childPID
