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

#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# install node, python, and other tools
RUN apt update -y && apt install vim curl supervisor git software-properties-common systemd rclone -y && \
	add-apt-repository -y ppa:deadsnakes/ppa && \
	apt-get update -y && \
	apt-get install -y python3.8 python3-pip && \
    curl -fsSL https://deb.nodesource.com/setup_12.x | bash - && \
	apt install -y nodejs 

RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

# get the galileo IDE
COPY --from=ide-build /theia /theia

# get metrics tools
COPY --from=metrics /prometheus-2.27.1.linux-amd64/prometheus /usr/local/bin/.
COPY --from=metrics /prometheus-2.27.1.linux-amd64/promtool /usr/local/bin/.
COPY --from=metrics /prometheus-2.27.1.linux-amd64/consoles /etc/prometheus/.
COPY --from=metrics /prometheus-2.27.1.linux-amd64/console_libraries /etc/prometheus/.
COPY --from=metrics /prometheus-2.27.1.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml

# get supervisor configuration file
COPY supervisord.conf /etc/

# get the go runtime
COPY --from=go /go /go
COPY --from=go /usr/local/go /usr/local/go
ENV PATH $PATH:/usr/local/go/bin:/home/galileo:/home/galileo/.local/bin

# get the Caddy server executable
# copy the caddy server build into this container
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/

# install the harmony node and cli binaries
RUN curl -LO https://harmony.one/hmycli && mv hmycli hmy && chmod +x hmy && \
    curl -LO https://harmony.one/binary && mv binary harmony && chmod +x harmony

WORKDIR /theia

# set environment variable to look for plugins in the correct directory
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/theia/plugins
ENV USE_LOCAL_GIT true

# set login credintials and write them to text file
ENV USERNAME "myuser"
ENV PASSWORD "testpass2"
RUN echo "basicauth /* {" >> /tmp/hashpass.txt && \
    echo "    {env.USERNAME}" $(caddy hash-password -plaintext $(echo $PASSWORD)) >> /tmp/hashpass.txt && \
    echo "}" >> /tmp/hashpass.txt

ENTRYPOINT ["sh", "-c", "supervisord"]