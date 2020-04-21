FROM alpine
COPY vina /bin/vina
COPY runvina.sh /runvina.sh
RUN mkdir /autodock
WORKDIR /autodock
ENTRYPOINT ["sh","/runvina.sh"]