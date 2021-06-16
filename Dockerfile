# get the caddy executable
FROM caddy AS caddy-build

FROM connextproject/vector_node:0.2.5-beta.18 as ide-build

RUN apk update && \
    apk add git openssh bash python3 python3-dev py-pip make gcc g++ libx11-dev libxkbfile-dev supervisor && \
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
    apk add nodejs npm

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

# get the router applications
FROM connextproject/vector_router:0.2.5-beta.18 AS router-layer
	
# Final build stage
FROM connextproject/vector_node:0.2.5-beta.18

RUN apk update && \
    apk add git zip unzip openssh bash python3 python3-dev py-pip make gcc g++ libx11-dev libxkbfile-dev supervisor && \
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
    apk add nodejs npm && \
	curl https://rclone.org/install.sh | bash 

# add galileo non-root user
RUN adduser -S galileo
COPY .vscode /app/.vscode
COPY .theia /app/.theia
RUN chmod a+rwx /home/galileo
RUN chmod a+rwx /app

COPY --from=router-layer /app /router

# edit the node configuration file for operating as a relay node
RUN mkdir /theia
WORKDIR /theia

# switch to non-root user
#USER galileo
WORKDIR /theia

# get the IDE
COPY --from=ide-build /theia /theia
	
# get superviserd
COPY supervisord.conf /etc/
COPY node.config.json /app/config.json
COPY router.config.json /router.config.json

# set environment variable to look for plugins in the correct directory
# set environment variable to look for plugins in the correct directory
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/theia/plugins
ENV USE_LOCAL_GIT true0

# get the Caddy server executable
# copy the caddy server build into this container
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/

# Vector environment variables
RUN mkdir /database
ENV VECTOR_PROD true
ENV VECTOR_SQLITE_FILE "/database/store.db"

# # set login credintials and write them to text file
ENV USERNAME "a"
ENV PASSWORD "a"
RUN echo "basicauth /* {" >> /tmp/hashpass.txt && \
    echo "    {env.USERNAME}" $(caddy hash-password -plaintext $(echo $PASSWORD)) >> /tmp/hashpass.txt && \
    echo "}" >> /tmp/hashpass.txt

ENTRYPOINT ["sh", "-c", "supervisord"]