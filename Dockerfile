FROM nvidia/cuda:10.2-devel-ubuntu18.04 as builder

# install required packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    libuv1-dev \
    libssl-dev \
    libhwloc-dev \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/xmrig/xmrig.git && mkdir /xmrig/build && cd /xmrig/build && cmake .. && make -j8
RUN git clone https://github.com/xmrig/xmrig-cuda.git && mkdir /xmrig-cuda/build && cd /xmrig-cuda/build && cmake .. -DCUDA_LIB=/usr/local/cuda/lib64/stubs/libcuda.so && make -j8

###############################################################################
FROM nvidia/cuda:10.2-runtime-ubuntu18.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libuv1-dev \
    libssl-dev \
    libhwloc-dev \
    vim \
  && rm -rf /var/lib/apt/lists/*

ENV PATH=/xmrig/build:$PATH
ENV LIBXMRIG_CUDA=/xmrig-cuda/build/libxmrig-cuda.so
ENV DONATE_LVL=1
ENV POOL=us-west.minexmr.com
ENV PORT=443

COPY --from=builder /xmrig/build /xmrig/build 
COPY --from=builder /xmrig-cuda/build /xmrig-cuda/build

RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

COPY runxmrig.sh .
ENTRYPOINT ["bash","runxmrig.sh"]
