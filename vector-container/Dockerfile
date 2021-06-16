FROM node:12 as base_builder

WORKDIR /root

ENV HOME /root

RUN apt update && apt install -y bash curl g++ gcc git jq make python openssl
RUN npm install -g npm@6.14.7
RUN npm i -g @prisma/cli@v2.16.1

# RUN git clone --branch vector-0.2.5-beta.6 https://github.com/connext/vector.git /root/vector
# RUN cd vector
# RUN make server-node-bundle && make router-bundle

COPY build/ .

FROM base_builder as node_builder
WORKDIR /root/node

ENV NODE_BASE build/vector/modules/server-node
ENV ROUTER_BASE build/vector/modules/router

COPY build/vector/modules/server-node/ops ops
COPY build/vector/modules/server-node/ops/package.json package.json

RUN npm install

COPY build/vector/modules/server-node/prisma-postgres prisma-postgres
# COPY build/vector/modules/server-node/dist dist
# COPY build/vector/modules/server-node/dist/generated/db-client /root/node/.prisma/client
# Copy linux musl as debian openssl because musl is selected during my build and the runtime requires openssl one
# COPY build/vector/modules/server-node/dist/generated/db-client/query-engine-linux-musl /root/node/dist/query-engine-debian-openssl-1.1.x

FROM base_builder as router_builder
WORKDIR /root/router

COPY build/vector/modules/router/ops/package.json package.json

RUN npm install --only=prod

COPY build/vector/modules/router/ops ops
COPY build/vector/modules/router/prisma-postgres prisma-postgres
# COPY build/vector/modules/router/dist dist
RUN ln -s dist/prisma-postgres prisma
# COPY build/vector/modules/router/dist/generated/db-client /root/router/prisma/client

FROM ubuntu:18.04
WORKDIR /root
# 80 AND 443 for proxy. Other ports: 5432 database, 8000 router/node
EXPOSE 80
EXPOSE 443
EXPOSE 5432
EXPOSE 8000

ENV NODE_ENV=production
ENV DEBIAN_FRONTEND=noninteractive
ENV VECTOR_PROD true
ENV VECTOR_ENV production
ENV VECTOR_JWT_SIGNER_PRIVATE_KEY -----BEGIN RSA PRIVATE KEY-----MIIEowIBAAKCAQEAqU/GXp8MqmugQyRk5FUFBvlJt1/h7L3Crzlzejz/OxriZdq/lBNQW9S1kzGc7qjXprZ1Kg3zP6irr6wmvP0WYBGltWs2cWUAmxh0PSxuKdT/OyL9w+rjKLh4yo3ex6DX3Ij0iP01Ej2POe5WrPDS8j6LT0s4HZ1FprL5h7RUQWV3cO4pF+1kl6HlBpNzEQzocW9ig4DNdSeUENARHWoCixE1gFYo9RXm7acqgqCk3ihdJRIbO4e/m1aZq2mvAFK+yHTIWBL0p5PF0Fe8zcWdNeEATYB+eRdNJ3jjS8447YrcbQcBQmhFjk8hbCnc3Rv3HvAapk8xDFhImdVF1ffDFwIDAQABAoIBAGZIs2ZmX5h0/JSTYAAw/KCB6W7Glg4XdY21/3VRdD+Ytj0iMaqbIGjZz/fkeRIVHnKwt4d4dgN3OoEeVyjFHMdc4eb/phxLEFqiI1bxiHvtGWP4d6XsON9Y0mBL5NJk8QNiGZjIn08tsWEmA2bm9gkyj6aPoo8BfBqA9Q5uepgmYIPT2NtEXvTbd2dedAEJDJspHKHqBfcuNBVoVhUixVSgehWGGP4GX+FvAEHbawDrwULkMvgblH+X8nBtzikp29LNpOZSRRbqF/Da0AkluFvuDUUIzitjZs5koSEAteaulkZO08BMxtovQjh/ZPtVZKZ27POCNOgRsbm/lVIXRMECgYEA2TQQ2Xy6eO5XfbiT4ZD1Z1xe9B6Ti7J2fC0ZNNSXs4DzdYVcHNIuZqfK6fGqmByvSnFut7n5Po0z2FdXc7xcKFJdBZdFP3GLXbN9vpRPIk9b6n+0df471uTYwVocmAGXez++y73j5XzHQQW4WmmC5SlKjQUWCGkuzISVjRDtlZ0CgYEAx43KPrJxSijjE2+VWYjNFVuv6KilnWoA8I2cZ7TtPi4h//r5vyOUst0egR3lJ7rBof74VttQPvqAk3GN697IrE/bSwefwG2lM1Ta0KB3jn6b/iT4ckmaOB+v6aDHq/GPW6l/sxD0RIEelRYZlsNLepRgKhcQckhjnWzQuGWSl0MCgYBYJQ0BdeCm2vKejp1U2OL+Qzo1j4MJGi+DTToBepTlv9sNQkWTXKh/+HAcaHp2qI1qhIYOAWbov5zemvNegH5Vzrb5Yd40VPvd1s2c3csPfW0ryQ+PItFd8BkWvl8EQQEcf04KmNE3fF/QP2YFKvR30z3x5LKAT08yqEuYp9oC8QKBgQCfc9XqGU3bEya3Lg8ptt0gtt2ty6xiRwSvMoiKeZCkgdpbH6EWMQktjvBD/a5Q+7KjjgfD54SMfj/lEPR1R9QTk8/HeTUWXsaFaMVbtQ0zSEm/Xq1DLTrUo8U9qmJCK0gA10SZwe9dGctlF36k8DJMpWjd2QYkO2GVthBld4wV3wKBgC7S4q0wmcrQIjyDIFmISQNdOAJhR0pJXG8mK2jECbEXxbKkAJnLj73DJ+1OVBlx4HXx54PiEkV3M3iTinf5tBSi8nA2D3s829F65XKFli1RC4rJv+2ygH8PnXX9rQKhK/v6/jeelKquH8zy894hLZe7feSsWV9GMgb5l9p+UzWB-----END RSA PRIVATE KEY-----
ENV VECTOR_JWT_SIGNER_PUBLIC_KEY -----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqU/GXp8MqmugQyRk5FUFBvlJt1/h7L3Crzlzejz/OxriZdq/lBNQW9S1kzGc7qjXprZ1Kg3zP6irr6wmvP0WYBGltWs2cWUAmxh0PSxuKdT/OyL9w+rjKLh4yo3ex6DX3Ij0iP01Ej2POe5WrPDS8j6LT0s4HZ1FprL5h7RUQWV3cO4pF+1kl6HlBpNzEQzocW9ig4DNdSeUENARHWoCixE1gFYo9RXm7acqgqCk3ihdJRIbO4e/m1aZq2mvAFK+yHTIWBL0p5PF0Fe8zcWdNeEATYB+eRdNJ3jjS8447YrcbQcBQmhFjk8hbCnc3Rv3HvAapk8xDFhImdVF1ffDFwIDAQAB-----END PUBLIC KEY-----
ENV VECTOR_MNEMONIC \"candy maple cake sugar pudding cream honey rich smooth crumble sweet treat\"
ENV VECTOR_ADMIN_TOKEN cxt1234
ENV VECTOR_PORT 5040

