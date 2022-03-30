## 安装过程

### 下载

运行以下命令以下载 Docker Compose 的当前稳定版本：

    sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

将可执行权限应用于二进制文件：

    sudo chmod +x /usr/local/bin/docker-compose

创建软链：

    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

测试是否安装成功：

    docker-compose --version
###  yum 安装



```
　　1、安装python-pip

　　yum -y install epel-release

　　yum -y install python-pip

　　2、安装docker-compose

　　pip install docker-compose

　　待安装完成后，执行查询版本的命令确认安装成功

　　docker-compose version

　　spring.dubbo

　　application.name

　　registry.port
```