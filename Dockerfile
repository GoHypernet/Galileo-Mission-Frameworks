FROM ubuntu:18.04

# install system requirements
RUN apt update -y \
  && apt install -y build-essential wget make gcc g++ git \
  && rm -rf /var/lib/apt/lists/*

# install go runtime
RUN wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz \
  && tar -xvf go1.13.3.linux-amd64.tar.gz \
  && mv go /usr/local \
  && rm go1.13.3.linux-amd64.tar.gz

# add non-root galileo user 
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

# set environment variables for go path
ENV GOROOT '/usr/local/go'
ENV GOPATH /home/galileo/go
ENV PATH ${GOPATH}/bin:${GOROOT}/bin:${PATH}

# build lachesis from source 
RUN mkdir -p go/src/github.com/Fantom-foundation \
  && cd go/src/github.com/Fantom-foundation/ \
  && git clone https://github.com/Fantom-foundation/go-lachesis.git \
  && cd go-lachesis \
  && git checkout tags/v0.7.0-rc.1 -b lachesis-v7rc1 \
  && make build
  
# add lachesis executable to user path
ENV PATH ${PATH}:/home/galileo/go/src/github.com/Fantom-foundation/go-lachesis/build