# get the caddy executable
FROM caddy AS caddy-build

FROM ubuntu:18.04

# install geth and nginx
RUN apt update -y \
  && apt install -y software-properties-common \
  && add-apt-repository -y ppa:ethereum/ethereum \ 
  && apt update -y \
  && apt install -y \
    ethereum \
    supervisor \
	vim \
  && rm -rf /var/lib/apt/lists/*

# add non-root galileo user 
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

# add the superviserd configuration file
COPY supervisord.conf /etc/

# copy the caddy server build into this container
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/

# use supervisord to start geth and caddy
CMD ["sh", "-c", "supervisord"]