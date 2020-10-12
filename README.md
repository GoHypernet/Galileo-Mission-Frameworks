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

docker build -t stage1 -f Dockerfile.stage1 .
docker run -name stage1 -it --entrypoint bash stage1
docker commit stage1 stage2
docker run -it --name stage2 --entrypoint bash stage2
docker commit stage2 hypernetlabs/stata:16