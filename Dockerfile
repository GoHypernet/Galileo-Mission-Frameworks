FROM ubuntu:18.04 AS amberbuild

# Builds AmberTools and creates an image with a 'sander' entrypoint.
ENV AMBER_VERSION 20

# if building ambertools 19, the tar file unpacks to a folder called amber18 for some reason
#ENV WHAT_IT_UNPACKS_TO amber18

# if building ambertools 20, the tar file unpacks to a folder called amber20_src
ENV WHAT_IT_UNPACKS_TO amber20_src

RUN apt-get update -y
RUN apt-get install -y csh flex patch gfortran g++ make xorg-dev \
    bison libbz2-dev python3 python3-dev python3-pip mpich \
	libmpich-dev ssh && pip3 install --upgrade pip

ADD AmberTools${AMBER_VERSION}.tar.bz2 /
ENV AMBERHOME /${WHAT_IT_UNPACKS_TO}
WORKDIR ${AMBERHOME}

RUN echo 'Y' | ./configure --with-python /usr/bin/python3 gnu
RUN . ./amber.sh && make -j8 install
RUN make clean
RUN echo 'Y' | ./configure --with-python /usr/bin/python3 -mpi gnu
RUN . ./amber.sh && make -j8 install

FROM ubuntu:18.04

RUN apt-get update -y && \
    apt-get install -y python3 mpich ssh libgfortran3 python3-pip

ENV AMBER_VERSION 20
ENV WHAT_IT_UNPACKS_TO amber20_src

COPY --from=amberbuild /${WHAT_IT_UNPACKS_TO}/amber.sh /amber${AMBER_VERSION}/amber.sh
COPY --from=amberbuild /${WHAT_IT_UNPACKS_TO}/bin /amber${AMBER_VERSION}/bin
COPY --from=amberbuild /${WHAT_IT_UNPACKS_TO}/lib /amber${AMBER_VERSION}/lib
COPY --from=amberbuild /${WHAT_IT_UNPACKS_TO}/dat /amber${AMBER_VERSION}/dat

RUN pip3 install --upgrade pip && pip3 install numpy
RUN echo 'source $AMBERHOME/amber.sh' >> /.bashrc

ENV AMBERHOME /amber${AMBER_VERSION}
ENV PATH "${AMBERHOME}/bin:${PATH}"
ENV PYTHONPATH "${AMBERHOME}/lib/python3.6/site-packages:${PYTHONPATH}"

RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo
ENV GALILEO_RESULTS_DIR /home/galileo

ENTRYPOINT ["bash","run.sh"]

