# get the caddy executable
FROM caddy AS caddy-build

FROM algorand/stable as ide-build

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
	
FROM algorand/stable

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# install node, python, go, java, and other tools
RUN apt update -y && apt install vim curl supervisor git software-properties-common -y && \
	add-apt-repository -y ppa:deadsnakes/ppa && \
	apt-get update -y && \
	apt-get install -y python3.8 python3-pip && \
	apt-get install -y 
    curl -fsSL https://deb.nodesource.com/setup_12.x | bash - && \
	apt install -y nodejs

RUN useradd -ms /bin/bash galileo

# edit the node configuration file for operating as a relay node
RUN mkdir /theia && \
    cp -r /root/node/* /home/galileo/. && \
	cp /home/galileo/data/config.json.example /home/galileo/data/config.json && \
	sed -i 's/"NetAddress": "",/"NetAddress": ":4161",/g' /home/galileo/data/config.json && \
	sed -i 's/"EnableDeveloperAPI": false,/"EnableDeveloperAPI": "true",/g' /home/galileo/data/config.json && \
	sed -i 's/"EndpointAddress": "127.0.0.1:0",/"EndpointAddress": "127.0.0.1:8080",/g' /home/galileo/data/config.json && \
	sed -i 's/"IncomingConnectionsLimit": 750,/"IncomingConnectionsLimit": 750,/g' /home/galileo/data/config.json && \
	chmod -R a+rwx /home/galileo
WORKDIR /theia

COPY --from=ide-build /theia /theia
	
COPY supervisord.conf /etc/

WORKDIR /theia

# set environment variable to look for plugins in the correct directory
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/theia/plugins
ENV USE_LOCAL_GIT true

ENV ALGORAND_DATA /home/galileo/data

# get the Caddy server executable
# copy the caddy server build into this container
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/

# set login credintials and write them to text file
#ENV USERNAME "myuser"
#ENV PASSWORD "testpass2"
#RUN echo "basicauth /* {" >> /tmp/hashpass.txt && \
#    echo "    {env.USERNAME}" $(caddy hash-password -plaintext $(echo $PASSWORD)) >> /tmp/hashpass.txt && \
#    echo "}" >> /tmp/hashpass.txt

USER galileo

ENTRYPOINT ["sh", "-c", "supervisord"]