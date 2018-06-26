#!/bin/bash

###Variables
	HOSTNAME_FILE='/etc/hostname'
	HOST_NETWORK='/etc/sysconfig/network'
	HOST_FILE='/etc/hosts'
	HDFS_SITE='/etc/hadoop/conf.empty/hdfs-site.xml'
	CORE_SITE='/etc/hadoop/conf.empty/core-site.xml'
	YARN_SITE='/etc/hadoop/conf.empty/yarn-site.xml'
	SPARK_ENV='/etc/spark/conf.dist/spark-env.sh'
	SPARK_CONF='/etc/spark/conf.dist/spark-defaults.conf'

###Remove the extra characters inside the 'root' user ".ssh/authorized_keys" to allow private key login with 'root'
echo -e "Clearing the commands found in .ssh/authorized_keys to enable root login"
	sed -i 's/^.*ssh-rsa/ssh-rsa/' /root/.ssh/authorized_keys

useradd bigdata
touch /etc/sudoers.d/bigdata
echo -e '%bigdata        ALL=(ALL)       NOPASSWD: ALL' > /etc/sudoers.d/bigdata
mkdir -p /bigdata
chown -R root:bigdata /bigdata
chmod -R 775 /bigdata
yum -y remove java-1.7.*
yum -y install java-1.8.0-openjdk

###Changing hostname in /etc/hostname
	IPADDR=$(ip addr | grep "inet" | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | cut -c -13)
	read -p "Please specify a hostname for this host: " HOSTNAME
	echo "$HOSTNAME" > $HOSTNAME_FILE
	echo -e "Hostname changed to: `cat $HOSTNAME_FILE`"

###Adding IP and Hostname to the /etc/hosts. Delete anything after the 2nd line inside /etc/hosts
	sed -i 3,50d $HOST_FILE
	echo -e "\n$IPADDR	$HOSTNAME" >> $HOST_FILE
	sed -i "/$HOSTNAME/{s|/||}" $HOST_FILE

###Changing hostname in /etc/sysconfig/network
sed -i 2d $HOST_NETWORK
echo -e "HOSTNAME=$HOSTNAME" >> $HOST_NETWORK

###Changing the hdfs-site.xml,spark-defaults.conf,spark-env.sh,yarn-site.xml,core-site.xml
	read -p "Please specify the master hostname: " MASTER_HOSTNAME
	read -p "Please specify the default amazon hostname of the master node: (e.g ip-172-19-0-0.domain.local): " AWS_HOSTNAME
	sed -i "/${AWS_HOSTNAME}/{s|${AWS_HOSTNAME}|${MASTER_HOSTNAME}|}" $HDFS_SITE
	sed -i "/${AWS_HOSTNAME}/{s|${AWS_HOSTNAME}|${MASTER_HOSTNAME}|}" $CORE_SITE
	sed -i "/${AWS_HOSTNAME}/{s|${AWS_HOSTNAME}|${MASTER_HOSTNAME}|}" $YARN_SITE
	sed -i "/${AWS_HOSTNAME}/{s|${AWS_HOSTNAME}|${MASTER_HOSTNAME}|}" $SPARK_ENV
	sed -i "/${AWS_HOSTNAME}/{s|${AWS_HOSTNAME}|${MASTER_HOSTNAME}|}" $SPARK_CONF
