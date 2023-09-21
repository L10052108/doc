资料来源：<br/>
[Docker安装RabbitMQ docker安装RabbitMQ完整详细教程](https://blog.csdn.net/qq_40739917/article/details/131509696)



### 拉取 RabbitMQ 镜像
我这边选择的版本是 `rabbitmq:3.12-management`在终端中执行以下命令以拉取 `rabbitmq:3.12-management`根据自己使用过的版本：
镜像尽量选择 带`-management`后缀的，因为这个是自带Web监控页面，同3.12版本MQ有两个
`docker pull rabbitmq:3.12-management`
`docker pull rabbitmq:3.12` 这个是不带Web管理页面的，是需要自己手动安装插件

```shell
docker pull rabbitmq:3.12-management
```

2、创建并运行容器
使用以下命令创建一个新的 rabbitmq容器并将其启动：

```shell
docker run --name some-rabbitmq -p 5672:5672 -p 15672:15672 -d rabbitmq:3.12-management
```


--name 是 容器别名，将 宿主机 5672端口映射到 容器内5672，and 端口15672端口映射到 容器内15672 端口，访问宿主机端口的时候会映射到对应容器端口, -d 表示后台运行。

3、RabbitMQ 常用端口以及作用

- 5672端口：AMQP（Advanced Message Queuing Protocol）协议的默认端口，用于客户端与RabbitMQ服务器之间的通信。

- 15672端口：RabbitMQ的管理界面，默认使用HTTP协议，用于监控和管理RabbitMQ服务器。

- 4369端口：Erlang分布式节点通信端口，用于RabbitMQ节点之间的通信。

- 25672端口：Erlang分布式节点通信端口，用于集群中的内部通信。

- 5671端口：安全的AMQP端口，使用TLS/SSL进行加密通信。

4、访问 管理页面测试，是否启动成功

![image-20230921192735901](img/image-20230921192735901.png)



访问 `localhost:15672` 管理页面是否正常

```url
http://localhost:15672/
```

RabbitMQ默认的登录账号和密码如下：

- 用户名：**guest**
- 密码： **guest**