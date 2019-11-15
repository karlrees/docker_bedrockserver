# Minecraft Server (Bedrock) for Docker

A Docker image and docker-compose file to run one or more instances of a native Minecraft Bedrock server in a minimal ubuntu environment.

## Background

My kids wanted a Minecraft (Bedrock) server so that they can play the same worlds on any of their devices at home.  Fortunately, Minecraft finally released an alpha version of a server for Bedrock edition.  See https://minecraft.net/en-us/download/server/bedrock/.

This worked well for a single server, but my kids each have their own worlds they want to serve, and they want to be able to bring these up and down quickly.  Long story short, for various reasons, I decided it was time to teach myself about Docker, and run the servers as separate docker images.

## Version History

- 1.13.1 (Nov 2019): Major revisions to architecture, including running under a different user and expanded custom resource file/directory support
- 0.1.12 (10 Jul 2019): Custom permission file support
- 0.1.8.2 (16 Dec 2018): Bump minecraft version number
- Initial release (17 Oct 2018)

*For updating to version 1.13.1, see the end of the document.*

## Prerequisites

- Docker
- docker-compose (if you want to use the instructions for multiple servers)
- git (if you need to build your own image or use docker-compose)

## Instructions

### Quick Start for Single-server / New world

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

It seems to work in a few test cases that I've tried, but I'm not confident enough with that solution, however, to rely on it myself.  Instead, I would mount a config folder from the host system using the  instructions in the next section.

### Single-server / New world with externally mounted data

*To build/run a single server with a new world whose data is stored in an externally accessible folder:*

Aside from giving you better peace of mind that your worlds will persist after an update, this has the added benefit of giving you easy access to the config folder so that you can create backups:

1. Pull the docker image, as in step 1 above.
2. Create (or locate) a parent folder to store (or that already stores) your Minecraft data.  We'll refer this folder subsequently as the "config" folder.  You may use the supplied config folder from the repository, or any other suitable location.  For instance:

```
mkdir /path/to/config
```

3. Give this new folder permissions whereby it is accessible to the user under which the server will run in the docker container.  There are a number of ways to do this.  The easiest and most nuclear option would be:

```
sudo chmod -R 777 /path/to/config
```

A more restrictive option would be to have the same user id as that under which the server runs take ownership of the config folder.  By default, this user id is 1132, so you would use the following command:

```
sudo chown -R 1132:1132 /path/to/config
```

Other options would include adding the user 1132 to a group that has access to the config folder, or changing the user id and/or group id under which the server runs to something that already has access to the config folder.  Changing the user id and/or group id under which the server runs is explained later in the document.

4. Start the document container

```
docker run -dit --name="minecraft" --network="host" -v /path/to/config:/config karlrees/docker_bedrockserver
```

Unfortunately, last time I checked (admittedly a while ago), I couldn't get the server to work with an external volume on Windows.  For some reason the server suffers a fatal error.  If someone has an idea of how to make this work, please let me know...

### Single-server / Existing world

*To build/run a single server using a pre-existing Bedrock world folder:*

1. Follow steps 1-2 from the "New world with externally mounted data" instructions.
2. Create (or locate) a folder named "worlds" in the "config" folder.  We'll refer this folder subsequently as the "worlds" folder.
3. Locate the "world" folder that stores the existing Minecraft world data for the world you wish to serve.  This may or may not be named "world", but we'll refer to it subsequently as the "world" folder. 

*You'll know this folder from the fact that it includes a file named "level.dat" and a subfolder named "db".  For instance, if you wanted to import a world from the Windows 10 Minecraft app, this would be a folder such as C:\Users\username\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\minecraftWorlds\xxx, where username is the name of your user account and xxx is typically a random set of characters.*

