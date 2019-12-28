FROM ubuntu:bionic

# Install Git, which is missing from the Ubuntu base images.
RUN apt-get update && apt-get install -y git vim curl

RUN apt-get install openjdk-8-jdk -y
#ENV JAVA_HOME `dirname $(dirname $(update-alternatives --list javac |grep java-8))`


RUN useradd -m -d /home/spark -s /bin/bash spark && echo spark:spark | chpasswd && adduser spark sudo
RUN echo "spark ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER spark
WORKDIR /home/spark
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-arm64
# Download maven
#RUN mkdir -p ./tools/maven \
#    && curl -sL https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz | tar zx --strip-components 1 -C ./tools/maven/
#ENV PATH $PATH:/home/spark/tools/maven/bin

# clone hbase
RUN git clone https://github.com/apache/spark

# install spark
RUN cd spark \
    && ./build/mvn clean install -DskipTests -Paarch64 -Phadoop-2.7 -Pyarn -Phive -Phive-1.2 -Phive-thriftserver -Pkinesis-asl -Pmesos

# generate release package
RUN cd spark \
    && ./dev/make-distribution.sh --tgz -Paarch64 -Phadoop-2.7 -Pyarn -Phive -Phive-1.2 -Phive-thriftserver -Pkinesis-asl -Pmesos
