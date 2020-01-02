FROM ubuntu:bionic

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

######
# Install common dependencies from packages. Versions here are either
# sufficient or irrelevant.
# WARNING: DO NOT PUT JAVA APPS HERE! Otherwise they will install default
# Ubuntu Java.  See Java section below!
######
RUN apt-get -q update \
    && apt-get -q install -y --no-install-recommends \
        build-essential \
        autoconf \
        automake \
        libtool \
        cmake \
        zlib1g-dev \
        pkg-config \
        libssl-dev \
        libssl1.0.0 \
        libsasl2-dev \
        bats \
        curl \
        wget \
        sudo \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

######
# Install Google Protobuf 3.7.1 (2.6.0 ships with Xenial)
######
ENV protoc_version 3.3.0

RUN mkdir -p /opt/protobuf-src \
    && cd /opt/protobuf-src
    && wget https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protobuf-java-${protoc_version}.tar.gz \
    && tar xzf /opt/protobuf-java-${protoc_version}.tar.gz --strip-components 1 -C /opt/protobuf-src \
    && cd /opt/protobuf-src \
    && ./configure --prefix=/opt/protobuf --disable-shared \
    && make install \
    && cd /root \
    && rm -rf /opt/protobuf-src
