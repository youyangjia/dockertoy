FROM ubuntu:bionic

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND noninteractive

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
        libssl1.0.0 \
        libsasl2-dev \
        libssl1.0-dev \
        bats \
        curl \
        wget \
        sudo \
        git \
        nodejs-dev \
        node-gyp \
        npm \
        libfontconfig \
        r-base-dev \
        r-cran-evaluate \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#######
# OpenJDK 8
#######
RUN apt-get -q update \
    && apt-get -q install -y --no-install-recommends openjdk-8-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# phantomjs 2.1.1 require libicu55 which only in ubuntu xenial
RUN echo "deb http://ports.ubuntu.com/ubuntu-ports xenial main universe" >> /etc/apt/sources.list
RUN apt-get -q update \
    && apt-get -q install -y libicu55 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://github.com/liusheng/phantomjs/releases/download/2.1.1/phantomjs-2.1.1-linux-aarch64.tar.bz2 | tar xj -C /tmp/ \
    && cp /tmp/phantomjs-2.1.1-linux-aarch64/bin/phantomjs /usr/bin/

RUN useradd -m -d /home/zeppelin -s /bin/bash zeppelin && echo zeppelin:zeppelin | chpasswd && adduser zeppelin sudo
RUN echo "zeppelin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER zeppelin
WORKDIR /home/zeppelin

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-arm64
ENV protoc_grpc_version 1.4.0

RUN mkdir -p ~/tools \
    && cd ~/tools  \
    && mkdir -p ~/tools/maven \
    && curl -sL https://archive.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz | tar zx --strip-components 1 -C ~/tools/maven/
ENV PATH $PATH:/home/zeppelin/tools/maven/bin

RUN mkdir -p ~/.m2/repository/io/grpc/protoc-gen-grpc-java/${protoc_grpc_version}/ \
    && cd ~/.m2/repository/io/grpc/protoc-gen-grpc-java/${protoc_grpc_version}/ \
    && curl -L -O -s -S http://home.apache.org/~aajisaka/repository/io/grpc/protoc-gen-grpc-java/1.15.1/protoc-gen-grpc-java-1.15.1-linux-aarch_64.exe \
    && curl -L -O -s -S http://home.apache.org/~aajisaka/repository/io/grpc/protoc-gen-grpc-java/1.15.1/protoc-gen-grpc-java-1.15.1.pom \
    && curl -L -O -s -S http://home.apache.org/~aajisaka/repository/io/grpc/protoc-gen-grpc-java/1.15.1/protoc-gen-grpc-java-1.15.1.pom.sha1 \
    && mv protoc-gen-grpc-java-1.15.1.pom protoc-gen-grpc-java-${protoc_grpc_version}.pom \
    && mv protoc-gen-grpc-java-1.15.1-linux-aarch_64.exe protoc-gen-grpc-java-${protoc_grpc_version}-linux-aarch_64.exe \
    && mv protoc-gen-grpc-java-1.15.1.pom.sha1 protoc-gen-grpc-java-${protoc_grpc_version}.pom.sha1

RUN git clone https://github.com/apache/zeppelin.git \
    && cd ~/zeppelin \
    && sed -i 's#<protocArtifact>com.google.protobuf:protoc:3.3.0:exe:${os.detected.classifier}</protocArtifact>#<protocArtifact>io.github.bzhaoopenstack:protoc:3.3.0:exe:${os.detected.classifier}</protocArtifact>#g' zeppelin-jupyter-interpreter/pom.xml \
    && mvn clean package -Pbuild-distr -DskipTests
