FROM ubuntu

# install dependencies
RUN apt update && \
  apt install -y curl unzip && \
  apt clean && \
  apt clean autoclean && \
  rm -rf /var/lib/apt/lists/*

# build arguments
ARG MCPORT
ARG INSTALLERURL
ARG MCUSER
ARG MCGROUP
ENV MCUSER=${MCUSER:-1132}
ENV MCGROUP=${MCGROUP:-1132}
ENV MCPORT=${MCPORT:-19132}
ENV INSTALLERURL=${INSTALLERURL:-"https://minecraft.azureedge.net/bin-linux/bedrock-server-1.14.0.9.zip"}

# setup environment
ENV container=docker
ENV WORLD='world'
ENV MCSERVERFOLDER="/srv/bedrockserver"
ENV MCVOLUME=/mcdata
ENV PATH $PATH:${MCSERVERFOLDER}

# open the server port
EXPOSE $MCPORT

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
COPY resource/runbedrockserver.sh $MCSERVERFOLDER
RUN chmod +x $MCSERVERFOLDER/runbedrockserver.sh && \
  chmod -Rf g=u $MCSERVERFOLDER/runbedrockserver.sh && \
  chown $MCUSER:$MCGROUP $MCSERVERFOLDER/runbedrockserver.sh

# set default user to minecraft user
USER $MCUSER:$MCGROUP

CMD ["runbedrockserver.sh"]
