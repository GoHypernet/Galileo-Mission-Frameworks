# get the caddy executable
FROM caddy AS caddy-build

# Build stage for Galileo IDE
FROM tezos/tezos:latest-release as ide-build

USER root 

RUN apk update && \
    apk add git openssh bash python3 python3-dev py-pip make gcc g++ libx11-dev libxkbfile-dev supervisor && \
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
    apk add nodejs npm && \
	npm install yarn -g

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
	
# Final build stage for complete application
FROM tezos/tezos:latest-release

USER root

RUN apk update && \
    apk add git tmux vim zip unzip openssh bash python3 python3-dev py-pip make gcc g++ libx11-dev libxkbfile-dev supervisor && \
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
    apk add nodejs npm && \
	curl https://rclone.org/install.sh | bash 

# add IDE configs
COPY .vscode /home/tezos/.vscode
COPY .theia /home/tezos/.theia
RUN chmod -R a+rwx /home/tezos

# edit the node configuration file for operating as a relay node
RUN mkdir /theia
WORKDIR /theia

# get superviserd
COPY supervisord.conf /etc/

# switch to non-root user
USER tezos
WORKDIR /theia

# get the IDE
COPY --from=ide-build /theia /theia

# set environment variable to look for plugins in the correct directory
# set environment variable to look for plugins in the correct directory
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/theia/plugins
ENV USE_LOCAL_GIT true
ENV GALILEO_RESULTS_DIR /home/tezos

# get the Caddy server executable
# copy the caddy server build into this container
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/

# # set login credintials and write them to text file
# ENV USERNAME "a"
# ENV PASSWORD "a"
# RUN echo "basicauth /* {" >> /tmp/hashpass.txt && \
    # echo "    {env.USERNAME}" $(caddy hash-password -plaintext $(echo $PASSWORD)) >> /tmp/hashpass.txt && \
    # echo "}" >> /tmp/hashpass.txt

ENTRYPOINT ["sh", "-c", "supervisord"]