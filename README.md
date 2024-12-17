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

#### Create required HDFS folders and set permission

```hdfs
hdfs dfs -ls /
hdfs dfs -rm -r /user
hdfs dfs -ls /
hdfs dfs -mkdir -p /user/hive/warehouse

hdfs dfs -chmod g+w /user
hdfs dfs -chmod g+wx /user

hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+wx /tmp
```
#### Hive Configurations (hive-env.sh)

```bash
cp hive-env.sh.template hive-env.sh

nano hive-env.sh
```

Then add/modify following 

```xml
HADOOP_HOME=/opt/hadoop
```
#### Remove conflicting libraries 

```bash
cd $HIVE_HOME/lib/

rm -rf rm -rf guava-22.0.jar 

cp $HADOOP_HOME/share/hadoop/common/lib/guava-27.0-jre.jar $HIVE_HOME/lib/
```

#### Hive verification - Using Apache Derby Metastore

```bash
cd $HIVE_HOME/scripts/metastore/upgrade/derby/

nano hive-schema-3.1.0.derby.sql 
```

Then add/modify following (Comment)

```sql
--CREATE FUNCTION "APP"."NUCLEUS_ASCII" (C CHAR(1)) RETURNS INTEGER LANGUAGE JAVA PARAMETER STYLE JAVA READS SQL DATA CALLED ON NULL INPUT EXTERNAL NAME 'org.datan>

--CREATE FUNCTION "APP"."NUCLEUS_MATCHES" (TEXT VARCHAR(8000),PATTERN VARCHAR(8000)) RETURNS INTEGER LANGUAGE JAVA PARAMETER STYLE JAVA READS SQL DATA CALLED ON NU>

```

```bash
#Hive build Derby metastore
cd $HIVE_HOME/bin
schematool -dbType derby -initSchema
```

#### Hive Testing

```hive
#Check Hive
hive
#or
beeline -u "jdbc:hive2://"

#create random data and uploaded to HDFS for Hive data loading
cd /home/hadoop
seq 1 10000000 > numbers.txt
hdfs dfs -mkdir /user/hive/warehouse/sample/
hdfs dfs -put numbers.txt /user/hive/warehouse/sample/

#create table and load HDFS data
beeline -u "jdbc:hive2://"

create database sample_data;
use sample_data;

CREATE  TABLE sample_data.number_data (
val_col bigint
)row format delimited fields terminated by ',' 
location '/user/hive/warehouse/sample/';


#testing status
select sum(val_col) from sample_data.number_data;
```

Fixing slf4j Log binding warnings 

```bash
#Fix slf4j Log binding
find /opt/hadoop /opt/tez -name "slf4j-reload4j-*.jar"
rm /opt/tez/lib/slf4j-reload4j-1.7.36.jar
rm -rf /opt/hive/lib/log4j-slf4j-impl-2.18.0.jar
sudo ln -s /opt/hadoop/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar /opt/tez/lib/slf4j-reload4j-1.7.36.jar
sudo ln -s /opt/hadoop/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar /opt/hive/lib/slf4j-reload4j-1.7.36.jar

```


## TEZ Configurations

#### Adding System variables 

```ssh
nano ~/.bashrc 


#Tez Related Options
export TEZ_HOME=/opt/tez
export TEZ_CONF_DIR=$TEZ_HOME/conf

export TEZ_JARS=$TEZ_HOME
# For enabling hive to use the Tez engine
if [ -z "$HIVE_AUX_JARS_PATH" ]; then
export HIVE_AUX_JARS_PATH="$TEZ_JARS"
else
export HIVE_AUX_JARS_PATH="$HIVE_AUX_JARS_PATH:$TEZ_JARS"
fi


export HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*

source ~/.bashrc

```

#### Create required HDFS folders and upload TEZ

