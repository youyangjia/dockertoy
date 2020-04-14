FROM ubuntu:bionic

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install common tools
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

# install mysql deps
RUN apt-get install libaio1 libncurses5-dev bison -y && \
    apt-get install libgmp-dev libmpfr-dev libmpc-dev -y && \

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

# glibc upgrade due to gcc vesion is too high and raise 
# /usr/lib/aarch64-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.26' not found
run apt-get install software-properties-common -y && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt update && \
    apt-get install --only-upgrade libstdc++6 -y

# Build and install mysql master
RUN cd && \
    git clone https://github.com/mysql/mysql-server.git && \
    cd /home && \
    mkdir boost-1-70-0 && \
    cd boost-1-70-0 && \
    wget https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz && \
    cd ~/mysql-server/ && \
    cmake . -DCMAKE_INSTALL_PREFIX=/home/mysql-master/mysql -DMYSQL_DATADIR=/data/mysql-master/mysql -DSYSCONFDIR=/etc -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DENABLE_DTRACE=0 -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DCMAKE_C_COMPILER=/usr/bin/gcc -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/home/boost-1-70-0/ -DFORCE_INSOURCE_BUILD=1 && \
    make && \
    make install

# Prepare the env
RUN mkdir -p /data/mysql-master/mysql/ && \
    adduser mysql && \
    chown -R mysql:mysql /home/mysql-master/mysql && \
    chown -R mysql:mysql /data/mysql-master/mysql

	
# install sysbench deps for mysql and postgresql
RUN apt update && \
    apt-get -y install libmysqlclient-dev libssl-dev && \
    apt-get -y install libpq-dev && \
    apt-get -y install libtool

# Install sysbench
# ./configure --with-mysql --with-pgsql
RUN cd && \
    git clone https://github.com/akopytov/sysbench.git && \
	cd sysbench && \
	./autogen.sh && \
	./configure --with-mysql-includes=/home/mysql-master/mysql/include --with-mysql-libs=/home/mysql-master/mysql/lib/ --prefix=/home/sysbench-install/ && \
	make -j && \
	make install

# download test suite
RUN cd && \
    git clone https://github.com/bzhaoopenstack/benchmark-suites.git
## Run the test suite
## Notes: before running test, you should startup the mysqld with the below configuration
# cd ~/benchmark-suites/sysbench
# ./combi_1.sh cacheline64 or cacheline128

USER mysql

RUN cd /home/mysql-master/mysql/bin && \
    ./mysqld --initialize-insecure

# Run mysqld with mysql user and './mysqld &'
# need to config mysql.conf manually, such as the below config
# mysqld configuration
#[mysqld]
#basedir=/home/mysql-128-install/mysql
#datadir=/data/mysql-128/mysql
#port=4000
#socket=/tmp/n1.sock
#mysqlx-port=4001
#log-error-verbosity=3
#
## mysql client connection params
#max_prepared_stmt_count=1000000
#max_connections=2048
#back_log=2000
#
## buffer pool and redo-log file setting
## based on number of core
#innodb_buffer_pool_instances=8
## normally 75-90% of system memory.
#innodb_buffer_pool_size=28G
#innodb_log_file_size=2G
#innodb_log_buffer_size=64M
#innodb_buffer_pool_dump_at_shutdown=0
#innodb_buffer_pool_load_at_startup=0
#
## neighbors flushing turned off for SSD
#innodb_flush_neighbors=0
## recommended as innodb has its own buffer pool cache
#innodb_flush_method=O_DIRECT
#
## table open limits
#table_open_cache=4096
#table_open_cache_instances=64
#
## max should be = IOPS for the allocated vm
#innodb_io_capacity=12000
#innodb_io_capacity_max=16000
#
## read/write io threads
#innodb_read_io_threads=8
#innodb_write_io_threads=8
#innodb_purge_threads=4
## should not exceed number of buffer pool instance
#innodb_page_cleaners=4

# CMAKE OPTIONS for benchmark
#cmake . -DCMAKE_INSTALL_PREFIX=/home/mysql-128-install/mysql -DMYSQL_DATADIR=/data/mysql-128/mysql -DSYSCONFDIR=/etc -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DENABLE_DTRACE=0 -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DCMAKE_C_COMPILER=/usr/bin/gcc -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/home/boost-1-70-0/ -DFORCE_INSOURCE_BUILD=1 -DCPU_CACHE_LINESIZE_PADDING=128
#cmake . -DCMAKE_INSTALL_PREFIX=/home/mysql-64-install/mysql -DMYSQL_DATADIR=/data/mysql-64/mysql -DSYSCONFDIR=/etc -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DENABLE_DTRACE=0 -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DCMAKE_C_COMPILER=/usr/bin/gcc -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/home/boost-1-70-0/ -DFORCE_INSOURCE_BUILD=1
