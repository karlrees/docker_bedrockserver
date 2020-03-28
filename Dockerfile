FROM ubuntu

# install dependencies
RUN apt update && \
  apt install -y curl unzip && \
  apt clean && \
  apt clean autoclean && \
  rm -rf /var/lib/apt/lists/*

# build arguments
ARG MCPORT
ARG INSTALLERBASE
ARG INSTALLERURL
ARG MCUSER
ARG MCGROUP
ARG VERSION
ARG AUTOUPDATE
ENV MCUSER=${MCUSER:-1132}
ENV MCGROUP=${MCGROUP:-1132}
ENV MCPORT=${MCPORT:-19132}
ENV VERSION=${VERSION:-"1.14.32.1"}
ENV INSTALLERBASE=${INSTALLERBASE:-"https://minecraft.azureedge.net/bin-linux/bedrock-server-"}
ENV AUTOUPDATE=${AUTOUPDATE:-1}

# setup environment
ENV container=docker
ENV WORLD='world'
ENV MCSERVERFOLDER="/srv/bedrockserver"
ENV MCVOLUME=/mcdata
ENV PATH $PATH:${MCSERVERFOLDER}

# open the server port
EXPOSE $MCPORT

# make dirs
RUN mkdir -p $MCSERVERFOLDER/default $MCVOLUME

# copy resource files over
COPY resource/* $MCSERVERFOLDER/

# fix permissions
RUN chown -Rf $MCUSER:$MCGROUP $MCSERVERFOLDER $MCVOLUME && \
    chmod -Rf g=u $MCSERVERFOLDER $MCVOLUME && \
    chmod +x $MCSERVERFOLDER/*.sh

# set default user to minecraft user
USER $MCUSER:$MCGROUP

# create volume for minecraft resources
VOLUME $MCVOLUME

# install bedrock server
RUN if [ $AUTOUPDATE = 1 ]; then touch $MCSERVERFOLDER/.AUTOUPDATE; fi && \
    $MCSERVERFOLDER/installbedrockserver.sh $VERSION


CMD ["runbedrockserver.sh"]
