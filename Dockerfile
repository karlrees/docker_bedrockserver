FROM ubuntu
ENV container docker

# set minecraft world name and port and apk filename
ENV WORLD='world'
ENV MCPORT=19132
ARG INSTALLERURL=https://minecraft.azureedge.net/bin-linux/bedrock-server-1.13.0.34.zip
ENV MCSERVERFOLDER=/srv/bedrockserver
ENV MCVOLUME=/config
ENV MCUSER=1001
ENV MCGROUP=0

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
  chown -Rf $MCUSER:$MCGROUP $MCSERVERFOLDER $MCVOLUME && \
  chmod -Rf g=u $MCSERVERFOLDER $MCVOLUME && \
  rm ${MCSERVERFOLDER}/server.properties && \
  for i in permissions.json whitelist.json behavior_packs definitions resource_packs structures;do mv $MCSERVERFOLDER/$i $MCSERVERFOLDER/default/$i;done

# create folder for minecraft resources
VOLUME $MCVOLUME

# set up startup script
COPY startup.sh /srv/bedrockserver/
RUN chmod +x $MCSERVERFOLDER/startup.sh && \
  chmod -Rf g=u $MCSERVERFOLDER/startup.sh && \
  chown $MCUSER:$MCGROUP $MCSERVERFOLDER/startup.sh

# set default user to minecraft user
USER $MCUSER:$MCGROUP

CMD ["/srv/bedrockserver/startup.sh"]
