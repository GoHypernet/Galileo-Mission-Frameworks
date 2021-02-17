FROM jupyter/datascience-notebook

# set environment variable for password
ENV JUPYTER_PASSWD mypassword

# temporarily switch to root user to edit config and set working directories
USER root

RUN apt update -y && apt install vim -y

# edit config file to set password 
RUN echo "import os" >> /home/jovyan/.jupyter/jupyter_notebook_config.py \ 
 && echo "from IPython.lib import passwd" >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo "hashed_passwd = passwd(os.environ['JUPYTER_PASSWD'])" >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.password = hashed_passwd" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

RUN ["mkdir", "-p", "/home/galileo/work"]
RUN ["chown", "-R", "jovyan", "/home/galileo"]

# install go runtime
RUN wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz \
  && tar -xvf go1.13.3.linux-amd64.tar.gz \
  && mv go /usr/local \
  && rm go1.13.3.linux-amd64.tar.gz

# switch back to jovyan user
USER jovyan
WORKDIR /home/galileo/work

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
ENV PATH ${PATH}:/home/galileo/work/go/src/github.com/Fantom-foundation/go-lachesis/build

ENTRYPOINT ["jupyter", "lab"]
