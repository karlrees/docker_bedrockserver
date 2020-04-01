# Minecraft Server (Bedrock) for Docker

A Docker image and docker-compose file to run one or more instances of a native Minecraft Bedrock server in a minimal Ubuntu environment.  

## Introduction

This repository includes a DockerFile to build a Ubuntu-based Docker image configured to launch a Minecraft Bedrock Dedicated Server.  In most cases, when run using the host network driver, as shown in the instructions, any Minecraft Bedrock client (e.g. XBox One, Windows 10, Android, etc.) on your local area network *should* be able to see the server under the list of "Friends."

This repository further includes an example docker-compose.yml file for Docker Compose to run multiple such containers on a macvlan network.  When setup properly through the script and/or manual instructions below, it will concurrently run multiple servers that are each accessible to the local area network.  For instance, I have used it to run different survival and creative worlds for each of my children at the same time, each of which is always accessible on our home network, no matter what device the kids are using.   

The Minecraft data may further be exposed to your host, so that you can easily back up your worlds and configuration.

## Version History

- 1.14 (Dec 2019): Added automatic updating of minecraft server on image restart
- 1.13.1 (Nov 2019): Major revisions to architecture, including running under a different user and expanded custom resource file/directory support
- 0.1.12 (10 Jul 2019): Custom permission file support
- 0.1.8.2 (16 Dec 2018): Bump Minecraft version number
- Initial release (17 Oct 2018)

