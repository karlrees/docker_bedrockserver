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


REM Building image
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
echo The mcdata/world.server.properties file may be used to configure the server.  See the README file for advanced configuration information.
