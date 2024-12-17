# Containerized Bigdata Cluster (Hadoop/Hive/TEZ & SPARK)
<p align="center">
<picture>
  <img alt="docker" src="https://github.com/kavindatk/single_node_bigdata_cluster_docker_based/blob/main/images/docker.png" width="200" height="125">
</picture>
</p>

<picture>
  <img alt="hadoop" src="https://github.com/kavindatk/single_node_bigdata_cluster_docker_based/blob/main/images/hadoop.JPG" width="200" height="125">
</picture>

<picture>
  <img alt="hive" src="https://github.com/kavindatk/single_node_bigdata_cluster_docker_based/blob/main/images/hive.JPG" width="200" height="125">
</picture>

<picture>
  <img alt="tez" src="https://github.com/kavindatk/single_node_bigdata_cluster_docker_based/blob/main/images/tez.jpg" width="200" height="125">
</picture>

<picture>
  <img alt="spark" src="https://github.com/kavindatk/single_node_bigdata_cluster_docker_based/blob/main/images/spark.JPG" width="200" height="125">
</picture>

## Introduction 

In this article, I will show you how to set up a Big Data cluster using Docker. This setup includes Hadoop, Hive with the TEZ engine, and Spark. It is a single-node setup, useful for Big Data developers to practice and learn these tools.
I have used the latest versions of each tool and kept the setup small and simple.
If you don’t want to create your own Dockerfile or deal with configurations, you can use a pre-made image from Docker Hub. Here’s the link:

[Docker Hub Link](https://hub.docker.com/repository/docker/kavindat/hadoop_hive_tez_spark/general)

This guide is great for anyone who wants to start learning Big Data tools quickly and easily.


## DockerFile 

To build the Big Data Docker image, I used the latest Ubuntu stock image and installed the necessary plugins, including:

1. SSH
2. OpenJDK
3. Editor
4. Some additional tools (Netowrk tools, MySQL..etc)
    
Here are the steps I followed:

<b>Install Dependencies:</b> Installed the required plugins and tools.


```docker
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
```



<b>Download Big Data Software:</b> Downloaded the relevant Big Data software, unzipped them, and moved them to /opt/.

```docker
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
```


<b>Expose Ports and Configure SSH:</b> Exposed the required ports, created an SSH user, and generated a passwordless token as required by Hadoop.

```docker
# Expose required ports
EXPOSE 22 9870 9864 8088 10000 7077 4040
```

```docker
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


# Set the command to run SSH server
CMD ["/usr/sbin/sshd", "-D"]
```

<b>Build the Image:</b> Built the Docker image.

<b>Configure Tools:</b> Logged into the system and configured Hadoop, Hive, TEZ, and Spark.

<b>Setup Hive Metastore:</b> Used MySQL as the Hive Metastore database.


Versions Used:

    Hadoop: 3.4.1
    Hive: 4.0.0
    TEZ: 0.10.3
    Spark: 3.5.3


[Docke File Link](https://github.com/kavindatk/single_node_bigdata_cluster_docker_based/blob/main/Dockerfile)


## Docker Build and Configure Node

