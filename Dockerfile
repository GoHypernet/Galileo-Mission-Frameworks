# use alpine base for small
FROM alpine
COPY vina/. /usr/loca/bin/.

# run as the user "galileo" with associated working directory
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

COPY runvina.sh /usr/local/bin/.

ENTRYPOINT ["sh","runvina.sh"]
