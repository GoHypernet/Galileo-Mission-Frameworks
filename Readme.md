<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/flo2d/flo2d_logo.jfif" width="225">
</p>

# FLO2D
## Overview
- **Industry**: H&H

- **Target Container OS**: Windows 

- **Source Code**: The FLO2d software is closed source and requires a site license. The associated deployment script (given here) is open sourced under the [Hypernet Community License](https://github.com/GoHypernet/CommunityLicense/blob/main/Hypernet%20Community%20License.pdf). 

- **Website**: https://www.flo-2d.com/

## Notes
The user must place their flo2d license at the top of their project directory (this is the systemflp.dll file found in thier installation director on thier desktop). 
The user optionally provide their own FLOPRO.exe and associated DLLs if they so choose by also placing these at the top of their project directory, if they do not provide a 
FLOPRO.exe, a built-in version of FLOPRO.exe will be selected. 

## Building

In order to build the flo2d container, first install [Docker for Windows](https://docs.docker.com/docker-for-windows/). Once docker is installed on your Windows machine, ensure that you are running Windows containers. You control this through the Docker Desktop Settings.

Open a powershell, cd into the folder, checkout the flo2d branch, and run:

```
docker build -t flo2d .
```

This will build the a Docker image called flo2d that contains a default version of FLOPRO.exe and a startup script that runs the simulation and prints the progress to stdout.

## Running

This framework does not require any environment variables to be set for the runtime. Instead, the entrypoint script, runflo.py, checks for the presence of a systemflp.dll 
license file, then for a user-provided FLOPRO.exe file, and lastly for a CONT.DAT file which specifies the parameters for the simulation. The working directory is 
C:\Users\Public\flo2d and input files should be placed in this location in order to be detected by runflo.py. Output files will also be written to this directory. 
