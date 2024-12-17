# Use the latest Ubuntu image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install required packages
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openssh-server \
    nano \
    wget \
    scala \
    git \
    net-tools \
    mysql-server \
    sudo && \
    mkdir /var/run/sshd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# Create a new user called 'hadoop'
RUN useradd -m -s /bin/bash hadoop && \
    echo "hadoop:hadoop" | chpasswd && \
    usermod -aG sudo hadoop

# Generate SSH keys for 'hadoop' user
RUN mkdir -p /home/hadoop/.ssh && \
    ssh-keygen -t rsa -b 4096 -f /home/hadoop/.ssh/id_rsa -N "" && \
    cp /home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/authorized_keys && \
    chmod 700 /home/hadoop/.ssh && \
    chmod 600 /home/hadoop/.ssh/authorized_keys && \
    chown -R hadoop:hadoop /home/hadoop/.ssh

# Configure SSH server
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "StrictModes no" >> /etc/ssh/sshd_config

RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz && \
    tar -xzf hadoop-3.4.1.tar.gz && \
    mv hadoop-3.4.1 /opt/hadoop && \
    rm hadoop-3.4.1.tar.gz
	
RUN wget https://archive.apache.org/dist/hive/hive-4.0.0/apache-hive-4.0.0-bin.tar.gz && \
    tar -xzf apache-hive-4.0.0-bin.tar.gz && \
    mv apache-hive-4.0.0-bin /opt/hive && \
    rm apache-hive-4.0.0-bin.tar.gz
	
RUN wget https://dlcdn.apache.org/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz && \
    tar -xzf spark-3.5.3-bin-hadoop3.tgz && \
    mv spark-3.5.3-bin-hadoop3 /opt/spark && \
    rm spark-3.5.3-bin-hadoop3.tgz

RUN wget https://dlcdn.apache.org/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz && \
    tar -xzf apache-tez-0.10.3-bin.tar.gz && \
    mv apache-tez-0.10.3-bin /opt/tez && \
    rm apache-tez-0.10.3-bin.tar.gz

RUN sudo chown -R hadoop:hadoop /opt/hadoop /opt/hive /opt/spark /opt/tez 

ENV HOSTNAME=hadoop_node

# Expose required ports
EXPOSE 22 9870 9864 8088 10000 7077 4040

# Set the command to run SSH server
CMD ["/usr/sbin/sshd", "-D"]

