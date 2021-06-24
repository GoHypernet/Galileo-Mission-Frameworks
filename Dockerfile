# get the caddy executable
FROM caddy AS caddy-build

# get the go executable 
FROM golang as go-build

# build lachesis from source 
RUN git clone https://github.com/Fantom-foundation/go-opera.git && \
    cd go-opera && \
    git checkout release/1.0.1-rc.1 && \
    make

FROM ubuntu:18.04 as ide-build

# install node, yarn, and other tools
RUN apt update -y && apt install vim curl gcc g++ make libx11-dev libxkbfile-dev supervisor -y && \
    curl -fsSL https://deb.nodesource.com/setup_12.x | bash - && \
	apt install -y nodejs && \
	npm install --global yarn

# create a build directory for the IDE
RUN mkdir /theia
WORKDIR /theia

# build the IDE
COPY package.json .
COPY preload.html .
RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM ubuntu:18.04

# install node, python, go, java, and other tools
RUN apt update -y && apt install tmux vim curl wget zip unzip supervisor git software-properties-common -y && \
	add-apt-repository -y ppa:deadsnakes/ppa && \
	apt-get update -y && \
	apt-get install -y python3.8 python3-pip python3-dev && \
    curl -fsSL https://deb.nodesource.com/setup_12.x | bash - && \
	apt install -y nodejs && \
	curl https://rclone.org/install.sh | bash 

# get the go runtime and opera executable
COPY --from=go-build /go /go
COPY --from=go-build /usr/local/go /usr/local/go
COPY --from=go-build /go/go-opera/build/opera /usr/bin/opera
ENV PATH $PATH:/usr/local/go/bin:/home/galileo:/home/galileo/.local/bin
ENV GOPATH /go

# add galileo non-root user
RUN useradd -ms /bin/bash galileo
COPY .theia /home/galileo/.theia
RUN chmod -R a+rwx /home/galileo/.theia

# edit the node configuration file for operating as a relay node
RUN mkdir /theia
WORKDIR /theia

COPY --from=ide-build /theia /theia
COPY supervisord.conf /etc/

WORKDIR /theia

ENV GALILEO_RESULTS_DIR /home/galileo

# set environment variable to look for plugins in the correct directory
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/theia/plugins
ENV USE_LOCAL_GIT true

# get the Caddy server executable
# copy the caddy server build into this container
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/

# set login credintials and write them to text file
# ENV USERNAME "a"
# ENV PASSWORD "a"
# RUN echo "basicauth /* {" >> /tmp/hashpass.txt && \
     # echo "    {env.USERNAME}" $(caddy hash-password -plaintext $(echo $PASSWORD)) >> /tmp/hashpass.txt && \
     # echo "}" >> /tmp/hashpass.txt

USER galileo

ENTRYPOINT ["sh", "-c", "supervisord"]
