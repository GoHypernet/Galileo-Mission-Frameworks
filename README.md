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
It is common for TUFLOW models to contain a large number of small text files. This makes uploading raw TUFLOW
models very time consuming since each file requires an individual API call. TUFLOW models should be zipped before
uploading to a Galileo Mission. The build-in entrypoint will decompress the model automatically. 

All major 2018 and 2020 builds are included in this repository and installed in the `/exe` folder. The environment
variables `EXE_iDP` and `EXE_iSP` should be set to the desired version and used to reference the executables. Additionally,
these environment variables include the `-nmb` and `-nc` flags to ensure that GUI popup boxes do not stall the headless 
session.

This framework comes with a React-based IDE for interactive sessions. A password and username must be set via the 
`PASSWORD` and `USERNAME` environment variables for authentication with the interactive session. The IDE is served on 
port 3000 and the authenticated enpoint which reverse-proxies the app is on port 8888. 

![alt](Galileo-Tuflow-IDE.png)

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
