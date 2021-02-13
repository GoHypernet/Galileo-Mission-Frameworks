FROM nginx:1.17.6

# install geth and nginx
RUN apt update -y \
  && apt install -y software-properties-common gpg \
  && add-apt-repository -y ppa:ethereum/ethereum \ 
  && apt update -y \
  && apt install -y \
    ethereum \
	nginx \
    supervisor \
	vim \
  && rm -rf /var/lib/apt/lists/*

# add non-root galileo user 
RUN useradd -ms /bin/bash galileo

# copy nginx configuration file into container
copy nginx.conf /etc/nginx/nginx.conf

## add permissions for galileo user
RUN chown -R galileo:galileo /app && chmod -R 755 /app && \
        chown -R galileo:galileo /var/cache/nginx && \
        chown -R galileo:galileo /var/log/nginx && \
        chown -R galileo:galileo /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
        chown -R galileo:galileo /var/run/nginx.pid

USER galileo
WORKDIR /home/galileo

# add the superviserd configuration file
COPY supervisord.conf /etc/


# use supervisord to start geth and caddy
CMD ["sh", "-c", "supervisord"]