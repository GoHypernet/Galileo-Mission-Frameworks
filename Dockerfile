FROM nvidia/cuda:10.2-runtime-ubuntu18.04

# add and unpack binaries
ADD NAMD_2.14b2_Linux-x86_64-multicore.tar.gz /namd-2.14b2
ADD NAMD_2.14b2_Linux-x86_64-multicore-CUDA.tar.gz /namd-2.14b2-cuda

# add chooser file to detect hardware and run on GPU if available
COPY namd-chooser.sh /usr/local/bin/namd2
RUN chmod +x /usr/local/bin/namd2

# add non-root user
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo
