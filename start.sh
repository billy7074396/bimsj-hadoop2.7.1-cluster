#!/bin/bash

service ssh start
: ${HADOOP_PREFIX:=/opt/hadoop-2.7.1}
source /etc/profile

if [[ $1 = "master" ]]; then

# altering the core-site configuration
cp /etc/hosts /etc/hosts_temp
sed -i '/172.18.0.2\tmaster/d' /etc/hosts_temp
cp /etc/hosts_temp /etc/hosts
rm /etc/hosts_temp

sed -i 's/localhost/master/' $HADOOP_PREFIX/etc/hadoop/slaves
$HADOOP_PREFIX/bin/hadoop namenode -format
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh

echo "This is your Hadoop master IP "
hostname --ip-address
fi

if [[ $1 = "slave" ]]; then

echo "$2  master master" >> /etc/hosts
# altering the core-site configuration
ssh root@master "echo "$HOSTNAME" >> /opt/hadoop-2.7.1/etc/hadoop/slaves"
IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
ssh root@master "echo "$IP  $HOSTNAME  $HOSTNAME" >> /etc/hosts"
for (( c=1; c<=$3; c++ ))
do
    ssh root@master "scp "$HADOOP_PREFIX"/etc/hadoop/slaves slave"$c":"$HADOOP_PREFIX"/etc/hadoop/slaves"
	ssh root@master "scp /etc/hosts slave"$c":/etc/hosts"
done

$HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start tasktracker
hadoop balancer
$HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager
if [[ $4 == "-bash" ]]; then
  /bin/bash
fi

fi

if [[ $1 = "-d" ]]; then
  while true; do sleep 1000; done
fi
if [[ $2 == "-bash" ]]; then
  /bin/bash
fi

