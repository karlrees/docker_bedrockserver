echo off

REM ###########################################
REM #
REM # Setup script for docker bedrock_server
REM # Single server version
REM #
REM # May need to run under Administrator
REM # Also, be sure to install docker
REM #
REM ###########################################


cd ..

echo.
echo -----------------------------------------------------------------
echo Docker Bedrock Server Single-Server Setup script
echo -----------------------------------------------------------------
echo This script copies the example files to the appropriate locations to start running the bedrock server container with an externally mounted mcdata folder.
echo.


REM Copy MCDATA example world and set permissions
if not exist mcdata/world.server.properties (
	xcopy /Y /E  templates\mcdata\* mcdata\
) else (
	echo ------------------------------------------------------------------
	echo WARNING: The example server properties in mcdata is already found. To avoid inadvertently losing your data, this script will not overwrite it.  Please delete it if you want to overwrite it.
	echo ------------------------------------------------------------------
)


REM Stop/delete container
echo.
echo Stopping and removing container, if it already exists ...
docker stop minecraft 1>NUL 2>NUL
docker rm minecraft 1>NUL 2>NUL

REM Building image
echo.
echo Building image ...
docker build  -t karlrees/docker_bedrockserver .


REM Starting container
echo .
echo Starting container ... 
docker run -dit --name="minecraft" --network="host" -v %CD%\mcdata:/mcdata karlrees/docker_bedrockserver


echo The Docker Bedrock Server shoud be set up and running.
echo ------------------------------------------------------------------
echo. 
echo To stop the server:
echo   docker stop minecraft
echo.
echo To start the server:
echo   docker start minecraft
echo .
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo IMPORTANT: Although you can use this DockerFile to run a Bedrock server on a Windows host, the default  host network driver it uses does not work the same way as it would on a Linux-based host.  Thus you will not by default have access to the Bedrock server on your LAN.  You will need to figure out how to bridge the Docker host network yourself, or switch to a Linux host.  
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.
echo The mcdata/world.server.properties file may be used to configure the server.  See the README file for advanced configuration information.
