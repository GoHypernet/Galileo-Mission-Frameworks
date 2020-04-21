#### Stage 1 #######
# first build the base image with required dependencies
# then start interactive session to manually perform installation
#FROM ubuntu:16.04
#RUN apt-get update && apt-get upgrade -y && apt-get install -y libgtk2.0.0 libpng16-16 vim
#WORKDIR /media
#COPY Stata16Linux64.tar.gz .
#RUN mkdir /usr/local/stata16
#RUN tar -xvf Stata16Linux64.tar.gz && rm Stata16Linux64.tar.gz
#WORKDIR /usr/local/stata16
##### Stage 2 ######
## commit container with Stata installion to new base image
FROM hypernetlabs/stata:16
RUN mkdir /data
ENV PATH=/usr/local/stata16:$PATH
WORKDIR /data
COPY runstata.sh /runstata.sh
ENTRYPOINT ["bash","/runstata.sh"]