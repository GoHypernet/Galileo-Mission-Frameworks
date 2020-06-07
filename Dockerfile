FROM ubuntu:16.04
# Builds AmberTools and creates an image with a 'sander' entrypoint.
ENV AMBER_VERSION 19

ADD /data/AmberTools${AMBER_VERSION}.tar.bz2 /root/
RUN apt-get update -y 
RUN apt-get install -y csh flex patch gfortran g++ make xorg-dev bison libbz2-dev python python-dev openmpi-bin libopenmpi-dev ssh
ENV AMBERHOME /root/amber${AMBER_VERSION}
RUN cd ${AMBERHOME} && echo 'Y' | ./configure --with-python /usr/bin/python gnu
RUN cd ${AMBERHOME} && . ./amber.sh && make install
RUN cd ${AMBERHOME} && make clean
RUN cd ${AMBERHOME} && echo 'Y' | ./configure --with-python /usr/bin/python -mpi gnu
RUN cd ${AMBERHOME} && . ./amber.sh && make install

FROM ubuntu:16.04
ENV AMBER_VERSION 19
COPY --from=0 /root/amber${AMBER_VERSION}/amber.sh /root/amber${AMBER_VERSION}/amber.sh
COPY --from=0 /root/amber${AMBER_VERSION}/bin /root/amber${AMBER_VERSION}/bin
COPY --from=0 /root/amber${AMBER_VERSION}/lib /root/amber${AMBER_VERSION}/lib
COPY --from=0 /root/amber${AMBER_VERSION}/dat /root/amber${AMBER_VERSION}/dat
RUN apt-get update -y 
RUN apt-get install -y python openmpi-bin ssh libgfortran3 python-pip
RUN pip install numpy
RUN echo 'source $AMBERHOME/amber.sh' >> /root/.bashrc
RUN echo '#!/bin/bash' > /usr/local/bin/mysander && echo 'cores=`nproc --all`' >> /usr/local/bin/mysander && echo 'source ${AMBERHOME}/amber.sh && mpirun -np $cores --allow-run-as-root sander.MPI $@' >> /usr/local/bin/mysander && chmod +x /usr/local/bin/mysander
ENV AMBERHOME /root/amber${AMBER_VERSION}
ENTRYPOINT ["/usr/local/bin/mysander"]
CMD []