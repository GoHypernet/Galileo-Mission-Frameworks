FROM ubuntu:16.04 as builder

RUN apt-get update --fix-missing \
    && apt-get install -y wget gcc make \
    && cd /usr/local/ \
    && wget -O mafft-7.427-without-extensions-src.tgz https://mafft.cbrc.jp/alignment/software/mafft-7.427-without-extensions-src.tgz \
    && tar -xzvf mafft-7.427-without-extensions-src.tgz \
    && rm -rf mafft-7.427-without-extensions-src.tgz \
    && cd mafft-7.427-without-extensions/core \
    && make \
    && make install \
    && cd /usr/local \
    && rm -rf /usr/local/mafft-7.427-without-extensions/ \
    && apt-get remove -y wget gcc make \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /pasteur

RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

ENV inputfile empty
ENV outputfile results.fasta

COPY mafft_run.sh .
ENTRYPOINT ["bash","mafft_run.sh"]
