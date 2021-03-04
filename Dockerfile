FROM nvidia/cuda:10.2-runtime-ubuntu18.04

RUN apt update -y && \
    apt install -y wget xz-utils
	
# add non-root galileo user 
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo
	
RUN wget https://github.com/develsoftware/GMinerRelease/releases/download/2.45/gminer_2_45_linux64.tar.xz && \
    tar -xvf gminer_2_45_linux64.tar.xz && \
	rm gminer_2_45_linux64.tar.xz