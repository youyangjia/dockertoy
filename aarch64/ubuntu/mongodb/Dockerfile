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

## Old mongodb version using python2 as below
#yum -y install libcurl-devel libyaml libyaml-devel python-setuptools libcurldevel python-devel libffi-devel libssl-devel
#apt-get install libcurl4-openssl-dev libyaml-dev python-setuptools libpython-dev libffi-dev libssl-dev -y

## lastest mongodb version using python3 as below
apt-get install python3-setuptools libpython3-dev libssl-dev libffi-dev python3-pip -y
apt-get install libcurl4-openssl-dev libyaml-dev -y
apt-get install build-essential -y
apt-get install libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev -y
# python3-pymongo is used for testing mongodb python tests
apt-get install python3-pymongo -y

# Install deps
RUN cd && \
    apt-get install libcurl4-openssl-dev libyaml-dev python-setuptools libpython-dev -y




# Compile cmake
RUN cd && \
    wget https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz && \
    tar -zxvf cmake-3.5.2.tar.gz && \
    cd cmake-3.5.2 && \
    ./bootstrap && \
    make && \
    make install && \
    cmake --version && \
    which cmake


# install gcc deps
# configure: error: Building GCC requires GMP 4.2+, MPFR 2.4.0+ and MPC 0.8.0+.
# gmp first, and then mpfr and mpc GMP > MPFR > MPC
# gmp
#apt-get install M4 texinfo -y
cd
apt-get install texinfo -y
wget ftp://ftp.gnu.org/gnu/gmp/gmp-5.0.1.tar.bz2
tar -jxvf gmp-5.0.1.tar.bz2
cd gmp-5.0.1
# will raise can not guess the build, so we must specific the build from exec /usr/share/misc/config.guess
./configure --prefix=/usr/local/gmp-5.0.1 --build=aarch64-unknown-linux-gnu
make && make install
# mpfr
cd
apt-get install autotools-dev automake -y
wget https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.0.tar.xz
tar -xvf mpfr-3.1.0.tar.xz
cd mpfr-3.1.0
./configure --prefix=/usr/local/mpfr-3.1.0 --with-gmp=/usr/local/gmp-5.0.1 --build=aarch64-unknown-linux-gnu
make && make install
# mpc
cd
wget https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
tar -zxvf mpc-1.1.0.tar.gz
cd mpc-1.1.0
./configure --prefix=/usr/local/mpc-1.1.0 --with-gmp=/usr/local/gmp-5.0.1 --with-mpfr=/usr/local/mpfr-3.1.0  --build=aarch64-unknown-linux-gnu
make && make install

# refresh ldconfig
echo "/usr/local/gmp-5.0.1/lib" >> vi /etc/ld.so.conf
echo "/usr/local/mpfr-3.1.0/lib" >> vi /etc/ld.so.conf
echo "/usr/local/mpc-1.1.0/lib" >> vi /etc/ld.so.conf
ldconfig
ldconfig -p

# Compile gcc
# Specify the gcc deps which we build above
RUN cd && \
    wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.gz && \
    tar -xvf gcc-9.2.0.tar.gz && \
    cd gcc-9.2.0 && \
    ./configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --enable-bootstrap --with-gmp=/usr/local/gmp-5.0.1 --with-mpc=/usr/local/mpc-1.1.0 --with-mpfr=/usr/local/mpfr-3.1.0 && \
    make -j 96 && \
    make install && \
    gcc -v && \
    which gcc


## MongoDB python deps install
# cython install
cd /home
git clone https://github.com/cython/cython.git
cd /home/cython
python3 setup.py install

# pyyaml install
cd /home
git clone https://github.com/yaml/pyyaml.git
#git clone -b 3.11 https://github.com/yaml/pyyaml.git
cd /home/pyyaml
python3 setup.py install

# typing install
cd /home
git clone https://github.com/python/typing.git
#git clone -b 3.6.1 https://github.com/python/typing.git
cd /home/typing
python3 setup.py install

# cheetah3 install
cd /home
git clone https://github.com/CheetahTemplate3/cheetah3.git
#git clone -b 3.0.0 https://github.com/CheetahTemplate3/cheetah3.git
cd /home/cheetah3
python3 setup.py install





# Download mongodb source code and prepare compiling
# install mongodb python3 deps
cd
git clone https://github.com/mongodb/mongo.git
cd mongo
pip3 install -r buildscripts/requirements.txt


# python2 version
#python2 buildscripts/scons.py MONGO_VERSION=5.0.0 all CFLAGS="- march=armv8-a+crc -mtune=generic" -j64 --disable-warnings-as-errors 
# python3 version
#python3 buildscripts/scons.py MONGO_VERSION=5.0.0 all CFLAGS="-march=armv8-a+crc -mtune=generic" -j64 --disable-warnings-as-errors 
#python3 buildscripts/scons.py MONGO_VERSION=5.0.0 all   CFLAGS="-march=armv8-a+crc -mtune=generic" -j4 --disable-warnings-as-errors 

# the above will run so long time, as it includes so many things in it. So we need to change it from 'all' to just 'core'
python3 buildscripts/scons.py MONGO_VERSION=5.0.0 core CFLAGS="-march=armv8-a+crc -mtune=generic" -j4 --disable-warnings-as-errors 

mkdir /usr/local/mongo
python3 buildscripts/scons.py MONGO_VERSION=5.0.0 --prefix=/usr/local/mongo --disable-warnings-as-errors CFLAGS="-march=armv8-a+crc" install -j4

cd /usr/local/mongo/bin 
strip mongos 
strip mongod 
strip mongo
