FROM ubuntu
ENV container docker

# set minecraft world name and port and apk filename
ENV WORLD='default'
ENV MCPORT=19132
ARG INSTALLERURL=https://minecraft.azureedge.net/bin-linux/bedrock-server-1.13.0.34.zip
ENV MCSERVERFOLDER=/srv/bedrockserver
ENV MCVOLUME=/config

EXPOSE $MCPORT

# install dependencies
RUN apt update && \
  apt install -y curl unzip && \
  apt clean && \
  apt clean autoclean && \
  rm -rf /var/lib/apt/lists/*

# install minecraft
RUN curl $INSTALLERURL --output mc.zip && \
  unzip mc.zip -d $MCSERVERFOLDER && \
  rm mc.zip && \
  mkdir $MCSERVERFOLDER/default $MCVOLUME && \
  chown -Rf 1001:0 $MCSERVERFOLDER $MCVOLUME && \
  chmod -Rf g=u $MCSERVERFOLDER $MCVOLUME && \
  rm ${MCSERVERFOLDER}/server.properties && \
  for i in permissions.json whitelist.json behavior_packs definitions resource_packs structures;do mv $MCSERVERFOLDER/$i $MCSERVERFOLDER/default/$i;done


# create folders for minecraft resources
VOLUME $MCVOLUME

# copy over server properties template
# COPY server.properties.template $MCSERVERFOLDER/server.properties.template

# set up startup script
COPY startup.sh /srv/bedrockserver/
RUN chmod +x $MCSERVERFOLDER/startup.sh && \
  chmod -Rf g=u $MCSERVERFOLDER/startup.sh && \
  chown 1001:0 $MCSERVERFOLDER/startup.sh

USER 1001

CMD ["/srv/bedrockserver/startup.sh"]
