# Minecraft Server (Bedrock) for Docker

A Docker image and docker-compose file to run one or more instances of a native Minecraft Bedrock server in a minimal ubuntu environment.

## Background

My kids wanted a Minecraft (Bedrock) server so that they can play the same worlds on any of their devices at home.  Fortunately, Minecraft finally released an alpha version of a server for Bedrock edition.  See https://minecraft.net/en-us/download/server/bedrock/.

This worked well for a single server, but my kids each have their own worlds they want to serve, and they want to be able to bring these up and down quickly.  Long story short, for various reasons, I decided it was time to teach myself about Docker, and run the servers as separate docker containers.

## Version History

- 1.13.1 (Nov 2019): Major revisions to architecture, including running under a different user and expanded custom resource file/directory support
- 0.1.12 (10 Jul 2019): Custom permission file support
- 0.1.8.2 (16 Dec 2018): Bump minecraft version number
- Initial release (17 Oct 2018)

*For updating to version 1.13.1, see [Updating to Version 1.13.1](#updating-to-version-1131).*

## Prerequisites

- Docker
- docker-compose (if you want to use the instructions for multiple servers)
- git (if you need to build your own image or use docker-compose)

## Instructions

### Quick Start for a single server

*To build/run a single server with a new world on the host:*

1. Pull the docker image.

```
docker pull karlrees/docker_bedrockserver
```

2. Start the docker container.

```
docker run -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver
```

Unfortunately, I think it's probable that with the above command, *you will lose your world* if you ever have to update the docker image (e.g. for a new server version).  One way to get around this, *may* be to give a fixed name the mcdata folder as follows:

```
docker run -dit --name="minecraft" --network="host" -v mcdata:/mcdata karlrees/docker_bedrockserver
```

It seems to work in a few test cases that I've tried, but I'm not confident enough with that solution, however, to rely on it myself.  Instead, I would mount a mcdata folder from the host system using the instructions in the next section.

### Single-server with externally mounted data

*To build/run a single server with a world whose data is stored in an externally accessible folder:*

Aside from giving you better peace of mind that your worlds will persist after an update, this has the added benefit of giving you easy access to the mcdata folder so that you can create backups.

*Unfortunately, last time I checked (admittedly a while ago), I couldn't get the server to work with an external volume on Windows.  For some reason the server suffers a fatal error.  If someone has an idea of how to make this work, please let me know...*

#### Option A (Single-world Setup Script)

If you have git installed, you can pull the repository and take advantage of the setup script:

1. Download the source code from git.

```
git clone https://github.com/karlrees/docker_bedrockserver
```

2. Run the setup script.

```
cd docker_bedrockserver
./setup_standalone
```

The container/server should now be running, and your world data can be found in the `docker_bedrockserver/mcdata` folder.

#### Option B (Single-world Manual Setup)

If you don't have git installed, or you want more control over the container configuration:

1. Pull the docker image, as in step 1 of the quick start instructions.
2. Create (or locate) a parent folder to store (or that already stores) your Minecraft data.  We'll refer this folder subsequently as the `mcdata` folder.  You may use the supplied `mcdata` folder from the repository, or any other suitable location.  For instance:

```
mkdir /path/to/mcdata
```

3. Give this new folder permissions whereby it is accessible to the user under which the server will run in the docker container.  There are a number of ways to do this.  The easiest and most nuclear option would be:

```
sudo chmod -R 777 /path/to/mcdata
```

A more restrictive option would be to have the same user id as that under which the server runs take ownership of the `mcdata` folder.  By default, this user id is 1132, so you would use the following command:

```
sudo chown -R 1132:1132 /path/to/mcdata
```

Other options would include adding the user 1132 to a group that has access to the `mcdata` folder, or changing the user id and/or group id under which the server runs to something that already has access to the `mcdata` folder.  Changing the user id and/or group id under which the server runs is explained later in the document.

4. Start the docker container

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

*To run multiple servers using multiple Bedrock worlds, each running at a separate IP address:*

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

5. Edit the `docker-compose.yml` file to include a separate section for each server.  Be sure to change the name for each server--change both the container_name property and the `WORLD` environment variable.  Be sure to use a different IP address for each server as well.

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
5. Edit `docker-compose.yml` to include a separate section for each server/world. Be sure to change the name for each server/world to match what you used in step 3.
6. Restart the docker-compose services.

```
docker-compose down
docker-compose up -d
```

## Changing server properties

Server properties may be changed using either a custom `server.properties` file for your world, or `MCPROP_` environment variables.  Any time you change properties, you will need to restart the container for the changes to take effect.

### Server.properties

The container will look for a custom `server-properties` file for its world/server in each of the following locations: `/mcdata/world.server.properties`, `/mcdata/worlds/world.server.properties`, and `/mcdata/worlds/world/server.properties` (where `world` is the name of the world/server).  It will then link the `server.properties` file for the server to the custome `server.properties` it locates.

If no custom `server.properties` file is found, a default `server.properties` file will be created, optionally using any supplied environment variables (see below).

### MCPROP_ Environment variables

Environment varaibles may be passed through the command line or set in the `docker-compose.yml` file.  For instance, to change the gamemode to 1 over the CLI, one would set the `MCPROP_GAMEMODE` environment variable to `1`.

```
docker run -e MCPROP_GAMEMODE=1 -e WORLD=worldname -v /path/to/worlds/folder:/mcdata -dit --name="minecraft" --network="host" karlrees/docker_bedrockserver
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

You can then issue server commands, like `stop`, `permissions list`, etc.

To exit, enter `Ctrl-P` followed by `Ctrl-Q`.

## Restarting the server

You can stop the server in the console, or by issuing the following command (where `minecraft` is the container name):

```
docker stop minecraft
```

You can restart it with the following command.

```
docker start minecraft
```

Note that if you use docker-compose, the `docker-compose.yml` file is set to automatically restart a server once it goes down, so this command should not be necessary unless you change the `docker-compose.yml` file.

## Minecraft Server updates

For new updates to the server, first remove the existing containers.  Then grab the update, and run the container again.

### If you are pulling the docker image directly (basic single-server installs)

Use the following commands, where `minecraft` is the container name:

```
docker stop minecraft
docker rm minecraft
docker pull karlrees/docker_bedrockserver
```

Then use whatever docker run command you used to run the container.

### If you are building the docker image yourself (e.g. multiple world, pulling the source from GitHub)

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
docker build --build-arg MCUSER=1000 --build-arg MCGROUP=1000 .
```

*Be sure to use a numeric id, not a display name like root or user.*

## Troubleshooting

### The server says that it cannot open the port.

This could be one of two things.  First, the obvious issue could be that you are running two servers over the same network interface.  If this is your problem, use the docker-compose solution, and give each server a separate IP address.

Second, I've seen this error when there is a permission problem with some or all of the resource files when you are mounting an external volume to the `mcdata` folder.  The solution is to make sure that the user id (the specific number--e.g. 1132) of all of your files is the same as being used in the container.  See above.

## Updating to version 1.13.1

To update to 1.13.1, you may need to be aware of the following, depending on how you were deploying the server before.

### Changed mount point

Prior to version 1.13.1, the recommended installation procedure was to mount directly to the `srv/bedrockserver/worlds folder`.  We now recommend mounting to the `/mcdata` folder, which should be up one level from your `worlds` folder.  See the instructions above and the new DockerFile.

### Changed user id

We were previously running the server within the container as root.  We have changed to user id to 1132.  You may need to change the permissions on your shared `mcdata/worlds` folder to access them, and/or change the user id under which the container is running (see above).

### Docker-compose.yml changes

If you were using the `docker-compose.yml` file before, we have changed the `docker-compose.yml` file somewhat.  You should probably save your previous version as a reference, download the new version, and readjust the new version to match the changes you made to your previous version.

Note that `docker-compose.yml` no longer exists in the repository.  The expectation is that users will copy the `/examples/docker-compose.yml` to `docker-compose.yml`, either manually or via the `setup_multi.sh` script.

### Changed .env file usage

Before, certain environment varaibles such as the installer URL were always being set from the `.env` file, which made the defaults in `docker-compose.yml` and the `DockerFile` kind of pointless.  I have commented out these values in the new `.env` file.  Going forward, I suggest you use the `.env` file only if you want to override the default `docker-compose.yml` or `DockerFile` value. 

Also, git is now configured to ignore the `.env` file (and `docker-compose.yml`), so that you can update the project in the future without losing your settings.

## Known Issues

Because of Windows permission difficulties, mounting external volumes for Minecraft worlds does not appear to work when using a Windows host.

## Contributors

- @karlrees - original author and maintainer
- @ParFlesh - the guy who actually knows his way around Linux

Additional contributions from: @eithe, @rsnodgrass, @RemcoHulshof, @tsingletonacic, and probably others I lost track of.  Thanks!
