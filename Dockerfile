# Creates distributed hadoop 2.7.1
#
# docker build -t bimsj-hadoop2.7.1-cluster .

# Pull base image.
FROM bimsj-hadoop2.7.1-base
MAINTAINER bimsj

USER root

ENV HADOOP_PREFIX /opt/hadoop-2.7.1

# configuration Hadoop
ADD core-site.xml /opt/hadoop-2.7.1/etc/hadoop/core-site.xml
ADD hdfs-site.xml /opt/hadoop-2.7.1/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml /opt/hadoop-2.7.1/etc/hadoop/mapred-site.xml
ADD yarn-site.xml /opt/hadoop-2.7.1/etc/hadoop/yarn-site.xml
ADD hadoop-env.sh /opt/hadoop-2.7.1/etc/hadoop/hadoop-env.sh

# SSH configuration
ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

RUN echo 'root:bimhadoop' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

# workingaround docker.io build error
RUN ls -la /opt/hadoop-2.7.1/etc/hadoop/*-env.sh
RUN chmod +x /opt/hadoop-2.7.1/etc/hadoop/*-env.sh
RUN ls -la /opt/hadoop-2.7.1/etc/hadoop/*-env.sh

# change owner
RUN chown -R root:root /opt
RUN chmod -R +x $HADOOP_PREFIX/*

# start
ADD start.sh /start.sh
RUN chown root:root /start.sh
RUN chmod 700 /start.sh

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122 22 4789 7946

CMD ["/start.sh", "-d"]

#docker run -p 8088:8088 --net multihost-network --name hadoopmaster -h master -d -it bimsj-hadoop2.7.1-cluster /start.sh master -bash
#docker exec -ti hadoopmaster bash
#yarn node -list  
#docker run --net multihost-network --name hadoopslave -h slave1 -it bimsj-hadoop2.7.1-cluster /start.sh slave 10.0.0.2
