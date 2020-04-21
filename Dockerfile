# place this dockerfile in parent directory of q-e source code
FROM ubuntu:16.04
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
  python-pip 
COPY . /q-e
WORKDIR /q-e
RUN ./configure && make all
ENV PATH="/q-e/bin:${PATH}"
RUN mkdir /data
WORKDIR /data