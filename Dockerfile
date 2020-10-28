FROM nvidia/cuda:10.2-devel-ubuntu18.04 as builder

# install required packages for building
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    cmake \
	mesa-common-dev \
    libidn11-dev \
    python3-requests \
    python3-git \
  && rm -rf /var/lib/apt/lists/*

# clone from github and build
RUN git clone https://github.com/ethereum-mining/ethminer.git 
WORKDIR /ethminer
RUN git submodule update --init --recursive 
RUN cmake -DHUNTER_JOBS_NUMBER=4 -DETHASHCUDA=ON -DAPICORE=ON -H. -Bbuild 
RUN cmake --build build -- -j4

###############################################################################
FROM nvidia/cuda:10.2-runtime-ubuntu18.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libidn11-dev \
    python3-requests \
    python3-git \
  && rm -rf /var/lib/apt/lists/*

# need to set WALLET and potentially PASSWORD
ENV PATH /ethminer/build/ethminer:$PATH
ENV SCHEME stratum
ENV WORKERNAME galileo
ENV POOLNAME us1.ethermine.org
ENV PORT 4444

COPY --from=builder /ethminer/build /ethminer/build 

RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

COPY runethminer.sh .
ENTRYPOINT ["bash","runethminer.sh"]
