# get the caddy executable
FROM caddy AS caddy-build

# get the go runtime
FROM golang as go

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

# get metrics binaries
FROM ubuntu:18.04 as metrics
	
# get prometheus metrics monitoring
ADD https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-amd64.tar.gz .
RUN tar -xvf prometheus-2.27.1.linux-amd64.tar.gz
RUN sed -i 's/localhost:9090,/localhost:9900,/g' /prometheus-2.27.1.linux-amd64/prometheus.yml
RUN ls -la


# Final build stage
FROM ubuntu:18.04 

# install geth and nginx
RUN apt update -y \
  && apt install -y software-properties-common gpg \
  && add-apt-repository -y ppa:ethereum/ethereum \ 
  && apt update -y \
  && apt install -y \
    ethereum solc \
    supervisor \
	vim curl git zip unzip vim speedometer net-tools \
  && curl -fsSL https://deb.nodesource.com/setup_12.x | bash - \
  && apt install -y nodejs \
  && npm install truffle -g \
  && npm install -g solc \
  && curl https://rclone.org/install.sh | bash \
  && rm -rf /var/lib/apt/lists/*


# get the go runtime
COPY --from=go /go /go
COPY --from=go /usr/local/go /usr/local/go
ENV PATH $PATH:/usr/local/go/bin:/home/galileo:/home/galileo/.local/bin

RUN useradd -ms /bin/bash galileo

COPY .theia /home/galileo/.theia
RUN chmod a+rwx /home/galileo/.theia

USER galileo
WORKDIR /home/galileo

# get the galileo IDE
COPY --from=ide-build /theia /theia

# get the Caddy server executable
# copy the caddy server build into this container
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/

# get supervisor configuration file
COPY supervisord.conf /etc/

WORKDIR /theia

# set environment variable to look for plugins in the correct directory
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/theia/plugins
ENV USE_LOCAL_GIT true
ENV GALILEO_RESULTS_DIR /home/galileo

# set login credintials and write them to text file
ENV USERNAME "a"
ENV PASSWORD "a"
RUN echo "basicauth /* {" >> /tmp/hashpass.txt && \
    echo "    {env.USERNAME}" $(caddy hash-password -plaintext $(echo $PASSWORD)) >> /tmp/hashpass.txt && \
    echo "}" >> /tmp/hashpass.txt

ENTRYPOINT ["sh", "-c", "supervisord"]