# Hadoop 2.7.1 Cluster Docker image
這是一個利用Docker製作的Apache Hadoop 2.7.1部署叢集用的映像檔。
該版本利用 [billy7074396/bimsj-hadoop2.7.1-base](https://github.com/billy7074396/bimsj-hadoop2.7.1-base "billy7074396/bimsj-hadoop2.7.1-base") 當作基底映像檔製作。

此映像檔有著多項好處 : 

__部署快 啟動快 隨時增加節點刪除節點__

*目前該版本為第一版，內容及完整性尚不足夠*

*後續會進行多次更新，敬請等待~*

# 事前準備
在進行建置映像檔之前請先確定主機已有Docker Engine環境。

## 網路通訊部分

在這裡要建立的是Overlay的Network，目的是讓不同Container可以互相溝通。

在這部分有很多種選擇，你可以選擇[consul](https://docs.docker.com/engine/userguide/networking/get-started-overlay/ "consul") , zookeeper , Open vSwitch ...，這部分只是為了能夠讓不同實體機器或Docker Machine的Container能夠互相通訊。

```
docker network create -d overlay multihost-network 
```

__需要更詳細的解說或安裝方式請參考 : 尚未準備完成__

## Docker 私有倉庫 (Private Registry)

建立私有倉庫的主要目的是，此映像檔只需要建置一次即可，切勿在每一台機器上面都建置，這樣會導致每台建置好的映像檔SSH金鑰不同而無法連線。所以選用其中一台機器進行映像檔的建置並上傳到私有倉庫，再從其他機器把映像檔下載下來。

[建置私有昌庫 (Deploying a registry server)](https://docs.docker.com/registry/deploying/ "Deploying a registry server")

# 建立映像檔
如果你想要自行建立的話請到專案資料夾進行Dockerfile的映像檔建立。
```
docker build -t billy7074396/bimsj-hadoop2.7.1-cluster .
```

# 下載映像檔
這個映像檔已經釋出到Docker官方的公開倉庫。
```
docker pull billy7074396/bimsj-hadoop2.7.1-cluster
```

# 測試&部署Hadoop叢集

假設我們現在已經建立好上述所有的步驟及所需的環境。

A host 192.168.1.2

B host 192.168.1.3

C host 192.168.1.4

我們使用A host來當作Hadoop的master節點，Network名稱使用multihost-network，Container的Host名稱必為master，啟動後的參數也必須是master。
```
docker run -p 8088:8088 -p 50070:50070 --net multihost-network --name hadoopmaster -h master -d -it billy7074396/bimsj-hadoop2.7.1-cluster /start.sh master -bash
```
如果Network設定時沒有多加設定，預設的第一個Container IP應為10.0.0.2

接下來使用B host來當作第一個Slave節點，Network名稱使用multihost-network，Container的Host名稱必為slave後面要加編號(例如 : slave1)，啟動後的參數也必須是slave，後面的10.0.0.2為master container的IP，最後面的1為此slave的編號。

__注意 : Slave編號只能往上遞增。__

```
docker run --net multihost-network --name hadoopslave1 -h slave1 -d -it billy7074396/bimsj-hadoop2.7.1-cluster /start.sh slave 10.0.0.2 1 -bash
```
接下來使用C host來當作第二個Slave節點，Network名稱使用multihost-network，Container的Host名稱必為slave後面要加編號(例如 : slave1)，啟動後的參數也必須是slave，後面的10.0.0.2為master container的IP，最後面的2為此slave的編號。
```
docker run --net multihost-network --name hadoopslave1 -h slave2 -d -it billy7074396/bimsj-hadoop2.7.1-cluster /start.sh slave 10.0.0.2 2 -bash
```

需要有更多安裝解說或使用方法請至 : [https://bimsj.serveblog.net/](https://bimsj.serveblog.net/ "BIM My Technology")
