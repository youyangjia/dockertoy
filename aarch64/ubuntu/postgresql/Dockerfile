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
        sudo \
        git \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


#yum -y install gcc gcc-c++ automake zlib zlib-devel bzip2 bzip2-devel bzip2- libs readline readline-devel bison gmp gmp-devel mpfr mpfr-devel libmpc libmpc-devel 


apt-get install zlib1g zlib1g-dev bzip2 libbz2-dev readline-common libreadline-dev bison libgmp-dev libmpfr-dev libmpc-dev -y
apt-get install flex -y


# Install deps
RUN cd && \
    apt-get install libcurl4-openssl-dev libyaml-dev python-setuptools libpython-dev -y

# Compile cmake
RUN cd && \
    wget https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz  --no-check-certificate && \
    tar -zxvf cmake-3.5.2.tar.gz && \
    cd cmake-3.5.2 && \
    ./bootstrap && \
    make && \
    make install && \
    cmake --version && \
    which cmake

# Compile gcc
# Specify the gcc deps which we build above
RUN cd && \
    wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.gz --no-check-certificate && \
    tar -xvf gcc-9.2.0.tar.gz && \
    cd gcc-9.2.0 && \
    ./configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --enable-bootstrap --with-gmp=/usr/local/gmp-5.0.1 --with-mpc=/usr/local/mpc-1.1.0 --with-mpfr=/usr/local/mpfr-3.1.0 && \
    make -j 96 && \
    make install && \
    gcc -v && \
    which gcc

# Fix "Problem with the SSL CA cert (path? access rights?)" during git clone
apt install ca-certificates -y

## clone postgresql and prepare
cd
git clone https://github.com/postgres/postgres.git
cd postgres
./configure --prefix=/usr/local/pgsql


#failed to add optimize options in src/Makefile.global like "-march=armv8-a+crc+lse", as we are in docker env.
#sed -i 's/‘`echo $abc`'/'`echo $abc` --ABC=1-2-3+5/g' src/Makefile.global
make && make install

export PATH=$PATH:/usr/local/pgsql/bin/
which psql
psql --version

