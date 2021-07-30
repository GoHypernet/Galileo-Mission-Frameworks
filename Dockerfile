# get the caddy executable
#FROM caddy AS caddy-build

# get the go executable 
FROM golang as go

FROM algorand/stable as ide-build

ARG XCADDY_URL="https://github.com/caddyserver/xcaddy/releases/download/v0.1.9/xcaddy_0.1.9_linux_amd64.tar.gz"
ARG CADDY_AUTH_JWT_URL=github.com/greenpau/caddy-auth-jwt
ARG CADDY_AUTH_PORTAL_URL=github.com/greenpau/caddy-auth-portal
ARG BCRYPT_CLI_URL=github.com/bitnami/bcrypt-cli

# enable noninteractive installation of deadsnakes/ppa
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# install node, yarn, and other tools
RUN apt update -y && apt install vim curl gcc g++ make libsecret-1-dev libx11-dev libxkbfile-dev supervisor -y && \
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

# Final build stage
FROM algorand/stable

# enable noninteractive installation of deadsnakes/ppa
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# install node, python, go, java, and other tools
RUN apt update -y && apt install vim tmux curl zip unzip supervisor git software-properties-common -y && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update -y && \
    apt-get install -y python3.8 python3-pip python3-dev libsecret-1-dev && \
    curl -fsSL https://deb.nodesource.com/setup_12.x | bash - && \
    apt install -y nodejs && \
    curl https://rclone.org/install.sh | bash 

# get the go runtime
COPY --from=go /go /go
COPY --from=go /usr/local/go /usr/local/go
ENV GOPATH=/usr/local/go
ENV PATH $PATH:/usr/local/go/bin:/home/galileo:/home/galileo/.local/bin:/home/galileo/go/bin

# add galileo non-root user
RUN useradd -ms /bin/bash galileo
COPY .theia /home/galileo/.theia
RUN chmod a+rwx /home/galileo/.theia; 

WORKDIR /home/galileo
# get the Caddy server executable
# copy the caddy server build into this container
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
# RUN wget -O /tmp/xcaddy.tar.gz ${XCADDY_URL}; \
#     tar x -z -f /tmp/xcaddy.tar.gz -C /usr/bin xcaddy; \
#     rm -f /tmp/xcaddy.tar.gz;
RUN xcaddy build --with github.com/greenpau/caddy-auth-jwt --with github.com/greenpau/caddy-auth-portal
RUN mv caddy /usr/bin/caddy
COPY Caddyfile /etc/
COPY users.json /etc/gatekeeper/
COPY header.html /etc/assets/
RUN chmod a+rwx /etc/Caddyfile && chmod a+r /etc/gatekeeper/users.json
RUN chmod -R a+rwx /tmp/

RUN go get -u github.com/bitnami/bcrypt-cli

ENV USERNAME "a"
ENV PASSWORD "a"
RUN sed -i 's,"username": "","username": "'"$USERNAME"'",1' /etc/gatekeeper/users.json && \
    sed -i 's,"hash": "","hash": "'"$(echo -n "$(echo $PASSWORD)" | bcrypt-cli -c 10 )"'",1' /etc/gatekeeper/users.json

# edit the node configuration file for operating as a relay node
RUN mkdir /theia && \
    cp -r /root/node/* /home/galileo/. && \
    cp /home/galileo/data/config.json.example /home/galileo/data/config.json && \
    sed -i 's/"NetAddress": "",/"NetAddress": ":4161",/g' /home/galileo/data/config.json && \
    sed -i 's/"EnableDeveloperAPI": false,/"EnableDeveloperAPI": true,/g' /home/galileo/data/config.json && \
    sed -i 's/"EndpointAddress": "127.0.0.1:0",/"EndpointAddress": "127.0.0.1:8080",/g' /home/galileo/data/config.json && \
    sed -i 's/"IncomingConnectionsLimit": 750,/"IncomingConnectionsLimit": 750,/g' /home/galileo/data/config.json && \
    chmod -R a+rwx /home/galileo
WORKDIR /theia

# switch to non-root user
USER galileo
WORKDIR /theia

# get the IDE
COPY --from=ide-build /theia /theia
# get superviserd
COPY supervisord.conf /etc/

# set environment variable to look for plugins in the correct directory
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/theia/plugins
ENV USE_LOCAL_GIT true

ENV ALGORAND_DATA /home/galileo/data

# # set login credintials and write them to text file


# RUN echo "basicauth /* {" >> /tmp/hashpass.txt && \
#     echo "    {env.USERNAME}" $(caddy hash-password -plaintext $(echo $PASSWORD)) >> /tmp/hashpass.txt && \
#     echo "}" >> /tmp/hashpass.txt

ENTRYPOINT ["sh", "-c", "supervisord"]