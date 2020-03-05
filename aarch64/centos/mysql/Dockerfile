FROM centos:centos7

# Install deps
RUN cd && \
    yum update -y && \
    yum -y install bison ncurses ncurses-devel libaio-devel openssl openssl-devel gmp gmp-devel mpfr mpfr-devel libmpc libmpc-devel git wget which && \
    yum groupinstall "Development Tools" -y

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

# Compile gcc
RUN cd && \
    wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.gz && \
    tar -xvf gcc-9.2.0.tar.gz && \
    cd gcc-9.2.0 && \
    ./configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --enable-bootstrap && \
    make -j 96 && \
    make install && \
    gcc -v && \
    which gcc

	
## Compile boost 1-70-0
#RUN yum install python-devel -y
#RUN cd && \
#    git clone --recursive https://github.com/boostorg/boost.git && \
#    cd boost && \
#    git checkout boost-1.70.0 && \
#    ./bootstrap.sh && \
#    ./b2 install -q

# Build and install mysql master
RUN cd && \
    git clone https://github.com/mysql/mysql-server.git && \
	cd /home && \
    mkdir boost-1-70-0 && \
    wget https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz && \
    cd ~/mysql-server/ && \
	cmake . -DCMAKE_INSTALL_PREFIX=/home/mysql-master/mysql -DMYSQL_DATADIR=/data/mysql-master/mysql -DSYSCONFDIR=/etc -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DENABLE_DTRACE=0 -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DCMAKE_C_COMPILER=/usr/bin/gcc -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/home/boost-1-70-0/ -DFORCE_INSOURCE_BUILD=1 && \
    make && \
    make install
