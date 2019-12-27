FROM ubuntu:bionic

# Install Git, which is missing from the Ubuntu base images.
RUN apt-get update && apt-get install -y git vim curl

RUN apt-get install openjdk-8-jdk -y
#ENV JAVA_HOME `dirname $(dirname $(update-alternatives --list javac |grep java-8))`

RUN curl -sL https://github.com/liusheng/package/releases/download/protobuf-aarch64/protobuf-2.5.0.tar.gz | tar zx -C /opt/
RUN echo /opt/protobuf-2.5.0/lib/ > /etc/ld.so.conf.d/protobuf-2.5.0.conf && ldconfig

RUN useradd -m -d /home/hbase -s /bin/bash hbase && echo hbase:hbase | chpasswd && adduser hbase sudo
RUN echo "hbase ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER hbase
WORKDIR /home/hbase
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-arm64
# Download maven
RUN mkdir -p ./tools/maven \
    && curl -sL https://archive.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz | tar zx --strip-components 1 -C ./tools/maven/
ENV PATH $PATH:/home/hbase/tools/maven/bin

# clone hbase
RUN git clone https://github.com/apache/hbase

# load the PR
RUN curl -sL https://raw.githubusercontent.com/apache/hbase/3865affd8a80d2dec65bf679c0d915a142a7509b/pom.xml > hbase/pom.xml
RUN mkdir -p hbase-results

ARG prebuild=false
RUN if [ "$prebuild" = "true" ]; then cd hbase \
    && git pull \
    && mvn clean install assembly:single -f ./pom.xml -Dhadoop.profile=3.0 -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -Dfindbugs.skip=true -Dspotbugs.skip=true -DskipTests 2>&1 | tee ~/hbase-results/hbase_build.log ; fi

CMD cd hbase \
    && git pull \
    && mvn clean install assembly:single -f ./pom.xml -Dhadoop.profile=3.0 -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -Dfindbugs.skip=true -Dspotbugs.skip=true -DskipTests 2>&1 | tee ~/hbase-results/hbase_build.log \
    && mvn clean test -P runAllTests -Dhadoop.profile=3.0 -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -Dfindbugs.skip=true -Dspotbugs.skip=true -Dtest.exclude.pattern=**/security.access.TestSnapshotScannerHDFSAclController.java -fn | tee ~/hbase-results/hbase_all_test.log
