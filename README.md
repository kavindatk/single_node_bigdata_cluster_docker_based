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

Docker Build Image :

```docker
docker build -t <image name> .
```

Docker Login to image (Create containner and launch configurations):

```docker
docker run -it --name <custom-container-name> -p host_port:container_port <image name>
```

## System/OS Configurations

In this step, after logging into the container, I use SSH to log in to localhost as the hadoop user. This is because Hadoop recommends accessing the system via SSH for proper functionality.Then i add system variables for Hadoop and Java for proceed the installation 

#### Login

```ssh
su - hadoop
ssh localhost
```

#### Adding System variables 

```ssh
nano ~/.bashrc

#Hadoop Related Options
export HADOOP_HOME=/opt/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$JAVA_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"


source ~/.bashrc

```

## MYSQL Configurations

In this step, I first start the MySQL service and then create the necessary users and configurations required for the Hadoop Metastore.

#### Start MySQL service

```ssh
sudo service mysql start

ls -l /var/run/mysqld/
sudo chown -R mysql:mysql /var/run/mysqld/
sudo chmod 755 /var/run/m

```

#### MySQL configurations

```mysql
sudo mysql_secure_installation

sudo mysql -u root -p
UNINSTALL COMPONENT 'file://component_validate_password';

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;
EXIT;
```

```mysql
mysql -u root -p (verify)

CREATE DATABASE metastore;
CREATE USER 'hive'@'localhost' IDENTIFIED WITH mysql_native_password BY 'hive';
ALTER USER 'hive'@'localhost' IDENTIFIED WITH mysql_native_password BY 'hive';
GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'localhost';
FLUSH PRIVILEGES;
EXIT;

```


## HADOOP Configurations

#### Create necessary folders

```bash
cd /opt/hadoop/
mkdir data
cd data
mkdir -p {datanode,namenode}
```

#### Hadoop Configurations (hadoop-env.sh)

```bash
cd /opt/hadoop/etc/hadoop/

nano $HADOOP_HOME/etc/hadoop/hadoop-env.sh 
```

Then add/modify following 

```xml
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```


#### Hadoop Configurations (core-site.xml)

```bash
nano $HADOOP_HOME/etc/hadoop/core-site.xml
```

Then add/modify following 

```xml
<property>
  <name>fs.default.name</name>
  <value>hdfs://localhost:9000</value>
</property>
```


#### Hadoop Configurations (hdfs-site.xml)

```bash
nano $HADOOP_HOME/etc/hadoop/hdfs-site.xml
```

Then add/modify following 

```xml
<property>
  <name>dfs.name.dir</name>
  <value>/opt/hadoop/data/namenode</value>
</property>
<property>
  <name>dfs.data.dir</name>
  <value>/opt/hadoop/data/datanode</value>
</property>
<property>
  <name>dfs.replication</name>
  <value>1</value>
</property>
```

#### Hadoop Configurations (mapred-site.xml)

```bash
nano $HADOOP_HOME/etc/hadoop/mapred-site.xml
```

Then add/modify following 

```xml
<property> 
  <name>mapreduce.framework.name</name> 
  <value>yarn</value> 
</property> 
```

#### Hadoop Configurations (yarn-site.xml)

```bash
nano $HADOOP_HOME/etc/hadoop/yarn-site.xml
```

Then add/modify following 

```xml
<property>
  <name>yarn.nodemanager.aux-services</name>
  <value>mapreduce_shuffle</value>
</property>
<property>
  <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
  <value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>
<property>
  <name>yarn.resourcemanager.hostname</name>
  <value>127.0.0.1</value>
</property>
<property>
  <name>yarn.acl.enable</name>
  <value>0</value>
</property>
<property>
  <name>yarn.nodemanager.env-whitelist</name>   
  <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PERPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
</property 
```

#### Hadoop Service starting and testing

```hadoop
hdfs namenode -format
```

```hadoop
start-dfs.sh
start-yarn.sh
```

```hadoop
#Check Service is Up and Running
netstat -tuln | grep 9870

#Testing hadoop
cd $HADOOP_HOME/share/hadoop/mapreduce/

yarn jar hadoop-mapreduce-examples-3.4.1.jar pi 10 100
```


## HIVE Configurations

#### Adding System variables 

```ssh
nano ~/.bashrc 

#Hive Related Options
export HIVE_HOME=/opt/hive
export HIVE_CONF=$HIVE_HOME/conf
export PATH=$PATH:$HIVE_HOME/bin
export CLASSPATH=$CLASSPATH:$HADOOP_HOME/lib/*:.
export CLASSPATH=$CLASSPATH:$HIVE_HOME/lib/*:.


source ~/.bashrc 
```

#### Hive Configurations (hive-site.xml)

```bash
cd $HIVE_HOME/conf/

cp hive-default.xml.template hive-site.xml

nano hive-site.xml
```

Then add/modify following 

```xml
  <property>
    <name>system:java.io.tmpdir</name>
    <value>/tmp/hive/java</value>
  </property>
  <property>
    <name>system:user.name</name>
    <value>${user.name}</value>
  </property>
```

🔴 🔴 🔴 Goto line 3224 and remove non-unicode character , this cause the unicode error 🔴 🔴 🔴 


## TEZ Configurations

#### Adding System variables 

```ssh
nano ~/.bashrc

#Hadoop Related Options
export HADOOP_HOME=/opt/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$JAVA_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"


source ~/.bashrc

```

## SPARK Configurations

#### Adding System variables 

```ssh
nano ~/.bashrc

#Hadoop Related Options
export HADOOP_HOME=/opt/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$JAVA_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"


source ~/.bashrc

```








