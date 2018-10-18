#!/bin/bash

# if world folder does not exist, create it
mkdir -p -- "${MCSERVERFOLDER}/worlds/${WORLD}"

# if no existing custom properties file, copt template over
if ! [ -f "${MCSERVERFOLDER}/worlds/${WORLD}.properties" ]; then
 mv "${MCSERVERFOLDER}/server.properties.template" "/${MCSERVERFOLDER}/worlds/${WORLD}.properties"
fi

# fix custom properties file world location
sed -i -e "s/=world/=$WORLD/g" "${MCSERVERFOLDER}/worlds/${WORLD}.properties"

# copy custom properties file to correct location
cp "${MCSERVERFOLDER}/worlds/${WORLD}.properties" "${MCSERVERFOLDER}/server.properties"

# change default server port
sed -i -e "s/=19132/=$MCPORT/g" "${MCSERVERFOLDER}/server.properties"

# old fix for permission problems, don't think I need it anymore
# chmod -R 777 "${MCSERVERFOLDER}/worlds/${WORLD}"

echo "STARTING BEDROCKSERVER: ${WORLD} on ${HOSTNAME}:${MCPORT} ..."


cd /${MCSERVERFOLDER}/
LD_LIBRARY_PATH=. ./bedrock_server

