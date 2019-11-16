#!/bin/bash

export PATH=$PATH:${MCSERVERFOLDER}

file_lookup () {
  LOOKUP_FILE=$1
  if [ -e "${MCVOLUME}/worlds/${WORLD}/${LOOKUP_FILE}" ]
  then
    echo "${MCVOLUME}/worlds/${WORLD}/${LOOKUP_FILE}"
  elif [ -e "${MCVOLUME}/${WORLD}.${LOOKUP_FILE}" ]
  then
    echo "${MCVOLUME}/${WORLD}.${LOOKUP_FILE}"
  elif [ -e "${MCVOLUME}/worlds/${WORLD}.${LOOKUP_FILE}" ]
  then
    echo "${MCVOLUME}/worlds/${WORLD}.${LOOKUP_FILE}"
  else
    echo "${MCVOLUME}/${LOOKUP_FILE}"
  fi
}

# if world folder does not exist, create it
if [ ! -d "${MCVOLUME}/worlds/${WORLD}" ]
then
 mkdir -p -- "${MCVOLUME}/worlds/${WORLD}"
fi

SERVER_FILE=`file_lookup "server.properties"`
# If worldname.server.properties file is found, link to that
if [ -f ${SERVER_FILE} ]
then
  # (re)link server.properties file
  rm -f -- ${MCSERVERFOLDER}/server.properties
  ln -s ${SERVER_FILE} ${MCSERVERFOLDER}/server.properties
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

# Link permission and whilelist
for f in permissions.json whitelist.json
do
  LOOKUP_FILE=`file_lookup "${f}"`
  # If file doesn't exist create from minecraft default
	if ! [ -f "${LOOKUP_FILE}" ]
	then
		cp ${MCSERVERFOLDER}/default/${f} ${LOOKUP_FILE}
	fi
	# (re)link directory
	rm -f -- ${MCSERVERFOLDER}/${f}	
	ln -s ${LOOKUP_FILE} ${MCSERVERFOLDER}/${f}
done

# Link Debug_Log and valid_known_packs
for f in Debug_Log.txt valid_known_packs.json
do
  LOOKUP_FILE=`file_lookup "${f}"`
  # If file doesn't exist create empty
	if ! [ -f "${LOOKUP_FILE}" ]
	then
		touch ${LOOKUP_FILE}
	fi
	# (re)link directory
	rm -f -- ${MCSERVERFOLDER}/${f}	
	ln -s ${LOOKUP_FILE} ${MCSERVERFOLDER}/${f}
done

# Link directories with defaults
for f in behavior_packs definitions resource_packs structures worlds
do
  LOOKUP_FILE=`file_lookup "${f}"`
  # if directory doesn't exist create from minecraft default
	if ! [ -d "${LOOKUP_FILE}" ]
	then
		cp -a ${MCSERVERFOLDER}/default/${f} ${LOOKUP_FILE}
	fi
	# (re)link directory
	rm -f -- ${MCSERVERFOLDER}/${f}	
	ln -s ${LOOKUP_FILE} ${MCSERVERFOLDER}/${f}
done

# Link directories without defaults
for f in development_behavior_packs development_resource_packs premium_cache treatments world_templates
do
  LOOKUP_FILE=`file_lookup "${f}"`
  # if directory doesn't exist create empty
	if ! [ -d "${LOOKUP_FILE}" ]
	then
		mkdir ${LOOKUP_FILE}
		chmod g=u ${LOOKUP_FILE}
	fi
	# (re)link directory
	rm -f -- ${MCSERVERFOLDER}/${f}	
	ln -s ${LOOKUP_FILE} ${MCSERVERFOLDER}/${f}
done

echo "STARTING BEDROCKSERVER: ${WORLD} on ${HOSTNAME}:${MCPORT} ..."

mkfifo /tmp/mc-input
cat > /tmp/mc-input &
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
wait $childPID
echo $?
