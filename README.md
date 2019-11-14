# Minecraft Server (Bedrock) for Docker

A Docker image and docker-compose file to run one or more instances of a native Minecraft Bedrock server in a minimal ubuntu environment.

For updating and changes since the last update, see the end of the document.


## Background

My kids wanted a Minecraft (Bedrock) server so that they can play the same worlds on any of their devices at home.  Fortunately, Minecraft finally released an alpha version of a server for Bedrock edition.  See https://minecraft.net/en-us/download/server/bedrock/.

This worked well for a single server, but my kids each have their own worlds they want to serve, and they want to be able to bring these up and down quickly.  Long story short, for various reasons, I decided it was time to teach myself about Docker, and run the servers as separate docker images.


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

Unfortunately, I think it's probable that with the above command, *you will lose your world* if you ever have to update the docker image (e.g. for a new server version).  One way to get around this, *may* be to give a fixed name the minecraft config folder as follows:

```
docker run -dit --name="minecraft" --network="host" -v config:/config karlrees/docker_bedrockserver
```

It seems to work in a few test cases that I've tried, but I'm not confident enough with that solution, however, to rely on it myself.  Instead, I would mount a worlds folder from the host system as follows:

```
docker run -dit --name="minecraft" --network="host" -v /path/to/config/folder:/config karlrees/docker_bedrockserver
```

This has the added benefit of giving you easy access to the worlds folder so that you can create backups.

Unfortunately, I can't get this to work with an external volume on Windows.  For some reason the server suffers a fatal error.  So you have to go with the second option instead.  Unless someone has a better idea of how docker works and would like to share it...

### Single-server / Existing world

*To build/run a single server using a pre-existing Bedrock world folder:*

1. Create (or locate) a parent folder to store (or that already stores) your Minecraft worlds.  We'll refer this folder subsequently as the parent "worlds" folder.
2. Locate the "world" folder that stores the existing Minecraft world data for the world you wish to serve.  This may or may not be named "world", but we'll refer to it subsequently as the "world" folder.
3. Save the "world" under the parent "worlds" folder (if needed, using a different name to your liking).
<!--4. Create or locate a server.properties file for your world (see the example server.properties.template if you don't have one).
5. Save the server.properties file as "worldname.properties" in the *"worlds"* folder, where worldname is the name of your "world" folder.
6. Change the level-name attribute value from "world" to "worldname" (or whatever your "world" folder is named)-->
7. Start the docker container as shown below, replacing "worldname" with whatever your "world" folder is named, and "/path/to/world/folder" with the absolute path to your parent worlds folder:

```
docker run -e WORLD=worldname -v /path/to/worlds/folder:/config -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver
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

## Changing server properties

Server properties may be changed using MCPROP_ environment variables, either passed through the command line, set in docker-compose file, or set in the .env file.  For instance, to change the gamemode to 1, one would set the MCPROP_GAMEMODE environment variable to 1.

*Server properties may also be changed using a custom server.properties file, created using the method below.*

## Custom permissions / whitelist / resource files and folders

You can change your permissions.json file, whitelist.json file, resource directories, and so forth, by mounting the /config folder to an external volume and making changes from there.  These are all linked to the appropriate locations on the server when the conatiner is started.

### Multiple Servers

If you are running multiple servers, by default they will all share the same files in the /config folder.  You may or may not want to change this.  You can create separate permissions, whitelists, etc., for a server by prefacing the appropriate file(s) and/or directories in the config folder with "worldname.", where "worldname" is the name of your world.  

For instance, to create a separate permissions file for your world, create a file named "/config/worldname.permissions.json" (where "worldname" is the name of your world).  The startup script will link this file, if it exists, into the worldname image as the permissions.json file for the server.  

Similarly, the startup script would copy the "worldname.whitelist.json" file, if it exists (where "worldname" is the name of your world), into the image as the whitelist.json file for the server.

Or, for a custom resource_packs directory, rename it "worldname.resource_packs."

## Accessing the server console

To access the server console, if you're using the single-server instructions above:

```
docker attach minecraft
```

If you changed the container name in the run command, change "minecraft" to the container name you used.  If you're using docker-compose instructions, replace "minecraft" with the container name you specified in the "docker-compose.yml" file (e.g. minecraft1, minecraft2, etc.).

You can then issue server commands, like "stop", "permission list", etc.

To exit, enter "Ctrl-P" followed by "Ctrl-Q".

## Restarting the server

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

## Changing the User the Container runs under

By default, the container runs under user 1001 and group 0.  You can change these by setting the MCUSER and MCGROUP environment variables (e.g. over the command line, in the docker-compose file, or in the .env file, depending on how you're starting the server).

## Troubleshooting

### The server says that it cannot open the port.

This could be one of two things.  First, the obvious issue could be that you are running two servers over the same network interface.  If this is your problem, use the docker-compose solution, and give each server a separate IP address.

Second, I've seen this error when there is a permission problem with some or all of the resource files when you are mounting an external volume to teh config folder.  The solution is to make sure that the user id (the specific number--e.g. 1001) of all of your files is the same as being used in the container.  See above.

## Updating to version 0.1.13.1

To update to 0.1.13.1, you may need to be aware of the following, depending on how you were deploying the server before.

### Changed mount point

Prior to version 0.1.13.1, the recommended installation procedure was to mount directly to the srv/bedrockserver/worlds folder.  We now recommend mounting to the /config folder, which should be up one level from your worlds folder.  See the instructios above and the new docker file.

### Changed location of settings files

Additionally, the server.properties, permissions.json, and whitelist.json have been moved up one directory (to the /config folder).  See the example config folder in the repository for the expected locations of files.

### Changed user id

We were previously running the server within the container as root.  We have changed to user id to 1001.  You may need to change the permissions on your shared worlds/config folder to access them, and/or change the user id under whcih the container is running (see above).


## Known Issues

Because of Windows permission difficulties, mounting external volumes for Minecraft worlds does not appear to work when using a Windows host.
