FROM nvidia/cuda:10.2-devel-ubuntu18.04 as builder

ARG FFTW_VERSION=3.3.8
ARG FFTW_MD5=8aac833c943d8e90d51b697b27d4384d

# number of make jobs during compile
ARG JOBS=16

# install required packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    cmake \
    git \
    curl \
    ssh \
    libopenmpi-dev \
    openmpi-bin \
    openmpi-common \
    ffmpeg \
    python3-dev python3-pip python3-six \
    zlibc zlib1g zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/openmpi/lib

# Install fftw with more optimizations than the default packages
# It is not critical to run the tests here, since our experience is that the
# Gromacs unit tests will catch fftw build errors too.
RUN curl -o fftw.tar.gz http://www.fftw.org/fftw-${FFTW_VERSION}.tar.gz \
  && echo "${FFTW_MD5}  fftw.tar.gz" > fftw.tar.gz.md5 \
  && md5sum -c fftw.tar.gz.md5 \
  && tar -xzvf fftw.tar.gz && cd fftw-${FFTW_VERSION} \
  && ./configure --disable-double --enable-float --enable-sse2 --enable-avx --enable-avx2 --enable-avx512 --enable-shared --disable-static \
  && make -j ${JOBS} \
  && make install

# Download sources
RUN git clone https://github.com/lammps/lammps.git && mkdir /lammps-build
WORKDIR /lammps-build
RUN cmake /lammps/cmake/ && make -j4 && make install
RUN useradd -ms /bin/bash galileo
USER galileo

# build GROMACS and run unit tests
# To cater to different architectures, we build for all of them
# and install in different bin/lib directories.

# You can change the architecture list here to add more SIMD types,
# but make sure to always include SSE2 as a fall-back.
#RUN for aRCH in ${GROMACS_ARCH}; do \
#     mkdir -p /gromacs-build.${ARCH} && cd /gromacs-build.${ARCH} \
#  && CC=gcc CXX=g++ cmake /gromacs-src \
#    -DGMX_OPENMP=ON \
#    -DGMX_GPU=ON \
#    -DGMX_MPI=OFF \
#    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
#    -DCMAKE_INSTALL_PREFIX=/gromacs \
#    -DREGRESSIONTEST_DOWNLOAD=ON \
#    -DMPIEXEC_PREFLAGS=--allow-run-as-root \
#    -DGMX_SIMD=${ARCH} \
#    -DCMAKE_INSTALL_BINDIR=bin.${ARCH} \
#    -DCMAKE_INSTALL_LIBDIR=lib.${ARCH} \
#  && make -j ${JOBS} \
#  && make install; done

# Add architecture-detection script
#COPY gmx-chooser /gromacs/bin/gmx
#RUN chmod +x /gromacs/bin/gmx

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
