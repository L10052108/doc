## 安装jdk

如果你是第一次配置环境变量，可以使用`touch.bash_profile` 创建一个`.bash_profile`的隐藏配置文件(如果你是为编辑已存在的配置文件，则使用`open -e .bash_profile`命令)：

输入`open -e.bash_profile`命令：

~~~~shell
JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_40.jdk/Contents/Home
PATH=$JAVA_HOME/bin:$PATH:.
CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.
export JAVA_HOME
export PATH
export CLASSPATH
~~~~

!>  根据自己的情况，修改配置JAVA_HOME的文件路径，一般只要修改版本号

## 安装maven

maven配置文件

~~~~Shell
export MAVEN_HOME=/Users/liuwei/Documents/java/apache-maven-3.8.4
export PATH=$PATH:$MAVEN_HOME/bin
~~~~

