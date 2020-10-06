FROM golang:1.14-buster AS easy-novnc-build

# build easy-novnc
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM golang:1.14-buster AS caddy-build
WORKDIR /src
RUN echo 'module caddy' > go.mod && \
    echo 'require github.com/caddyserver/caddy/v2 v2.1.1' >> go.mod && \
    echo 'require github.com/mholt/caddy-webdav v0.0.0-20200523051447-bc5d19941ac3' >> go.mod
RUN echo 'package main' > caddy.go && \
    echo 'import caddycmd "github.com/caddyserver/caddy/v2/cmd"' >> caddy.go && \
    echo 'import _ "github.com/caddyserver/caddy/v2/modules/standard"' >> caddy.go && \
    echo 'import _ "github.com/mholt/caddy-webdav"' >> caddy.go && \
    echo 'func main() { caddycmd.Main() }' >> caddy.go
RUN go build -o /bin/caddy .

FROM qgis/qgis

# install bare minimum required to run GUI applications 
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

# install some general-purpose utilities 
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip && \
    rm -rf /var/lib/apt/lists

# copy configuration files and easy-novnc binary to this image
COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY menu.xml /etc/xdg/openbox/
COPY supervisord.conf /etc/
EXPOSE 8080

# set user properties appropriatly 
RUN groupadd --gid 1000 app && \
    useradd --home-dir /data --shell /bin/bash --uid 1000 --gid 1000 app && \
    mkdir -p /data
VOLUME /data

# copy the caddy server build into this container
COPY --from=caddy-build /bin/caddy /usr/local/bin/
COPY Caddyfile /etc/

# set the username and password hash for the caddy server
ENV APP_USERNAME "myusr"
ENV APP_PASSWORD_HASH "JDJhJDEwJHkySERNZVJlcUpoSkgvbldxRHZ5aHVHRjFDRXdDZXMvN0VpQ0ZKTncwaHJYQjBBdFdHYW0y"

CMD ["sh", "-c", "chown app:app /data /dev/stdout && exec gosu app supervisord"]