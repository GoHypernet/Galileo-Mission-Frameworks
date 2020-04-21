#### Stage 1 #######
# setup base image with required dependencies
# then manually step through the install steps in an interactive session
#FROM ubuntu:16.04
#RUN apt-get update && apt-get upgrade -y && apt-get install -y libgtk2.0.0 libpng16-16 vim
#WORKDIR /media
#COPY Stata16Linux64.tar.gz .
#RUN mkdir /usr/local/stata16
#RUN tar -xvf Stata16Linux64.tar.gz && rm Stata16Linux64.tar.gz
#WORKDIR /usr/local/stata16
##### Stage 2 ######
FROM hypernetlabs/stata:16
RUN mkdir /data
ENV PATH=/usr/local/stata16:$PATH
WORKDIR /data
COPY runstata.sh /runstata.sh
ENTRYPOINT ["bash","/runstata.sh"]