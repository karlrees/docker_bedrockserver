echo off

REM ###########################################
REM #
REM # Setup script for docker bedrock_server
REM # Multiple server / Docker-Compose version
REM #
REM # May need to run under Administrator
REM # Also, be sure to install docker and docker-compose
REM #
REM ###########################################

cd ..

echo.
echo -----------------------------------------------------------------
echo Docker Bedrock Server Multi-Server Setup script
echo -----------------------------------------------------------------
echo This script copies the example files to the appropriate locations to start running multiple bedrock server containers using docker-compose with externally mounted data.
echo.


REM Copy ENV file
if not exist .env (
	copy /Y templates\.env .env 
	call :FindReplace "# MCVOLUME" "MCVOLUME" .env
	call :FindReplace "/opt/minecraft/server/mcdata" "%CD%\mcdata" .env
) else (
	echo ------------------------------------------------------------------
	echo WARNING: The .env file already exists. To avoid inadvertently losing your changes, this script will not overwrite it.  Please edit .env manually, or delete .env and run this script again.
	echo ------------------------------------------------------------------
)

REM Copy Docker Compose file
if not exist docker-compose.yml (
	copy /Y templates\docker-compose.yml docker-compose.yml 
) else (
	echo ------------------------------------------------------------------
	echo WARNING: The docker-compose.yml file already exists. To avoid inadvertently losing your changes, this script will not overwrite it.  Please edit docker-compose.yml manually, or delete docker-compose.yml and run this script again.
	echo ------------------------------------------------------------------
)

REM Copy MCDATA example world and set permissions
if not exist mcdata/world.server.properties (
	xcopy /Y /E templates\mcdata\* mcdata\
) else (
	echo ------------------------------------------------------------------
	echo WARNING: The example server properties in mcdata is already found. To avoid inadvertently losing your data, this script will not overwrite it.  Please delete it if you want to overwrite it.
	echo ------------------------------------------------------------------
)

echo. 
echo Everything is now in place to run the docker bedrock servers
echo ------------------------------------------------------------------
echo. 
echo To start the servers:
echo   cd %CD%
echo   docker-compose up
echo.
echo To stop the servers:
echo   cd %CD%
echo   docker-compose down
echo.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo IMPORTANT: Although you can use docker-compose to run multiple Bedrock containers/servers on a Windows host, the default macvlan network driver it uses does not work in the same way it works on a Linux-based host.  Thus you will not by default have access to the servers on your LAN.  You will need to figure out how to bridge the network yourself, or switch to a Linux-based host for multiple servers.  
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.
echo To configure your own servers, edit the docker-compose.yml file.  See the README file for more information.See the README file for advanced configuration information.

exit /b


:FindReplace <findstr> <replstr> <file>
set tmp="%temp%\tmp.txt"
If not exist %temp%\_.vbs call :MakeReplace
for /f "tokens=*" %%a in ('dir "%3" /b /a-d /on') do (
  for /f "usebackq" %%b in (`Findstr /mic:"%~1" "%%a"`) do (
    echo(&Echo Replacing "%~1" with "%~2" in file %%~nxa
    <%%a cscript //nologo %temp%\_.vbs "%~1" "%~2">%tmp%
    if exist %tmp% move /Y %tmp% "%%~dpnxa">nul
  )
)
del %temp%\_.vbs
exit /b

:MakeReplace
>%temp%\_.vbs echo with Wscript
>>%temp%\_.vbs echo set args=.arguments
>>%temp%\_.vbs echo .StdOut.Write _
>>%temp%\_.vbs echo Replace(.StdIn.ReadAll,args(0),args(1),1,-1,1)
>>%temp%\_.vbs echo end with