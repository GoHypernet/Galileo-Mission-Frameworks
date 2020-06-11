FROM nvidia/cuda:10.2-devel-ubuntu18.04 as builder

# number of make jobs during compile
ARG PROCS=16

# install required packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    cmake \
    git \
    wget \
    curl \
    ssh \
    mpich libmpich12 libmpich-dev\
    ffmpeg libboost-dev fftw3 fftw3-dev pkg-config \
    python3-dev python3-pip python3-six \
    zlibc zlib1g zlib1g-dev \
    libnetcdf-dev pnetcdf-bin libpnetcdf-dev voro++ voro++-dev \
    libblas-dev liblapack-dev libgsl-dev\
  && rm -rf /var/lib/apt/lists/*
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/mpich/lib


# Install latest Eigen3 lib
RUN git clone  https://gitlab.com/libeigen/eigen.git \
  && mkdir /eigen-build \
  && cd eigen-build \
  && cmake /eigen \
  && make -j${PROCS} blas \
  && make install

# install latest version of cmake
ARG version=3.14
ARG build=5
RUN wget https://cmake.org/files/v$version/cmake-${version}.${build}.tar.gz && \
    tar -xzvf cmake-${version}.${build}.tar.gz && \
    cd cmake-${version}.${build}/ && \
    ./bootstrap && \
    make -j${PROCS} && \
    make install

# then install ADIOS2
RUN git clone https://github.com/ornladios/ADIOS2.git && \
    mkdir adios2-build && cd adios2-build && \
    cmake /ADIOS2/ && make -j${PROCS} && make install

RUN git clone https://github.com/lammps/lammps.git && mkdir /lammps-build
WORKDIR /lammps-build
# this will build the cpu version with most of the packages
RUN cmake -C /lammps/cmake/presets/most.cmake /lammps/cmake && make -j${PROCS} && make install
# this will biuld the GPU version with most of the packages
#RUN cmake -C /lammps/cmake/presets/most.cmake /lammps/cmake -D PKG_GPU=on -D GPU_API=cuda && make -j${PROCS} && make install

###############################################################################
# Final stage
###############################################################################
FROM nvidia/cuda:10.2-runtime-ubuntu18.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    mpich libmpich12 libmpich-dev\
    ffmpeg libboost-dev fftw3 fftw3-dev pkg-config \
    python3-dev python3-pip python3-six \
    zlibc zlib1g zlib1g-dev \
    libnetcdf-dev pnetcdf-bin libpnetcdf-dev voro++ voro++-dev \
    libblas-dev liblapack-dev libgsl-dev\
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /lammps-build /lammps-build
COPY --from=builder /adios2-build /adios2-build

ENV PATH=$PATH:/lammps-build
RUN useradd -ms /bin/bash galileo
WORKDIR /home/galileo
USER galileo
