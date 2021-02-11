<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/master/galileo_pres.png" width="500">
</p>

# Galileo Mission Framework Types
This repository contains [Dockerfiles](https://docs.docker.com/engine/reference/builder/) and associated data to 
build frameworks supported by the [Galileo](https://hypernetlabs.io/galileo/) platform. Each branch is named after
the target application and contains information on the target audience of the application, how it is built, and how
it is intended to be executed. 

## Framework Guidelines
A well defined containerized framework should adhere to the following pattern:
1. The default user is non-root user named galileo with uid 1000
2. The default working directory is /home/galileo for linux and C:\Users\Public\ for windows (or a subdirectory of these paths)
3. The framework must not require special kernel priviledges (i.e. the container should run with the flag [--cap-drop all](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) enabled)
4. The framework should be architecture-agnostic and should detect the architecture available to it and adapt accordingly (i.e. multi-core or GPU acceleration)
5. The framework author should contruct the entrypoint such that it requires minimal user input to execute properly. 
6. The framework author should leverage clearly named environment variables to pass relevant arguments to the target application. 
7. For frameworks built around software that require a license, the framework should test that a license is included before attempting to run the software and alert the user if it does not detect an appropriate license file. 
8. Best effort should be made to print relevant information to stdout for progress tracking. 
