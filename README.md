# Minecraft Server (Bedrock) for Docker

A Docker image and docker-compose file to run one or more instances of a native Minecraft Bedrock server using codehz/mcpeserver in an ArchLinux environment wth systemd.


## Background

My kids wanted a Minecraft (Bedrock) server so that they can play the same worlds on any of their devices at home.  Fortunately, Minecraft finally released an alpha version of a server for Bedrock edition.  See https://minecraft.net/en-us/download/server/bedrock/.

This worked well for a single server, but my kids each have their own worlds they want to serve, and they want to be able to bring these up and down quickly.  Long story short, for various reasons, I decided it was time to teach myself about Docker, and run the servers in a docker image.

*So this is one of my first Docker projects.  Don't be too hard on me if I'm doing something terribly wrong.*


## Prerequisites

- Docker
- docker-compose (if you want to use the instructions for multiple servers)

## Instructions

### Single-server / New world

*To build/run a single server with a new world on the host:*

1. Pull the docker image.

```
docker pull karlrees/docker_bedrockserver
```

2. Start the docker container.

```
docker run -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver
```

Unfortunately, I'm not entirely sure I understand how docker volumes work.  I think it's probable that with the above, *you will lose your world* if you ever have to update the docker image (e.g. for a new server version).  One way to get around this, *may* be to give a fixed name the worlds folder as follows:

```
docker run -dit --name="minecraft" --network="host" -v worlds:/srv/bedrockserver/worlds karlrees/docker_bedrockserver
```

It seems to work in a few test cases that I've tried, but I'm not confident enough with that solution, however, to rely on it myself.  Instead, I would mount a worlds folder from the host system as follows:

```
docker run -dit --name="minecraft" --network="host" -v /path/to/worlds/folder:/srv/bedrockserver/worlds karlrees/docker_bedrockserver
```

This has the added benefit of giving you easy access to the worlds folder so that you can create backups.

Unfortunately, I can't get this to work with an external volume on Windows.  For some reason the server suffers a fatal error.  So you have to go with the second option instead.  Unless someone has a better idea of how things work and would like to share it...

### Single-server / Existing world

*To build/run a single server using a pre-existing Bedrock world folder:*

1. Create (or locate) a parent folder to store (or that already stores) your Minecraft worlds.  We'll refer this folder subsequently as the parent "worlds" folder.
2. Locate the "world" folder that stores the existing Minecraft world data for the world you wish to serve.  This may or may not be named "world", but we'll refer to it subsequently as the "world" folder.
3. Save the "world" under the parent "worlds" folder (if needed, using a different name to your liking).
4. Create or locate a server.properties file for your world (see the example server.properties.template if you don't have one).
5. Save the server.properties file as "worldname.properties" in the *"worlds"* folder, where worldname is the name of your "world" folder.
6. Change the level-name attribute value from "world" to "worldname" (or whatever your "world" folder is named)
7. Start docker container as shown below, replacing "worldname" with whatever your "world" folder is named, and "/path/to/world/folder" with the absolute path to your parent worlds folder:

```
docker run -e WORLD=worldname -v /path/to/worlds/folder:/srv/mcpeserver/worlds -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver
```

### Multiple existing worlds / docker-compose

*To run multiple servers using multiple pre-existing Bedrock worlds, each running at a separate IP address:*

1. Download the source code from git

```
git clone https://github.com/karlrees/docker_bedrockserver
```

2. Complete steps 1-6 above, using the worlds folder in the source code as the parent "worlds" folder.  Repeat steps 3-6 for each world you wish to serve.
3. Edit the ENV file as needed (e.g. change the IP Prefix to match your subnet, eth0 to match your network interface, etc.)
4. Edit the docker-compose file to include a separate section for each server.  Be sure to change the name for each server to match what you used in step 2.  Be sure to use a different IP address for each server as well.
5. Run docker-compose

```
docker-compose up -d
```

*Sorry for any confusing instructions.  Just thought it'd be better to share with terse instructions than not at all.*

## Custom permissions / whitelist

The startup script will copy the "worldname.permissions.json" file, if it exists (where "worldname" is the name of your world), into the image as the permissions.json file for the server.  Similarly, the startup script will copy the "worldname.whitelist.json" file, if it exists (where "worldname" is the name of your world), into the image as the whitelist.json file for the server

## Accessing the server console

To access the server console, if you're using the single-server instructions above:

```
docker attach minecraft
```

If you changed the container name in the run command, change "minecraft" to the container name you used.  If you're using docker-compose instructions, replace "minecraft" with the container name you specified in the "docker-compose.yml" file (e.g. minecraft1, minecraft2, etc.).

You can then issue server commands, like "stop", "permission list", etc.

To exit, enter "Ctrl-P" followed by "Ctrl-Q".

## Restarting Server

If you stop the server (e.g. in the console), you can restart it with the following command, where "minecraft" is the container name.

```
docker start minecraft
```

Note that the docker-compose file is set to automatically restart a server once it goes down, so this command shouldn't be necessary unless you change the docker-compose file.

## Minecraft Server updates

For new updates to the server, you will need to remove the existing container and then repeat the above instructions.  For the single-server instructions:

```
docker rm minecraft
```

This should theoretically be managed for you if you go the docker-compose route:

```
docker-compose down
```

## Known Issues

Because of Windows permission difficulties, mounting external volumes for Minecraft worlds does not appear to work when using a Windows host.
