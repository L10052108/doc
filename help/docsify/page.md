docsify 使用并扩展了Markdown语法，使文档更具可读性。<br>

## markdown
[markdown基本语法](https://www.jianshu.com/p/191d1e21f7ed)<br>
[Markdown 语法整理](https://www.jianshu.com/p/b03a8d7b1719)<br>

### 引用

```
> 引用金句
```

> 引用金句

## 重要内容提示

```
!> **Time** is money, my friend!
```

!> **Time** is money, my friend!

## 一般内容提示

```
?> **Time** is money, my friend!
```

?> **Time** is money, my friend!

## 链接

```
// 一般形式
[link](/demo/)

// 忽略链接，将不再编译该链接
[link](/demo/ ':ignore')
[link](/demo/ ':ignore title')

// 设置链接的目标属性
[link](/demo ':target=_blank')
[link](/demo2 ':target=_self')

// 禁用
[link](/demo ':disabled')

```

## 图片

```
![logo](https://docsify.js.org/_media/icon.svg ':size=50x100')
![logo](https://docsify.js.org/_media/icon.svg ':size=100')
![logo](https://docsify.js.org/_media/icon.svg ':size=10%')

<img align="center" src='https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f87f574e93964921a4d02146bf3ccdac~tplv-k3u1fbpfcp-zoom-1.image' width=300px height=300px />
```

## 下载文件

```
下载window脚本
<a href="computer/file/dingding_ngrok.bat">下载windows脚本</a>
```

## 设置标题ID

```
### 你好，世界！ :id=hello-world
```

## 注释

~~~~
[comment]: <> (This is a comment, it will not be included)
[comment]: <> (in  the output file unless you use it in)
[comment]: <> (a reference style link.)
[//]: <> (This is also a comment.)
[//]: # (This may be the most platform independent comment)
~~~~


## markdown in html

```
<details>
<summary>运动列表 (放开)</summary>

- 篮球
- 足球

</details>

<div style='color: red'>

- 篮球
- 足球

</div>

```

<details>
<summary>运动列表 (放开)</summary>

- 篮球
- 足球

</details>

<div style='color: red'>

- 篮球
- 足球

</div>

**显示红色：**

~~~~shell
<font color='red'> 字体颜色修改为红色 </font>
~~~~
<br/>
<font color='red'> 字体颜色修改为红色 </font>

### 一个 MD 文件中嵌入另外一个文件

可以使用下面的方式进行嵌入。

`[filename](_media/example.md ':include')`

在链接到 md 文件后，在文件的后端添加参数：’:include’ 就可以了。

需要注意的是 :include 需要单引号来进行包裹。[资料来源](https://blog.51cto.com/u_15077561/4192195)

## 复选框

**显示效果：**

- [x] Maven+SpringBoot项目搭建
- [ ] 优化**代码**


**代码**

~~~~
- [x] Maven+SpringBoot项目搭建
- [ ] 优化**代码**
~~~~

## 显示目录

自动生成目录

```
[TOC]
```

![image-20230629102109416](img\image-20230629102109416.png)