*For updating from pre-1.13.1 versions, see [Updating from Pre-1.13.1 Versions](#updating-from-pre-1131-versions).*

## Prerequisites

- Docker
- Docker Compose (if you want to use the instructions for multiple servers)
- git (if you need to build your own image or use docker-compose)


## Quick Start (Single Server)

*To build/run a single server with a new world on the host:*

```
docker run -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver
```

It's probable that, relying on the above command, *you will lose your world* if you ever have to update the docker image (e.g. for a new server version).  One way to get around this, is to make the mcdata folder a Docker volume as follows:

```
docker run -dit --name="minecraft" --network="host" -v mcdata:/mcdata karlrees/docker_bedrockserver
```

*However, it's nonetheless possible that Docker (or more likely you) could eventually inadvertantly remove the volume somehow.  A more fool-proof solution is to actually mount the volume to the host, as shown in the next section.*


## Advanced Instructions

### Single-server with externally mounted data

*To build/run a single server with a world whose data is stored in an externally accessible folder:*

Aside from giving you better peace of mind that you won't lose your data, this has the added benefit of giving you easy access to the mcdata folder so that you can create backups and/or manipulate your data.

#### Option A (Single-world Setup Script)

If you have git installed, you can pull the repository and take advantage of the setup script:

1. Download the source code from git.

```
git clone https://github.com/karlrees/docker_bedrockserver
```

2. Run the setup script.

```
cd docker_bedrockserver
./setup_standalone.sh
```

The container/server should now be running, and your world data can be found in the `docker_bedrockserver/mcdata` folder.

#### Option B (Single-world Manual Setup)

If you don't have git installed, and/or you want more control over the container configuration:

1. Create (or locate) a parent folder to store (or that already stores) your Minecraft data.  We'll refer this folder subsequently as the `mcdata` folder.  You may use the supplied `mcdata` folder from the repository, or any other suitable location.  For instance:

```
mkdir /path/to/mcdata
```

2. Give this new folder permissions whereby it is accessible to the user under which the server will run in the docker container.

In Linux, there are a number of ways to do this.  The easiest and most nuclear option would be:

```
sudo chmod -R 777 /path/to/mcdata
```

A more restrictive option would be to have the same user id as that under which the server runs take ownership of the `mcdata` folder.  By default, this user id is 1132, so you would use the following command:

```
sudo chown -R 1132:1132 /path/to/mcdata
```

Other options would include adding the user 1132 to a group that has access to the `mcdata` folder, or changing the user id and/or group id under which the server runs to something that already has access to the `mcdata` folder.  Changing the user id and/or group id under which the server runs is explained later in the document.

3. Run the docker container

```
docker run -dit --name="minecraft" --network="host" -v /path/to/mcdata:/mcdata karlrees/docker_bedrockserver
```

### Single-server / Existing world

*To build/run a single server using a pre-existing Bedrock world folder:*

1. Follow [Option A](#option-a-single-world-setup-script) or [Option B](#option-b-single-world-manual-setup) from above.
2. Locate the `world` folder that stores the existing Minecraft world data for the world you wish to serve.  This may or may not be named `world`, but we'll refer to it subsequently as the `world` folder. 

*You'll know this folder from the fact that it includes a file named "level.dat" and a subfolder named "db".  For instance, if you wanted to import a world from the Windows 10 Minecraft app, this would be a folder such as `C:\Users\username\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\minecraftWorlds\xxx`, where `username` is the name of your user account and xxx is typically a random set of characters.*

3. Replace the contents of the `/mcdata/worlds/world` folder with the contents of the `world` folder you located.
4. Reset permissions on the `mcdata` folder, if needed.  *See* Step 3 of [Option B](#option-b-single-world-manual-setup).
5. Restart the server

```
docker stop minecraft
docker start minecraft
```

### Multiple worlds with docker-compose

*To run multiple servers using multiple Bedrock worlds, each running at a separate IP address on your LAN:*

#### Option C (Multi-world Setup Script)

The setup script can try to setup your environment for you.  Be sure to install docker-compose.

1. Download the source code from git.

```
git clone https://github.com/karlrees/docker_bedrockserver
```

2. Run the `setup_multi.sh` script.

```
cd docker_bedrockserver
./setup_multi.sh
```

This copies the example `.env` file, `docker-compose.yml` file, and `mcdata` folder to their expected locations, and populates the environment variables with some naive assumptions about your network and mcdata storage location.

3. If you want more than just the two example servers, edit the `docker-compose.yml` file to include a separate section for each server.  Be sure to change the name for each server--change both the `container_name` property and the `WORLD` environment variable.  Be sure to use a different IP address for each server as well.

4. Run `docker-compose`

```
docker-compose up -d
```

If this doesn't work for you, you can try the manual setup below.

#### Option D (Multi-world Manual Setup)

1. Download the source code from git and change to the docker_bedrockserver directory

```
git clone https://github.com/karlrees/docker_bedrockserver
```

2. Setup a `mcdata` folder.  *See* Steps 2-3 of [Option B](#option-b-single-world-manual-setup).

3. Copy the example `.env` file and `docker-compose.yml` from the `templates` folder to parent directory.

```
cd docker_bedrockserver
cp templates/.env .env
cp templates/docker-compose.yml docker-compose.yml
```

4. Edit the `.env` file as needed.  You will probably need to at least:

 - change the IP Prefix to match your subnet
 - change `eth0` to match your network interface
 - change the `MCVOLUME` to point to the absolute path of your `mcdata` folder from step 2

5. Edit the `docker-compose.yml` file to include a separate section for each server, copying or editing the example servers already at the bottom of the file.  Be sure to change the name for each server--change both the `container_name` property and the `WORLD` environment variable.  Be sure to use a different IP address for each server as well.

6. Run `docker-compose`

```
docker-compose up -d
```

### Multiple existing worlds

*To run multiple servers using multiple pre-existing Bedrock worlds, each running at a separate IP address:*

1. Follow [Option C](#option-c-multi-world-setup-script) or [Option D](#option-d-multi-world-manual-setup) from above.
2. Locate the `world` folder that stores the existing Minecraft world data for each world you wish to serve.  This may or may not be named `world`, but we'll refer to it subsequently as the `world` folder. 
3. For each world, copy the contents of the `world` folder to the `/mcdata/worlds/` folder, using a different name for each. 

So you might have, for instance, a `/mcdata/worlds/world1` folder, a `/mcdata/worlds/world2` folder, and so forth.

4. Reset permissions on the `mcdata` folder, if needed.  *See* Step 3 of [Option B](#option-b-single-world-manual-setup).

5. Edit `docker-compose.yml` to include a separate section for each server/world, copying or editing the example servers already at the bottom of the file. Be sure to change the name for each server/world to match what you used in step 3.

6. Restart the docker-compose services.

```
docker-compose down
docker-compose up -d
```

## Changing server properties

Server properties may be changed using either a custom `server.properties` file for your world, or `MCPROP_` environment variables.  Any time you change properties, you will need to restart the container for the changes to take effect.

### server.properties

The container will look for a custom `server-properties` file for its world/server in each of the following locations: `/mcdata/world.server.properties`, `/mcdata/worlds/world.server.properties`, and `/mcdata/worlds/world/server.properties` (where `world` is the name of the world/server).  It will then link the `server.properties` file for the server to the custom `server.properties` it locates.

If no custom `server.properties` file is found, a default `server.properties` file will be created, optionally using any supplied environment variables (see below).

### MCPROP_ Environment variables

Environment variables may be passed through the command line or set in the `docker-compose.yml` file.  For instance, to change the gamemode to 1 over the CLI, one would set the `MCPROP_GAMEMODE` environment variable to `1`.

```
docker run -e MCPROP_GAMEMODE=1 -e WORLD=world -v /path/to/mcdata:/mcdata -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver
```

The `docker-compose.yml` gives some examples of passing `MCPROP_` environment variables through it.

Note that `level-name` is a special property that is set by the `WORLD` environment variable, as opposed to `MCPROP_LEVEL-NAME`.

## Custom permissions / whitelist / resource files and folders

You can change your `permissions.json` file, `whitelist.json` file, `resource` directories, and so forth, by mounting the `/mcdata` folder to an external folder and making changes from there.  These are all linked to the appropriate locations on the server when the container is started.

### Multiple Servers

If you are running multiple servers, by default they will all share the same files in the `/mcdata` folder.  You may or may not want to change this.  You can create separate permissions, whitelists, etc., for a server by either saving the appropriate file or folder in your custom world folder, or prefacing the appropriate file(s) and/or directories in the `mcdata` folder with `world.`, where `world` is the name of your world/server.

For instance, to create a separate permissions file for your world, you could create a file named `/mcdata/world.permissions.json` (where `world` is the name of your world).  Or, you could save `permissions.json` to `/mcdata/worlds/world/permissions.json`.  In either case, the container will link this file, if it exists, into the world container as the `permissions.json` file for the server.  

Similarly, the container would copy the `world.whitelist.json` file, if it exists (where `world` is the name of your world), into the container as the `whitelist.json` file for the server.

Or, for a custom `resource_packs` directory, rename it `world.resource_packs` or save it to `/mcdata/worlds/world/resource_packs`.

You will need to restart the container for any changes to take effect.

## Accessing the server console

To access the server console, if you're using the single-server instructions above:

```
docker attach minecraft
```

If you changed the container name in the run command, change `minecraft` to the container name you used.  If you're using docker-compose instructions, replace `minecraft` with the container name you specified in the `docker-compose.yml` file (e.g. `minecraft1`, `minecraft2`, etc.).

You can then issue server commands, like `stop`, `permission list`, etc.

To exit, enter `Ctrl-P` followed by `Ctrl-Q`.

## Restarting a server

You can stop a server in the console, or by issuing the following command (where `minecraft` is the container name):

```
docker stop minecraft
```

You can restart it with the following command.

```
docker start minecraft
```

If using docker-compose, you can restart all servers at once using:

```
docker-compose down
docker-compose up
```

## Minecraft Server updates

By default, the image will check for an updated version of the Minecraft server on restart.  So all you need to do is restart your image(s).  So for a single-server install, assuming your image name is minecraft:

```
docker restart minecraft
``` 

For multiple servers using docker-compose:

```
docker-compose restart
```

### Disabling automatic updates

Automatic updates may be disabled in one of two ways.  First, you can delete the `$MCSERVERFOLDER/.AUTOUPDATE` file.  For instance, if your image name is minecraft:

```
docker exec minecraft rm "/srv/bedrockserver/.AUTOUPDATE"
```

Second, you could disable auto-updates by setting the `AUTOUPDATE` build argument to `0` when building the docker image (which keeps the .AUTOUPDATE file from being created).  For instance:

```
docker build --build-arg AUTOUPDATE=0 -t karlrees/docker_bedrockserver:beta .
```

### Forcing updates

If auto-updates are disabled, you can still force a minecraft server update using the `updatebedrockserver.sh` script.  For instance, if your image name is minecraft:

```
docker exec minecraft /srv/bedrockserver/updatebedrockserver.sh
docker restart minecraft
```

### Forcing updates to a specific version

You can force an update to a specific version by adding the version number to the end of the update script.  E.g.:

```
docker exec minecraft /srv/bedrockserver/updatebedrockserver.sh 1.14.0.9
docker restart minecraft
```

Alternatively, you can use the `VERSION` build argument when building the image.


## Updating the Docker Image

To keep up to date with the latest features, you may need to update the docker image from time to time.  To update the image, first remove the existing containers.  Then pull the update, and run the container again.  To do this:

### If you are pulling the docker image directly (basic single-server installs)

Use the following commands, where `minecraft` is the container name:

```
docker stop minecraft
docker rm minecraft
docker pull karlrees/docker_bedrockserver
```

Then use whatever docker run command you used to run the container.

### If you are building the docker image yourself (e.g. multiple world, pulling the source from GitHub)

#### Standalone server

If you used the `setup_standalone` script, just re-run it (ignoring any errors about directories that already exist).

Otherise, use the following commands, where `~/docker_bedrockserver` is the location where you downloaded the source files:

```
cd ~/docker_bedrockserver
docker stop minecraft
docker rm minecraft
git pull
docker build  -t karlrees/docker_bedrockserver .
docker run -dit --name="minecraft" --network="host" -v /path/to/mcdata:/mcdata karlrees/docker_bedrockserver
```

#### Multi-world with docker-compose

Use the following commands, where `~/docker_bedrockserver` is the location where you downloaded the source files:

```
cd ~/docker_bedrockserver
docker-compose down
git pull
docker-compose build
docker-compose up -d
```

## Changing the user the server runs under

By default, the server runs within the container under user 1132 and group 1132.  You can change these by setting the `MCUSER` and `MCGROUP` environment build arguments.  (Depending on what you choose, you may need to reset the permissions on your `mcdata` folder to match -- *see* Step 3 of [Option B](#option-b-single-world-manual-setup)).

If you are using the docker-compose approach, all you need to do is change these values in the `.env` file. 

Otherwise, you will need to download and build the docker image yourself.  You would do this *instead* of pulling the docker image.  For instance, to build under user id 1000 and group id 1000:

```
git clone https://github.com/karlrees/docker_bedrockserver
cd docker_bedrockserver
docker build --build-arg MCUSER=1000 --build-arg MCGROUP=1000 -t karlrees/docker_bedrockserver .
```

*Be sure to use a numeric id, not a display name like root or user.*

## Using a MacOS host

*Thanks to @Shawnfreebern for these instructions.*

According to docker docs:

> The host networking driver only works on Linux hosts, and is not supported on Docker Desktop for Mac ...

The result is that you have to specify which ports to publish on MacOS. For a remote server you can (possibly) get away with publishing only your chosen server port (19132) but for LAN games minecraft opens a second randomly chosen port which you need to publish, but can't because you don't know the number when you start the container.

Docker has a `--publish-all` function but it doesn't seem to work:

it appears to only publish ports opened early in the container start process, and the LAN port is opened a bit later both TCP and UDP are required and it looks like `--publish-all` doesn't get that done it assigns known ports to randomly selected higher ports, which further complicates remote server access My solution at present is to artificially limit which random ports are available, and then specifically publish all port options for both TCP and UDP:

```
docker run --sysctl net.ipv4.ip_local_port_range="39132 39133" -p 19132:19132 -p 19132:19132/udp -p 39132:39132 -p 39132:39132/udp -p 39133:39133 -p 39133:39133/udp --name="minecraft" etc
```
Someone will hopefully find a better way to do this (I am not a docker, minecraft, or mac networking expert) but until that's discovered this might be helpful to other mac users.

## Using a Windows host

The above instructions assume you are running on a Linux-based host.  You can also run the containers on a Windows-based host.  However, because of differences in how Windows-based hosts handle networking, you won't by default have access to the servers on your LAN.

You *may* be able to get access to the servers on your LAN, if you bridge the Windows docker network with your LAN and/or set up port forwarding.  These are not tasks for the faint-hearted, and I make no attempt to describe them here.

## Troubleshooting

### The server says that it cannot open the port.

This could be one of two things.  First, the obvious issue could be that you are running two servers over the same network interface.  If this is your problem, use the docker-compose solution, and give each server a separate IP address.

Second, I've seen this error when there is a permission problem with some or all of the resource files when you are mounting an external volume to the `mcdata` folder.  The solution is to make sure that the user id (the specific number--e.g. 1132) of all of your files is the same as being used in the container.  See above.

## Updating from pre-1.13.1 versions

If you have problems after updating to a 1.13.1 image or higher, it is most likely related to permissions.  A quick and dirty solution may be to go into your worlds volume and run either `chmod -R 777 *`, or `chown -R 1132:1132 *`.  An even more quick and dirty solution would be to run the legacy branch instead.  For instance:

```
docker pull karlrees/docker_bedrockserver:legacy
docker run -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver:legacy
```

Of course, the most preferred solution (and most likely to be supported going forward) would be to start mounting the mcdata volume instead of the worlds folder, as described elsewehere herein.

A few changes in the update that you may or may not need to be aware of:

### Changed mount point

Prior to version 1.13.1, the recommended installation procedure was to mount directly to the `srv/bedrockserver/worlds` folder.  We now recommend mounting to the `/mcdata` folder, which should be up one level from your `worlds` folder.  See the instructions above and the new DockerFile.

### Changed user id

We were previously running the server within the container as root.  We have changed to user id to 1132.  You may need to change the permissions on your shared `mcdata/worlds` folder to access them, and/or change the user id under which the container is running (see above).

### Docker-compose.yml changes

If you were using the `docker-compose.yml` file before, we have changed the `docker-compose.yml` file somewhat.  You should probably save your previous version as a reference, download the new version, and readjust the new version to match the changes you made to your previous version.

Note that `docker-compose.yml` no longer exists in the repository.  The expectation is that users will copy the `/templates/docker-compose.yml` to `docker-compose.yml`, either manually or via the `setup_multi.sh` script.

### Changed .env file usage

Before, certain environment varaibles such as the installer URL were always being set from the `.env` file, which made the defaults in `docker-compose.yml` and the `DockerFile` kind of pointless.  I have commented out these values in the new `.env` file.  Going forward, I suggest you use the `.env` file only if you want to override the default `docker-compose.yml` or `DockerFile` value. 

Also, git is now configured to ignore the `.env` file (and `docker-compose.yml`), so that you can update the project in the future without losing your settings.

## Contributors

- @karlrees - original author and maintainer
- @ParFlesh - the guy who actually knows his way around Linux
- @eithe - Got the ball rolling on auto-updates

Additional contributions from: @Shawnfreebern, @rsnodgrass, @RemcoHulshof, @tsingletonacic, and probably others I lost track of.  Thanks!