4. Copy the "world" folder (which you can rename to something more descriptive if you wish) to the "worlds" folder.  *E.g. "/config/worlds/world".*
5. Change permissions on the config folder (including the world folder), as in step 3 of the "New world with externally mounted data" instructions.
6. Start the docker container as shown below, replacing "worldname" with whatever your "world" folder is named, and "/path/to/config" with the absolute path to your config folder:

```
docker run -e WORLD=worldname -v /path/to/config:/config -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver
```

### Multiple new worlds / docker-compose

*To run multiple servers using multiple Bedrock worlds, each running at a separate IP address:*

1. Download the source code from git and change to the docker_bedrockserver directory

```
git clone https://github.com/karlrees/docker_bedrockserver
cd docker_bedrockserver
```

2. Setup a config folder.  See steps 2-3 of the "New world with externally mounted data" instructions.
3. Edit the ENV file (.env) as needed.  You will probably need to at least:

 - change the IP Prefix to match your subnet
 - change eth0 to match your network interface
 - change the MCVOLUME to point to the absolute path of your config folder from step 2

4. Edit the docker-compose file to include a separate section for each server.  Be sure to change the name for each server--change both the container_name property and the WORLD environment variable.  Be sure to use a different IP address for each server as well.
5. Run docker-compose

```
docker-compose up -d
```

### Multiple existing worlds / docker-compose

*To run multiple servers using multiple pre-existing Bedrock worlds, each running at a separate IP address:*

1. Download the source code from git.  See step 1 from the "Multiple new worlds" instructions.
2. Complete steps 1-3 from the "single-server / existing world instructions."  Repeat step 3 for each world you wish to serve.  Hence, you'd have a /config/worlds/world1 folder, a config/worlds/world2 folder, and so forth.
3. Edit the ENV file (.env) as needed.  See step 3 from the "Multiple new worlds" instructions.
4. Edit the docker-compose file to include a separate section for each server.  Be sure to change the name for each server to match what you used in step 2--change both the container_name property and the WORLD environment variable.  Also, be sure to use a different IP address for each server as well.
5. Run docker-compose

```
docker-compose up -d
```

## Changing server properties

Server properties may be changed using MCPROP_ environment variables, either passed through the command line, set in docker-compose file, or set in the .env file.  For instance, to change the gamemode to 1, one would set the MCPROP_GAMEMODE environment variable to 1.

```
docker run -e MCPROP_GAMEMODE=1 -e WORLD=worldname -v /path/to/worlds/folder:/config -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver
```

Note that level-name is a special property that is set by the WORLD environment variable, as opposed to MCPROP_LEVEL-NAME.

You will need to restart the container for the changes to take effect.  

*Server properties may instead be changed using a custom worldname.server.properties file in the "config" folder, per the technique below.*

## Custom permissions / whitelist / resource files and folders

You can change your permissions.json file, whitelist.json file, resource directories, and so forth, by mounting the /config folder to an external volume and making changes from there.  These are all linked to the appropriate locations on the server when the conatiner is started.  

### Multiple Servers

If you are running multiple servers, by default they will all share the same files in the /config folder.  You may or may not want to change this.  You can create separate permissions, whitelists, etc., for a server by prefacing the appropriate file(s) and/or directories in the config folder with "worldname.", where "worldname" is the name of your world.  

For instance, to create a separate permissions file for your world, create a file named "/config/worldname.permissions.json" (where "worldname" is the name of your world).  The startup script will link this file, if it exists, into the worldname image as the permissions.json file for the server.  

Similarly, the startup script would copy the "worldname.whitelist.json" file, if it exists (where "worldname" is the name of your world), into the image as the whitelist.json file for the server.

Or, for a custom resource_packs directory, rename it "worldname.resource_packs."

You will need to restart the container for the changes to take effect.  

## Accessing the server console

To access the server console, if you're using the single-server instructions above:

```
docker attach minecraft
```

If you changed the container name in the run command, change "minecraft" to the container name you used.  If you're using docker-compose instructions, replace "minecraft" with the container name you specified in the "docker-compose.yml" file (e.g. minecraft1, minecraft2, etc.).

