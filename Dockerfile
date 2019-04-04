FROM ubuntu
ENV container docker

# set minecraft world name and port and apk filename
ENV WORLD='default'
ENV MCPORT=19132
ARG INSTALLERURL=https://minecraft.azureedge.net/bin-linux/bedrock-server-1.10.0.7.zip
ENV MCSERVERFOLDER=/srv/bedrockserver
ENV MCVOLUME=/config

EXPOSE $MCPORT

# install dependencies
RUN apt update && \
  apt install -y curl unzip && \
  apt clean

# install minecraft
RUN curl $INSTALLERURL --output mc.zip && \
  unzip mc.zip -d $MCSERVERFOLDER && \
  rm mc.zip && \
  mkdir $MCSERVERFOLDER/worlds $MCVOLUME && \
  chown -Rf 1000:0 $MCSERVERFOLDER $MCVOLUME && \
  chmod -Rf g=u $MCSERVERFOLDER $MCVOLUME


# create folders for minecraft resources
VOLUME $MCVOLUME

# copy over server properties template
# COPY server.properties.template $MCSERVERFOLDER/server.properties.template

# set up startup script
COPY startup.sh /srv/bedrockserver/
RUN chmod +x $MCSERVERFOLDER/startup.sh && \
  chmod -Rf g=u $MCSERVERFOLDER/startup.sh && \
  chown 1000:0 $MCSERVERFOLDER/startup.sh

USER 1000

ENTRYPOINT ["/srv/bedrockserver/startup.sh"]
