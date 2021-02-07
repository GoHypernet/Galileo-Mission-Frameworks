<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/epa-swmm/swmm.png" width="250">
</p>

# EPA-SWMM
Industry: H&H

Target OS: Windows 

License: open source

Website: https://www.epa.gov/water-research/storm-water-management-model-swmm

Github: https://github.com/USEPA/Stormwater-Management-Model

Notes: Used in conjunction with PCSWMM software as well as stand alone. Dockerfile should build properly with no user intervention or modification. 

In order to build the epa swmm container, first install docker for windows: https://docs.docker.com/docker-for-windows/
Once docker is installed on your windows machine, ensure that you are running windows containers. You control this through the Docker Desktop Settings

Open a powershell, cd into this folder and run:

docker build -t swmm5 .

This will build a container base image called swmm5 which you can confirm by running:

docker images

