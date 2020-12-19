# get easy-novnc to run novnc from a single binary
FROM golang:1.14-buster AS easy-novnc-build

# build easy-novnc
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

# get the caddy executable
FROM caddy AS caddy-build

FROM qgis/qgis

# install bare minimum required to run GUI applications 
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu xterm htop && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

# copy configuration files and easy-novnc binary to this image
COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/easy-novnc
COPY menu.xml /etc/xdg/openbox/
COPY supervisord.conf /etc/

# add non-root user
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

# copy the caddy server build into this container
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/

# set the username and password hash (mypass) for the caddy server

ENV USERNAME "myuser"
ENV PASSWORD "testpass"
#RUN echo "basicauth /* {" >> /tmp/hashpass.txt && \
#    echo "    {env.USERNAME}" $(caddy hash-password -plaintext $(echo $PASSWORD)) >> /tmp/hashpass.txt && \
#    echo "}" >> /tmp/hashpass.txt

CMD ["sh", "-c", "supervisord"]