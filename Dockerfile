FROM nvidia/cuda:10.2-runtime-ubuntu18.04
RUN apt-get update \
  && apt-get install -y wget vim
ENV PATH /miniconda3/bin:$PATH
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \  
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    conda init
RUN conda install -c acellera acemd3
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo
ENTRYPOINT ["acemd3","input"]
