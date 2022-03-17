
## 方法一：
### 首先我们需要安装GCC相关的环境：

    yum -y install gcc
    
    yum -y install gcc-c++

### 安装Docker需要的依赖软件包：

    yum install -y yum-utils device-mapper-persistent-data lvm2

### 设置国内的镜像（提高速度）

    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

### 更新yum软件包索引：

    yum makecache fast

### 安装DOCKER CE(注意：Docker分为CE版和EE版，一般我们用CE版就够用了.)

    yum -y install docker-ce

### 启动Docker：

    systemctl start docker

### 查看Docker版本：:

    docker version