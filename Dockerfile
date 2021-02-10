
FROM ubuntu:18.04

RUN apt update -y \
  && apt install -y software-properties-common \
  && add-apt-repository -y ppa:ethereum/ethereum \ 
  && apt update -y \
  && apt install -y \
    ethereum \
    python3-requests \
    python3-git \
  && rm -rf /var/lib/apt/lists/*
