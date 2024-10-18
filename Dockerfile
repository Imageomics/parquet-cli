# Stage 1: Build Stage
FROM ubuntu:22.04 AS builder

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    MAVEN_HOME=/opt/maven

# Install build dependencies with --no-install-recommends
RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-11-jdk \
        maven \
        git \
        build-essential \
        autoconf \
        libtool \
        bison \
        flex \
        libboost-all-dev \
        libevent-dev \
        libssl-dev \
        wget \
        tar \
    && rm -rf /var/lib/apt/lists/*

# Add Maven to PATH
ENV PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

# Install Thrift
RUN wget http://archive.apache.org/dist/thrift/0.20.0/thrift-0.20.0.tar.gz && \
    tar xzf thrift-0.20.0.tar.gz && \
    cd thrift-0.20.0 && \
    ./configure --without-python --without-cpp --without-c_glib --without-java \
                --without-erlang --without-nodejs --without-nodets --without-lua \
                --without-perl --without-php --without-php_extension --without-dart \
                --without-ruby --without-haskell --without-go --without-swift \
                --without-rs --without-cl --without-haxe --without-dotnetcore \
                --without-d --without-python_axiom --without-rust --without-flask \
                --without-netstd && \
    make && make install && \
    cd / && \
    rm -rf thrift-0.20.0 thrift-0.20.0.tar.gz

# Install Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz && \
    tar -xzf hadoop-3.4.0.tar.gz -C /opt/ && \
    mv /opt/hadoop-3.4.0 /opt/hadoop && \
    rm hadoop-3.4.0.tar.gz

ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin

# Clone and build parquet-java
RUN git clone https://github.com/apache/parquet-java.git /parquet-java && \
    cd /parquet-java && \
    ./mvnw clean install -DskipTests && \
    find /parquet-java/parquet-cli/target -name 'parquet-cli-*-runtime.jar' -exec cp {} /opt/parquet-cli.jar \; && \
    rm -rf /parquet-java

# Stage 2: Runtime Stage
FROM ubuntu:22.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    HADOOP_HOME=/opt/hadoop \
    PATH=/usr/lib/jvm/java-11-openjdk-amd64/bin:/opt/hadoop/bin:$PATH \
    APPTAINER_MAX_BIND_MOUNTS=512

# Install runtime dependencies with --no-install-recommends
RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-11-jre \
        libboost-all-dev \
        libevent-2.1-7 \
        libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

# Copy Hadoop from builder
COPY --from=builder /opt/hadoop /opt/hadoop

# Copy parquet-cli.jar from builder
COPY --from=builder /opt/parquet-cli.jar /opt/parquet-cli.jar

# Set CLASSPATH
ENV CLASSPATH=$(find /opt/hadoop -name '*.jar' -print | tr '\n' ':')

# Define entrypoint and default command
ENTRYPOINT ["java", "-cp", "/opt/parquet-cli.jar:$CLASSPATH", "org.apache.parquet.cli.Main"]
CMD ["--help"]