```bash
hdfs dfs -mkdir /apps
hdfs dfs -mkdir /apps/tez
hdfs dfs -chmod g+w /apps
hdfs dfs -chmod g+wx /apps

cp $HIVE_HOME/lib/protobuf-java-3.24.4.jar $TEZ_HOME/lib/
hdfs dfs -put $HIVE_HOME/lib/hive-exec-4.0.0.jar /apps/tez
cd $TEZ_HOME 
hdfs dfs -put * /apps/tez
```

#### TEZ Configurations (tez-site.xml)

```bash
cd $TEZ_HOME/conf/

nano tez-site.xml 
```

Then add/modify following 

```xml
<?xml version="1.0"?>
<configuration>

  <property>
    <name>tez.lib.uris</name>
    <value>${fs.default.name}/apps/tez/share/tez.tar.gz</value>
  </property>

</configuration>
```

#### Hive Configurations - Change execution engine (hive-site.xml)

```bash
nano $HIVE_HOME/conf/hive-site.xml 
```

Then add/modify following 

```xml
  <property>
    <name>hive.execution.engine</name>
    <value>tez</value>
    <description>
      Expects one of [mr, tez, spark].
      Chooses execution engine. Options are: mr (Map reduce, default), tez, spark. While>
      remains the default engine for historical reasons, it is itself a historical engine
      and is deprecated in Hive 2 line. It may be removed without further warning.
    </description>
  </property>

```

## Change Apache Derby Metastore to MySQL Metastore

```bash
#Remove existing metastore 
cd $HIVE_HOME/bin
rm -rf  metastore_db
```

```bash
# Download MYSQL JDBC Connectorand move to Hive Libs
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.30.tar.gz 
tar -xzvf mysql-connector-java-8.0.30.tar.gz

sudo cp mysql-connector-java-8.0.30.jar $HIVE_HOME/lib/
```

#### Hive Configurations - Change metastore (hive-site.xml)

```bash
nano $HIVE_HOME/conf/hive-site.xml 
```

Then add/modify following 

```xml
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://localhost:3306/metastore?useSSL=false</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.cj.jdbc.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>hive</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>your_strong_password</value>
    </property>
    
    <!-- Metastore Configuration -->
    <property>
        <name>hive.metastore.db.type</name>
        <value>mysql</value>
    </property>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>
```

```bash
# Regenrate Metastore

cd $HIVE_HOME/bin

schematool -initSchema -dbType mysql

```

```sql
# Verification

hadoop@7454095b6ca0:~$ beeline -u "jdbc:hive2://"
Connecting to jdbc:hive2://
Hive Session ID = 7c61ca30-bb38-456d-b8b9-aeefc78e837d
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.apache.hadoop.hive.common.StringInternUtils (file:/opt/hive/lib/hive-common-4.0.0.jar) to field java.net.URI.string
WARNING: Please consider reporting this to the maintainers of org.apache.hadoop.hive.common.StringInternUtils
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
Connected to: Apache Hive (version 4.0.0)
Driver: Hive JDBC (version 4.0.0)
Transaction isolation: TRANSACTION_REPEATABLE_READ
Beeline version 4.0.0 by Apache Hive
0: jdbc:hive2://> 
0: jdbc:hive2://> 
0: jdbc:hive2://> set hive.execution.engine;
+----------------------------+
|            set             |
+----------------------------+
| hive.execution.engine=tez  |
+----------------------------+
1 row selected (0.026 seconds)
0: jdbc:hive2://> 
0: jdbc:hive2://> 
```


## SPARK Configurations

#### Adding System variables 

```ssh
nano ~/.bashrc 

#Spark Related Options
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=/usr/bin/python3
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH

source ~/.bashrc 

```

```bash
#Set Log4j properties
nano $SPARK_HOME/conf/log4j2.properties
logger.HiveConf.name=org.apache.hadoop.hive.conf.HiveConf
logger.HiveConf.level=ERROR

#Coping MySQL connector
sudo cp /home/hadoop/mysql-connector-java-8.0.30.jar $SPARK_HOME/jars/
```

```bash
#Testing
start-master.sh
start-worker.sh spark://localhost:7077

netstat -tuln | grep 7077
netstat -tuln | grep 8080
```



