#### Stage 1 #######
# first build the base image with required dependencies
# then start interactive session to manually perform installation
# run container in interactive mode, execute install: /media/install
# follow install instructions
# commit resulting container to a new image
#FROM ubuntu:18.04
#RUN apt-get update && apt-get upgrade -y && apt-get install -y libgtk2.0.0 libpng16-16 vim
#WORKDIR /media
#COPY Stata16Linux64.tar.gz .
#RUN mkdir /usr/local/stata16
#RUN tar -xvf Stata16Linux64.tar.gz && rm Stata16Linux64.tar.gz
#WORKDIR /usr/local/stata16

##### Stage 2 ######
## commit container with Stata installation to new base image
FROM stata-stage-2

ENV PATH=/usr/local/stata16:$PATH
COPY runstata.sh /usr/local/stata16/runstata.sh

ENV STATA stata

# need write permissions to put license in correct location
RUN chmod 777 /usr/local/stata16

# add non-root user
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

ENTRYPOINT ["bash","/usr/local/stata16/runstata.sh"]
