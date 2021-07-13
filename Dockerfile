# use alpine base for small
FROM alpine

# add bash shell for compatibility with singularity
RUN apk update && apk upgrade && apk add bash

# add the autodock executable to the user path
ADD autodock_vina_1_1_2_linux_x86.tgz .
ENV PATH=/autodock_vina_1_1_2_linux_x86/bin:$PATH
COPY runvina.sh /usr/local/bin/.
RUN chmod +x /usr/local/bin/runvina.sh

# run as the user "galileo" with associated working directory
RUN adduser -s /bin/sh galileo -u 1000 -D
USER galileo
WORKDIR /home/galileo

# set the results directory
ENV GALILEO_RESULTS_DIR /home/galileo

ENTRYPOINT ["sh","/usr/local/bin/runvina.sh"]
