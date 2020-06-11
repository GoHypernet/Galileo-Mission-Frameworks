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
    pnetcdf-bin voro++ voro++-dev \
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
#this will build the GPU version with all of the packages
#RUN cmake -C /lammps/cmake/presets/all_on.cmake /lammps/cmake && make -j16 && make install
# this will build the cpu version with most of the packages
RUN cmake -C /lammps/cmake/presets/most.cmake /lammps/cmake && make -j${PROCS} && make install
ENV PATH=$PATH:/lammps-build
#RUN useradd -ms /bin/bash galileo
#WORKDIR /home/galileo
#USER galileo

###############################################################################
# Final stage
###############################################################################
#FROM nvidia/cuda:10.2-runtime-ubuntu18.04

# install required packages
#RUN apt-get update \
#  && apt-get install -y --no-install-recommends \
#    libgomp1 \
#    libopenmpi-dev \
#    openmpi-bin \
#    openmpi-common \
#    python \
#  && rm -rf /var/lib/apt/lists/*

# copy fftw libraries
#COPY --from=builder /usr/local/lib /usr/local/lib

# copy gromacs install
#COPY --from=builder /gromacs /gromacs
#ENV PATH=$PATH:/gromacs/bin

# setup labels
#LABEL com.nvidia.gromacs.version="${GROMACS_VERSION}"

# NVIDIA-specific stuff?
#RUN mkdir /data
#WORKDIR /data
#COPY examples examples 

#
# Enable the entrypoint to use the dockerfile as a GROMACS binary
#ENTRYPOINT [ "/gromacs/bin/gmx" ]
