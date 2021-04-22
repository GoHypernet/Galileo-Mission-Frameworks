<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/tuflow/tuflow_logo.png" width="225">
</p>

# TUFLOW
## Overview
- **Industry**: H&H

- **Target Container OS**: Windows

- **Source Code**: Closed source, site-license recquired

- **Website**: https://www.tuflow.com/

## Notes
This framework is still in testing. It is still very easy for a user to launch a Tuflow simulation 
that appears to be running properly but is actually stalled. More work on contstraining the entrypoint needs to be done. 

## Building

In order to build the Tuflow base image, first install [Docker for Windows](https://docs.docker.com/docker-for-windows/). 
Once Docker is installed on your Windows machine, ensure that you are running windows containers. This is controlled through the Docker Desktop Settings. 

Open a powershell, cd into the root folder of this project and run:

```bash
docker build -t tuflow .
```

This will build a Docker image called `tuflow` that contains the tuflow.exe runtime. 

## Running

The working directory of any Tuflow container created from the base image defined by this project's Dockerfile is set to 
be `C:\Users\Public\tuflow`. The Tuflow executable and all requisite runtime libraries are included in the 
`C:\exe\2018-03-AC\` folder. 

Two environment variables are set for convenience: `EXE_iSP` and `EXE_iDP`. These environment variables contain the installation
path of the single and double precision executables respectively.

A runtime .bat file called `run_tuflow.bat` is used as the entrypoint for the container. This .bat file executes whatever .bat file 
the user places in the wording directory and sets via the environment variable `TUFLOW_BAT`. 