RUN apt update && apt upgrade -y && apt install -y software-properties-common jq nginx apache2-utils gettext-base
RUN add-apt-repository ppa:vbernat/haproxy-2.1 --yes && apt update -y
RUN apt install -y supervisor bash openssl curl postgresql ca-certificates sudo mariadb-server certbot net-tools netcat haproxy nodejs unzip npm wget
RUN wget https://raw.githubusercontent.com/vishnubob/wait-for-it/ed77b63706ea721766a62ff22d3a251d8b4a6a30/wait-for-it.sh > /bin/wait-for && chmod +x /bin/wait-for
RUN npm install -g n
RUN n 12.13.0
RUN npm install -g npm@6.14.7
RUN npm install -g prisma @prisma/client nodemon pino-pretty ts-node typescript @types/node

COPY --from=node_builder /root/node node
COPY --from=router_builder /root/router router
COPY build/vector/ops/proxy /root/proxy
COPY http.cfg /root/proxy/http.cfg
COPY supervisord.conf ./
COPY entrypoint.sh ./
COPY default.conf ./

## Setup for postgres
WORKDIR /root/postgres
RUN apt install -y gnupg dirmngr
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common postgresql-12 postgresql-client-12

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN sed -i "/^#listen_addresses/i listen_addresses='*'" /etc/postgresql/12/main/postgresql.conf
RUN sed -i "/^# DO NOT DISABLE\!/i # Allow access from any IP address" /etc/postgresql/12/main/pg_hba.conf
RUN sed -i "/^# DO NOT DISABLE\!/i host all all 0.0.0.0/0 md5\n\n\n" /etc/postgresql/12/main/pg_hba.conf

# set root password
RUN echo "root:root" | chpasswd

WORKDIR /root

RUN chmod +x /root/node/ops/entry.sh /root/router/ops/entry.sh /root/proxy/entry.sh /root/entrypoint.sh

COPY vector-config.json .
COPY build/vector/modules/router/prisma-postgres/schema.prisma /root/router/dist/schema.prisma
# COPY build/vector/modules/router/prisma-postgres/schema.prisma /prisma-postgres/schema.prisma
# COPY /root/router/prisma-postgres/schema.prisma /root/router/dist/schema.prisma
# RUN echo '127.0.0.1 router' >> /etc/hosts
ENV ROUTER_HOST localhost:8000
ENV NODE_HOST localhost:8001
ENV ADMIN_TOKEN cxt1234
ENV METRICS_URL http://localhost:8000/metrics
ENV AUTO_REBALANCE_URL http://localhost:8000/auto-rebalance

# get superviserd
COPY supervisord.conf /etc/

ENTRYPOINT ["sh", "-c", "supervisord"]