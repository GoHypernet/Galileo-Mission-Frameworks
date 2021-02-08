<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/epa-swmm/swmm.png" width="225">
</p>

# EPA-SWMM
## Overview
- **Industry**: H&H
- **Target Container OS**: Windows 
- **Source Code**: open source
- **Website**: https://www.epa.gov/water-research/storm-water-management-model-swmm
- **Github**: https://github.com/USEPA/Stormwater-Management-Model

## Notes
This repository builds the container runtime used in the SWMM Mission type in [Galileo](https://hypernetlabs.io/galileo/). Additionally, users of the desktop-based [PCSWMM](https://www.pcswmm.com) software can deploy scenarios to Galileo by first converting their models to EPA-SWMM format and then uploading the input files as a SWMM Mission type. 

This application is multi-threaded and can benifit from multi-core architectures, however, there is limited computational speedup above 16 cores. 

## Building
In order to build the epa swmm container, first install [Docker for Windows](https://docs.docker.com/docker-for-windows/).
Once Docker is installed on your Windows machine, ensure that you are running windows containers. You control this through the Docker Desktop Settings.

Open a powershell, cd into the folder and run:

```
docker build -t swmm5 .
```

This will build the a Docker image called swmm5 that contains all currently available SWMM5 engines and a startup script that runs the simulation and prints the progress to stdout. 
## Running

This framework has the following environment variables:

1. VERSION - The version of the SWMM engine you want to run (i.e. VERSION = '5.1.011').
2. SWMMFILE - The name of the input file without the file extension (i.e. SWMMFILE = 'Example9').
3. RETURNINPUT - A boolean determining whether to return the input files in the results payload, default is 1 for yes. 

The working directory of the container runtime is C:\User\Public\SWMM. Input files should be placed in this directory for them to be detected by the startup script. 
Results will also be available in this folder after completion. 
