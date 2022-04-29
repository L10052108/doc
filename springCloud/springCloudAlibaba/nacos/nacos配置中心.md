资料来源：

[Spring Cloud 系列之 Alibaba Nacos 配置中心](https://mrhelloworld.com/nacos-config/)

[玩转Nacos参数配置！多图勿点](https://www.toutiao.com/article/7064151088441655847/?log_from=e8ba6d1ccdba8_1646702002454)



### 命名空间

在 Nacos 中通过命名空间（Namespace）+ 分组（Group）+服务名（Name）可以定位到一个唯一的服务实例。

![](large/e6c9d24ely1h1qdjp8yd6j20zn0hs3yw.jpg ':size=60%')

**命名空间（Namespace）：Nacos 服务中最顶层、也是包含范围最广的概念，用于强制隔离类似环境或租户等场景。Nacos 的服务也需要使用命名空间来进行隔离。**

命名空间在 Nacos 控制台的一级目录里可以找到，如下图所示：

![](large/e6c9d24ely1h1qdgvc6yxj22rk0ps77g.jpg ':size=75%')

命名空间默认为 public，在项目开发中，如果不指定命名空间，那么会使用默认值 public。**官方推荐使用运行环境来定义命名空间**，如生产版本可使用 public，开发版可定义为 private。

### 分组名

**分组名（Group）：Nacos 中次于命名空间的⼀种隔离概念，区别于命名空间的强制隔离属性，分组属于⼀个弱隔离概念，主要用于逻辑区分⼀些服务使用场景或不同应用的同名服务，最常用的情况主要是同⼀个服务的测试分组和生产分组、或者将应用名作为分组以防止不同应用提供的服务重名。**

分组名在 Nacos 控制台的服务列表中可以看到，如下图所示：

![](large/e6c9d24ely1h1qdnze9bnj21t20oc419.jpg ':size=60%')

分组名默认为 DEFAULT_GROUP，在项目中可通过“
spring.cloud.nacos.discovery.group”来设置，如下图所示：

![](large/e6c9d24ely1h1qdoe7pczj218h05x3yu.jpg ':size=60%')

此项可省略，省略时的默认值为 DEFAULT_GROUP。

**分组名可以直接在项目中使用**，无需像命名空间那样，在使用前还要在控制台中新建，设定了分组名之后，刷新服务列表就可以看到新的分组名称了，如下图所示：

![](large/e6c9d24ely1h1qdpu7rw8j21sv0nqdij.jpg ':size=60%')

### 服务名

**服务名（Name）：该服务实际的名字，⼀般用于描述该服务提供了某种功能或能力。**

通常推荐使用由运行环境作为命名空间、应用名作为分组，服务功能作为服务名的组合来确保该服务的天然唯⼀性，当然使用者可以忽略命名空间和分组，仅使用服务名作为服务唯⼀标示，这就需要使用者在定义服务名时额外增加自己的规则来确保在使用中能够唯⼀定位到该服务而不会发现到错误的服务上。

服务名在项目中可以通过“spring.application.name”来指定，如下图所示

![](large/e6c9d24ely1h1qdpl8mk3j218d04qq34.jpg ':size=60%')







