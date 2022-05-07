资料来源：
[注册中心](https://mrhelloworld.com/dubbo/#multicast-%E6%B3%A8%E5%86%8C%E4%B8%AD%E5%BF%83)

### Dubbo控制台介绍
Dubbo 2.6 版本以及以前我们是通过一个war包，将其部署在tomcat下，启动服务器访问war包项目即可，界面效果如下。

![](large/e6c9d24ely1h1zu6yvzq4j212f0dnjt7.jpg ':size=60%')

　　Dubbo 2.7 版本以后管理控制台结构上采取了前后端分离的方式，前端使用 Vue 和 Vuetify 分别作为 Javascript 框架和 UI 框架，后端采用 Spring Boot 框架。既可以按照标准的 Maven 方式进行打包，部署，也可以采用前后端分离的部署方式，方便开发，功能上，目前具备了服务查询，服务治理（包括Dubbo2.7中新增的治理规则）以及服务测试三部分内容，最终效果如下：

![568723655695.png](large/1568723655695.png ':size=60%')

### Maven方式部署

　　使用 git 将项目克隆至本地，打包启动访问或者导入 IDE 启动访问

~~~~bash
git clone https://github.com/apache/dubbo-admin.git
cd dubbo-admin
mvn clean package -Dmaven.test.skip=true
cd dubbo-admin-distribution/target
java -jar dubbo-admin-0.2.0-SNAPSHOT.jar
~~~~

> 配置maven过程略,springboot打包编译过程

项目访问地址：http://localhost:8080

### 前端

前端使用vue需要配置[Vue的环境](http://nodejs.cn/)

[安装过程](computer/mac/01mac安装软件.md)参考

~~~~shell
cd dubbo-admin-ui
npm install
npm run dev
~~~~

前端编译出现了问题，以后再搞吧