
###上传安装包

已经上传到百度网盘中

>  链接: https://pan.baidu.com/s/1ZDiVfGy7-5bF6BBoyBlWTQ?pwd=5kc4 提取码: 5kc4

###执行安装

创建文件夹

`mkdir -p /usr/java`

- 解压

~~~~~
tar -zxvf jdk-8u91-linux-x64.tar.gz -C /usr/java
~~~~~

配置环境变量

`vim /etc/profile`

输入i进行编辑，编辑完成后输入wq保存

文件中增加jdk配置

~~~~~
export JAVA_HOME=/usr/java/jdk1.8.0_91
export CLASSPATH=$JAVA_HOME/lib/
export PATH=$PATH:$JAVA_HOME/bin
export PATH JAVA_HOME CLASSPATH
~~~~~

生效

`source /etc/profile`

### 验证

测试命令

`java -version`

运行效果

![Snipaste_2022-03-15_16-04-11](pic/Snipaste_2022-03-15_16-04-11.png)















