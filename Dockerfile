# place this dockerfile in parent directory of q-e source code
FROM ubuntu:18.04 as builder
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  subversion \
  autoconf \
  libtool \
  flex \
  g++ \
  gfortran \
  libstdc++6 \
  byacc \
  libexpat1-dev \
  libblas-dev \
  liblapack-dev \
  libfftw3-dev \
  mpich \
  uuid-dev \
  ruby \
  build-essential \
  wget \
  pkg-config \
  gedit \ 
  vim \
  python2.7 \
  python-pip \
  git

RUN git clone https://github.com/QEF/q-e.git && cd q-e && ./configure && make all -j8

ENV PATH="/q-e/bin:${PATH}"

# run as the user "galileo" with associated working directory
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo
