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
        ccache \
        libevent-dev \
        libapr1-dev \
        libffi-dev \
        libssl-dev \
        git \
        python-pip \
        python-dev \
        gcc \
        libsodium-dev \
        libcurl4-openssl-dev \
        libzstd1-dev \
        libldap2-dev \
        flex \
        libbz2-dev \
        bison \
        libpq-dev \
        postgresql-server-dev-all \
        postgresql-common \
        libyaml-dev \
        zlib1g \
        zlib1g-dev \
        sudo \
        vim \
        net-tools \
        less \
        iputils-ping \
        iproute2 \
        ssh \
        locales \
        locales-all \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

######
# Create test user with sudo priority
######
RUN useradd -m -d /home/greenplum -s /bin/bash greenplum && echo greenplum:greenplum | chpasswd && adduser greenplum sudo
RUN echo "greenplum ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER greenplum
WORKDIR /home/greenplum

######
# Genarate ssh connection without passwd to make sure demo cluster could be launched successful
######
RUN ssh-keygen -f ~/.ssh/id_rsa -t rsa -N '' \
    && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys


ENV SODIUM_INSTALL system
######
# install pip requirements
######
RUN pip install setuptools \
    && pip install wheel \
    && pip install --user "pyopenssl>=19.0.0" \
    && pip install --user --pre psutil \
    && pip install --user lockfile \
    && pip install --no-binary :all: pynacl \
    && pip install --user paramiko || true

######
# Clone gpdb source code
######
RUN mkdir -p /home/greenplum/src \
    && cd /home/greenplum/src \
    && git clone https://github.com/bzhaoopenstack/gpdb

## fetch fixed PR from https://github.com/bzhaoopenstack/gpdb/pull/4
RUN cd /home/greenplum/src/gpdb \
    && git fetch origin pull/4/head:test-branch \
    && git checkout test-branch

ENV TRAVIS_BUILD_DIR /home/greenplum/src/gpdb

######
# Compile and install gpdb
######
RUN cd ${TRAVIS_BUILD_DIR} \
    && ./configure --with-openssl --with-ldap --with-libcurl --prefix=${TRAVIS_BUILD_DIR}/gpsql --disable-orca --disable-gpcloud --enable-pxf --without-readline \
    && make \
    && make install

######
# Compile and install the external functions of gpdb
######
RUN source ${TRAVIS_BUILD_DIR}/gpsql/greenplum_path.sh \
    && cd ${TRAVIS_BUILD_DIR}/gpcontrib/orafce \
    && make install USE_PGXS=1 \
    && cd ${TRAVIS_BUILD_DIR}/gpcontrib/gpmapreduce \
    && sed -i 's/$(CC) $(CFLAGS) $(MAPREDOBJS) $(libpq_pgport) $(LDFLAGS) $(LIBS) -o $@$(X)/$(CC) $(CFLAGS) $(MAPREDOBJS) $(libpq_pgport) $(LDFLAGS) $(LIBS) -lyaml -o $@$(X)/g' ./Makefile \
    && make install

######
# Check the installed apps
######
RUN source ${TRAVIS_BUILD_DIR}/gpsql/greenplum_path.sh \
    && postgres --version \
    && initdb --version \
    && createdb --version \
    && psql --version \
    && gpssh --version \
    && gpmapreduce --version \
    && gpfdist --version

######
# RUN the small part check
# This step will fail, and willing to genarate the following error file
######
RUN cd /home/greenplum/src/gpdb \
    && source ${TRAVIS_BUILD_DIR}/gpsql/greenplum_path.sh \
    && make -s unittest-check || true


######
# Fix the issue before unittest-check
# issue: https://github.com/google/cmockery/issues/67
######
## remove mock error statement
RUN cd /home/greenplum/src/gpdb \
    && cat src/test/unit/mock/backend/libpq/pqexpbuffer_mock.c | grep -v 'check_expected(args);' > src/test/unit/mock/backend/libpq/pqexpbuffer_mock.c_new \
    && mv src/test/unit/mock/backend/libpq/pqexpbuffer_mock.c_new src/test/unit/mock/backend/libpq/pqexpbuffer_mock.c


## restart ssh to enable ssh localhost via Domain
######
# RUN the small part check
######
RUN cd /home/greenplum/src/gpdb \
    && source ${TRAVIS_BUILD_DIR}/gpsql/greenplum_path.sh \
    && make -s unittest-check | tee ~/unittest-check.log \
    && sudo service ssh start \
    && make -C gpAux/gpdemo cluster | tee ~/cluster-launch.log \
    && source gpAux/gpdemo/gpdemo-env.sh \
    && make -C src/test/regress installcheck-small | tee ~/installcheck-small.log || true \
    && make installcheck-world | tee ~/installcheck-world.log || true
