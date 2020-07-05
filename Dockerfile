FROM ubuntu:16.04
# Builds AmberTools and creates an image with a 'sander' entrypoint.
ENV AMBER_VERSION 20
# if building ambertools 19, the tar file unpacks to a folder called amber18 for some reason
#ENV WHAT_IT_UNPACKS_TO amber18
# if building ambertools 20, the tar file unpacks to a folder called amber20_src
ENV WHAT_IT_UNPACKS_TO amber20_src


RUN apt-get update -y
RUN apt-get install -y csh flex patch gfortran g++ make xorg-dev bison libbz2-dev python3 python3-dev python3-pip mpich libmpich-dev ssh && pip3 install --upgrade pip
#RUN apt-get install -y csh flex patch gfortran g++ make xorg-dev bison libbz2-dev python3 python3-dev python3-pip openmpi-bin libopenmpi-dev ssh && pip3 install --upgrade pip
ADD AmberTools${AMBER_VERSION}.tar.bz2 /
ENV AMBERHOME /amber${AMBER_VERSION}
RUN mv /${WHAT_IT_UNPACKS_TO} /amber${AMBER_VERSION} && cd ${AMBERHOME} && echo 'Y' | ./configure --with-python /usr/bin/python3 gnu
RUN cd ${AMBERHOME} && . ./amber.sh && make -j8 install
RUN cd ${AMBERHOME} && make clean
RUN cd ${AMBERHOME} && echo 'Y' | ./configure --with-python /usr/bin/python3 -mpi gnu
RUN cd ${AMBERHOME} && . ./amber.sh && make -j8 install

FROM ubuntu:16.04
ENV AMBER_VERSION 19
COPY --from=0 /amber${AMBER_VERSION}/amber.sh /amber${AMBER_VERSION}/amber.sh
COPY --from=0 /amber${AMBER_VERSION}/bin /amber${AMBER_VERSION}/bin
COPY --from=0 /amber${AMBER_VERSION}/lib /amber${AMBER_VERSION}/lib
COPY --from=0 /amber${AMBER_VERSION}/dat /amber${AMBER_VERSION}/dat
RUN apt-get update -y
RUN apt-get install -y python3 mpich ssh libgfortran3 python3-pip
#RUN apt-get install -y python3 openmpi-bin ssh libgfortran3 python3-pip
RUN pip3 install --upgrade pip && pip3 install numpy
RUN echo 'source $AMBERHOME/amber.sh' >> /.bashrc
RUN echo '#!/bin/bash' > /usr/local/bin/mysander && echo 'cores=`nproc --all`' >> /usr/local/bin/mysander && echo 'source ${AMBERHOME}/amber.sh && mpirun -np $cores --allow-run-as-root sander.MPI $@' >> /usr/local/bin/mysander && chmod +x /usr/local/bin/mysander
ENV AMBERHOME /amber${AMBER_VERSION}
ENV PATH "${AMBERHOME}/bin:${PATH}"
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo
ENTRYPOINT ["bash","run.sh"]