You can then issue server commands, like "stop", "permission list", etc.

To exit, enter "Ctrl-P" followed by "Ctrl-Q".

## Restarting the server

You can stop the server in the console, or by issuing the following command:

```
docker stop minecraft
```

You can restart it with the following command, where "minecraft" is the container name.

```
docker start minecraft
```

Note that if you use docker-compose, the docker-compose file is set to automatically restart a server once it goes down, so this command shouldn't be necessary unless you change the docker-compose file.

## Minecraft Server updates

For new updates to the server, first remove the existing containers.  Then grab the update, and run the container again.

###If you used the single-server instructions###

Use the following commands, where "minecraft" is the container name:

```
docker stop minecraft
docker rm minecraft
docker pull karlrees/docker_bedrockserver
```

Then use whatever docker run command you used to run ther container.

###If you used the multiple world instructions###

For the docker-compose route, first be sure to save copies of any files you changed, in case you need to repeate those changes after the update.  Then, do the following, where ~/docker_bedrockserver is the location where you downloaded the source files:

```
cd ~/docker_bedrockserver
docker-compose down
git pull
docker-compose build
docker-compose up -d
```

## Changing the user the server runs under

By default, the server runs within the container under user 1132 and group 1132.  You can change these by setting the MCUSER and MCGROUP environment build arguments.  (Depending on what you choose, you may need to reset the permissions on your config folder to match -- see step 3 of the "New world with externally mounted data").

If you are using the docker-compose approach, all you need to do is change these values in the .env file. 

Otherwise, you will need to download and build the docker image yourself.  You would do this *instead* of pulling the docker image.  For instance, to build under user id 1000 and group id 1000:

```
git clone https://github.com/karlrees/docker_bedrockserver
cd docker_bedrockserver
docker build --build-arg MCUSER=1000 --build-arg MCGROUP=1000 .
```

*Be sure to use a numeric id, not a display name like root or user.*

## Troubleshooting

### The server says that it cannot open the port.

This could be one of two things.  First, the obvious issue could be that you are running two servers over the same network interface.  If this is your problem, use the docker-compose solution, and give each server a separate IP address.

Second, I've seen this error when there is a permission problem with some or all of the resource files when you are mounting an external volume to teh config folder.  The solution is to make sure that the user id (the specific number--e.g. 1132) of all of your files is the same as being used in the container.  See above.

## Updating to version 1.13.1

To update to 1.13.1, you may need to be aware of the following, depending on how you were deploying the server before.

### Changed mount point

Prior to version 0.1.13.1, the recommended installation procedure was to mount directly to the srv/bedrockserver/worlds folder.  We now recommend mounting to the /config folder, which should be up one level from your worlds folder.  See the instructions above and the new docker file.

### Changed user id

We were previously running the server within the container as root.  We have changed to user id to 1132.  You may need to change the permissions on your shared worlds/config folder to access them, and/or change the user id under which the container is running (see above).

### Docker-compose.yml changes

If you were using the docker-compose.yml file before, we have changed the docker-compose.yml file somewhat.  You should probably save your previous version as a reference, download the new version, and readjust the new version to match the changes you made to your previous version.

### Changed .env file usage

Before, certain environment varaibles were always being set from the .env file, which made the defaults in docker-compose kind of pointless.  I have commented out all values in the .env file.  Going forward, I suggest you use the .env file only if you want to override the default docker-compose value.  You would then set up git to ignore the .env file (and docker-compose.yml), so that you could update the project in the future without losing your settings.

## Known Issues

Because of Windows permission difficulties, mounting external volumes for Minecraft worlds does not appear to work when using a Windows host.

## Contributors

- karlrees - original author and maintainer
- ParFlesh - the guy who actually knows his way around Linux

Additional contributions from: eithe, rsnodgrass, RemcoHulshof, tsingletonacic, and probably others I lost track of.  Thanks!
