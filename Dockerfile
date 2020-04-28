FROM ubuntu:16.04
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  tcsh make \
  gcc gfortran \
  flex bison patch \
  bc xorg-dev libbz2-dev wget \
  openmpi-bin libopenmpi-dev \
  && mkdir /data
WORKDIR /data