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

#yum install -y ncurses ncurses-devel libaio-devel gmp gmp-devel mpfr mpfr-devel libmpc libmpc-devel libcurl-devel readline-devel zlib-devel openssl*  git perl* bison net-tools 

apt-get install libncurses5 libncurses5-dev libncursesw5-dev libaio-dev zlib1g zlib1g-dev bzip2 libbz2-dev readline-common libreadline-dev bison libgmp-dev libmpfr-dev libmpc-dev -y



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


# download boost
cd /home
wget https://nchc.dl.sourceforge.net/project/boost/boost/1.70.0/boost_1_70_0.tar.gz 
tar xvf boost_1_70_0.tar.gz

## clone percona and prepare
cd
git clone https://github.com/percona/percona-server
cd percona-server
cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_CONFIG=mysql_release -DFEATURE_SET=community -DWITH_BOOST=/home/boost_1_70_0 -DCMAKE_INSTALL_PREFIX=/usr/local/percona -DMYSQL_DATADIR=/data/percona -DSYSCONFDIR=/etc -DWITHOUT_TOKUDB=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWIYH_SSL=system -DWITH_ZLIB=system -DWITH_LOBWRAP=0 -DMYSQL_UNIX_ADDR=/data/percona/run/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DFORCE_INSOURCE_BUILD=1 

make
make install
