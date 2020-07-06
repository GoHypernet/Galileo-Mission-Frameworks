# STATA

Industry: Statistics, Economectrics

Target OS: Linux

License: Closed source, licensed software

Website: https://www.stata.com/

Notes: This framework requires a two-stage build.
1. First build a base image that contains the installer package. 
2. Next create a container from this base image and manually install the stata software. 
3. Commit the container to a new base image. 
4. Finish the build from the previous base image. 
