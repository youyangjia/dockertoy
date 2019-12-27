# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04

# Install Git, which is missing from the Ubuntu base images.
RUN apt-get update && apt-get install -y git

# Add the dependencies from the hbase_docker folder and delete ones we don't need.
WORKDIR /root
ADD . /root
RUN find . -not -name "*tar.gz" -delete

# Install Java.
RUN mkdir -p /usr/java
RUN tar xzf *jdk* --strip-components 1 -C /usr/java
ENV JAVA_HOME /usr/java

# Install Maven.
RUN mkdir -p /usr/local/apache-maven
RUN tar xzf *maven* --strip-components 1 -C /usr/local/apache-maven
ENV MAVEN_HOME /usr/local/apache-maven

# Add Java and Maven to the path.
ENV PATH /usr/java/bin:/usr/local/apache-maven/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Precompile the protobuf 2.5.0
RUN apt-get install curl -y
RUN curl -sL https://github.com/liusheng/package/releases/download/protobuf-aarch64/protobuf-2.5.0.tar.gz | tar zx -C /opt/
RUN echo /opt/protobuf-2.5.0/lib/ > /etc/ld.so.conf.d/protobuf-2.5.0.conf && ldconfig
#ENV LD_LIBRARY_PATH /opt/protobuf-2.5.0/lib/

# Pull down HBase and build it into /root/hbase-bin.
RUN git clone https://gitbox.apache.org/repos/asf/hbase.git -b master
# load the PR
RUN curl -sL https://raw.githubusercontent.com/apache/hbase/3865affd8a80d2dec65bf679c0d915a142a7509b/pom.xml > hbase/pom.xml
RUN mvn clean install -DskipTests assembly:single -f ./hbase/pom.xml
RUN mkdir -p hbase-bin

# This will fail as the *tar.gz used by tar
RUN for i in `ls /root/hbase/hbase-assembly/target/*tar.gz`; do tar xzf $i --strip-components 1 -C /root/hbase-bin; done
# RUN tar xzf /root/hbase/hbase-assembly/target/*tar.gz --strip-components 1 -C /root/hbase-bin

# Set HBASE_HOME, add it to the path, and start HBase.
ENV HBASE_HOME /root/hbase-bin
ENV PATH /root/hbase-bin/bin:/usr/java/bin:/usr/local/apache-maven/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["/bin/bash", "-c", "start-hbase.sh; hbase shell"]

