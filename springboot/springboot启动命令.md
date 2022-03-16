## springboot启动

资料来源：[【SpringBoot】在 linux 下利用 nohup 后台运行 jar 包](https://blog.csdn.net/AV_woaijava/article/details/96278287?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_title~default-4.pc_relevant_paycolumn_v3&spm=1001.2101.3001.4242.3&utm_relevant_index=7)

### 方式一

`java -jar XXX.jar`

特点：当前[ssh](https://so.csdn.net/so/search?q=ssh&spm=1001.2101.3001.7020)窗口被锁定，可按CTRL + C打断程序运行，或直接关闭窗口，程序退出

### 方式二

`java -jar XXX.jar & `

`&`代表在后台运行。

特定：当前ssh窗口不被锁定，但是当窗口关闭时，程序中止运行。

### 方式三

方式三
`nohup java -jar XXX.jar & `
nohup:意思是不挂断运行命令,当账户退出或终端关闭时,程序仍然运行

当用 nohup 命令执行作业时，缺省情况下该作业的所有输出被重定向到nohup.out的文件中，除非另外指定了输出文件。

### 方式四
`nohup java -jar XXX.jar >temp.txt &`

> 日志输入出到temp.txt

### 方式五

`nohup java -jar xxx.jar >/dev/null &`

如果不需要输出日志

### 方式六

`nohup java -jar xxx.jar >/dev/null 2>&1 &`

shell上:
0表示标准输入
1表示标准输出
2表示标准错误输出

\> 默认为标准输出重定向，与 1> 相同
2>&1 意思是把 标准错误输出 重定向到 标准输出.
&>file 意思是把 标准输出 和 标准错误输出 都重定向到文件file中