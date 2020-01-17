FROM ubuntu:bionic

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get -q update \
    && apt-get -y install libxml2-dev libboost-dev wget git build-essential cmake

RUN wget http://www.colm.net/files/ragel/ragel-6.10.tar.gz \
    && tar -zxf ragel-6.10.tar.gz \
    && cd ./ragel-6.10 \
    && ./configure \
    && make -j32 \
    && make install

RUN git clone https://github.com/tqltech/hyperscan.git

RUN wget https://sourceforge.net/projects/pcre/files/pcre/8.43/pcre-8.43.tar.gz \
    && tar -zxf pcre-8.43.tar.gz \
    && cp -rf ./pcre-8.43 ./hyperscan/pcre

RUN cd ./hyperscan \
    && rm -rf build \
    && mkdir build \
    && cd build \
    && cmake ..  \
    && make -j32 \
    && ./bin/unit-hyperscan

