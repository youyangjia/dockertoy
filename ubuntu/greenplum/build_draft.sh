# greenplum build
# root/non root
sudo apt update

sudo apt install ccache libevent-dev libapr1-dev libffi-dev libssl-dev -y

#pip install --user --upgrade pip
pip install --user "pyopenssl>=19.0.0"
pip install --user --pre psutil
pip install --user lockfile

sudo apt install libsodium-dev -y
export SODIUM_INSTALL=system
sudo pip install --no-binary :all: pynacl
pip install --user paramiko

#pip install --user setuptools

export TRAVIS_BUILD_DIR=/home/zuul/src/github.com/bzhaoopenstack/gpdb

sudo apt install libcurl4-openssl-dev libzstd1-dev -y

sudo apt install libldap2-dev flex libbz2-dev -y

sudo apt-get install bison -y

sudo ./configure --with-openssl --with-ldap --with-libcurl --prefix=${TRAVIS_BUILD_DIR}/gpsql --disable-orca --disable-gpcloud --enable-pxf --without-readline


sudo make
sudo make install
source ${TRAVIS_BUILD_DIR}/gpsql/greenplum_path.sh
cd ${TRAVIS_BUILD_DIR}/gpcontrib/orafce
sudo apt-get install libpq-dev postgresql-server-dev-all postgresql-common -y
sudo make install USE_PGXS=1


cd ${TRAVIS_BUILD_DIR}/gpcontrib/gpmapreduce
sudo apt install libyaml-dev -y
# change Makefile in gpmapreduce
# root@linaro2:/opt/bzhao_test/greenplum-db/gpdb/gpcontrib/gpmapreduce# git diff Makefile
# diff --git a/gpcontrib/gpmapreduce/Makefile b/gpcontrib/gpmapreduce/Makefile
# index 44fe882..670a3fb 100644
# --- a/gpcontrib/gpmapreduce/Makefile
# +++ b/gpcontrib/gpmapreduce/Makefile
# @@ -42,7 +42,7 @@ $(MAPREDOBJS): override CPPFLAGS += -DFRONTEND
#  all: submake-libpq gpmapreduce all-lib
#
#  gpmapreduce: $(MAPREDOBJS) $(libpq_builddir)/libpq.a
# -       $(CC) $(CFLAGS) $(MAPREDOBJS) $(libpq_pgport) $(LDFLAGS) $(LIBS) -o $@$(X)
# +       $(CC) $(CFLAGS) $(MAPREDOBJS) $(libpq_pgport) $(LDFLAGS) $(LIBS) -lyaml -o $@$(X)
#
#  $(SRCDIR)/yaml_scan.c: $(SRCDIR)/yaml_parse.h $(SRCDIR)/yaml_scan.l
#  ifdef FLEX
sudo make install
postgres --version
initdb --version
createdb --version
psql --version
gpssh --version
gpmapreduce --version
gpfdist --version


# Use non-root user to run
# Notes: 如果换了用户需要重新安装pip及其相关依赖
# sudo easy_install pip
# pip install --user --upgrade pip
# pip install --user "pyopenssl>=19.0.0"
# pip install --user --pre psutil
# pip install --user lockfile
# export SODIUM_INSTALL=system
# pip install --no-binary :all: pynacl
# pip install --user paramiko
# pip install --user setuptools
# sudo pip2 install psutil   ---  执行下面的命令竟然要python2版本
# export TRAVIS_BUILD_DIR=/opt/bzhao_test/greenplum-db/gpdb
# export PATH=$PATH:$TRAVIS_BUILD_DIR/gpsql/bin
# netstat -nltp | grep 7000 跑之前确认7000端口没有进程，有的话就杀掉
# 然后再运行make -s create-demo-cluster的时候，还需要本用户的密码，需要更改
# 上面的解决方法是直接在 本用户的vi ~/.ssh/config 下配置默认私钥，在ssh ubuntu@linaro2时让其自己加载默认路径私钥来避免输入密码
export PATH=$PATH:$TRAVIS_BUILD_DIR/gpsql/bin
source ${TRAVIS_BUILD_DIR}/gpsql/greenplum_path.sh
cd $TRAVIS_BUILD_DIR
sudo apt install less -y
make -s create-demo-cluster

source gpAux/gpdemo/gpdemo-env.sh

# Use default configuration to test
make installcheck-world


# Clean above build
sudo make clean

# Run UT on ubuntu
sudo apt install libreadline-dev libxml2-dev libperl-dev -y
sudo ./configure \
      --prefix=${TRAVIS_BUILD_DIR}/gpsql \
      --enable-cassert \
      --enable-debug \
      --enable-debug-extensions \
      --with-perl \
      --with-python \
      --disable-orca \
      --with-openssl \
      --with-ldap \
      --with-libcurl \
      --with-libxml \
      --enable-mapreduce \
      --enable-orafce

# 自加步骤
sudo make
sudo make -s install

# 删掉sudo vi src/test/unit/mock/backend/libpq/pqexpbuffer_mock.c的110行，要不会导致编译错误
# ../../../../../src/backend/mock.mk:130: warning: overriding recipe for target '../../../../../src/backend/objfiles.txt'
# ../../../../../src/backend/mock.mk:130: warning: ignoring old recipe for target '../../../../../src/backend/objfiles.txt'
# mocking /home/zuul/src/github.com/bzhaoopenstack/gpdb/src/backend/libpq/pqexpbuffer.c
# ../../../../../src/test/unit/mock/backend/libpq/pqexpbuffer_mock.c: In function ‘appendPQExpBufferVA’:
# ../../../../../src/test/unit/mock/backend/libpq/pqexpbuffer_mock.c:110:2: error: aggregate value used where an integer was expected
#   check_expected(args);
#   ^
# <builtin>: recipe for target '../../../../../src/test/unit/mock/backend/libpq/pqexpbuffer_mock.o' failed
# make[4]: *** [../../../../../src/test/unit/mock/backend/libpq/pqexpbuffer_mock.o] Error 1
# ../../../../src/backend/common.mk:52: recipe for target 'unittest-check-local' failed
# make[3]: *** [unittest-check-local] Error 2
# ../../../src/backend/common.mk:49: recipe for target 'unittest-check-dispatcher-recurse' failed
# make[2]: *** [unittest-check-dispatcher-recurse] Error 2
# common.mk:49: recipe for target 'unittest-check-cdb-recurse' failed
# make[1]: *** [unittest-check-cdb-recurse] Error 2
# GNUmakefile:173: recipe for target 'unittest-check' failed
# make: *** [unittest-check] Error 2

sudo make -s unittest-check

# 用非root用户，否则读取不到应有的环境变量GPHOME啥的
make -C gpAux/gpdemo cluster

source gpAux/gpdemo/gpdemo-env.sh
# 下面这句和上面的原因一样，无法获得环境变量，但是又嵌套使用sudo，导致现有代码权限比较混乱
sudo chown -R zuul:zuul ~/src/github.com/bzhaoopenstack/gpdb
make -C src/test/regress installcheck-small