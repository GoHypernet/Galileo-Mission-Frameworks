# get easy-novnc to run novnc from a single binary
FROM golang:1.14-buster AS easy-novnc-build

# build easy-novnc
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

# get the caddy executable
FROM caddy AS caddy-build

FROM ubuntu:18.04

# install bare minimum required to run GUI applications 
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu && \
    apt-get install -y libglu1-mesa libdbus-1-3 libnss3 libxcomposite1 libxcursor1 libxi6 libxtst6 libasound2 gdebi-core wget xterm htop openjdk-8-jdk openjdk-8-jre unzip && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

# install Rapid Miner
COPY rapidminer-studio-9.8.1.zip .
RUN unzip rapidminer-studio-9.8.1.zip && rm rapidminer-studio-9.8.1.zip

# copy configuration files and easy-novnc binary to this image
COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/easy-novnc
COPY menu.xml /etc/xdg/openbox/
COPY supervisord.conf /etc/

# add non-root user
# RUN useradd -ms /bin/bash galileo
# USER galileo
# WORKDIR /home/galileo

# copy the caddy server build into this container
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/

ENV USERNAME "myuser"
ENV PASSWORD "testpass"
RUN echo "basicauth /* {" >> /tmp/hashpass.txt && \
    echo "    {env.USERNAME}" $(caddy hash-password -plaintext $(echo $PASSWORD)) >> /tmp/hashpass.txt && \
    echo "}" >> /tmp/hashpass.txt

CMD ["sh", "-c", "supervisord"]