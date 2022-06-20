资料来源：

[简单搭建 Zerotier Moon ](https://tvtv.fun/vps/001.html)



## 安装moon

###  在云服务器上安装 zerotier-one

方法一：

~~~~shell
$ curl -s https://install.zerotier.com | sudo bash
~~~~

方法二：**更安全**

> 要求系统中安装了 GPG

~~~~shell
$ curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
~~~~

### 云服务器加入虚拟网络

执行命令，将云服务器加入到自己创建好的虚拟网络，将命令中的 `xxxxxxxx` 替换成实际的虚拟网络 ID。

```shell
$ sudo zerotier-cli join xxxxxxxx
```

#### 

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h3ep50y37ij20ne0gcq3i.jpg)

### 配置 Moon

进入 zerotier-one 程序所在的目录，默认为 `/var/lib/zerotier-one`。

```Shell
$ cd /var/lib/zerotier-one
```

**生成 moon.json 配置文件**

```Shell
$ sudo zerotier-idtool initmoon identity.public >> moon.json
```

**编辑 moon.json 配置文件**

```Shell
$ sudo vim moon.json
```

将配置文件中的 `"stableEndpoints": []` 修改成 `"stableEndpoints": ["ServerIP/9993"]`，将 `ServerIP` 替换成云服务器的公网IP。

**生成 .moon 文件**

```Shell
$ sudo zerotier-idtool genmoon moon.json
```

将生成的 000000xxxxxxxxxx.moon 移动到 `moons.d` 目录

```Shell
$ sudo mkdir moons.d
$ sudo mv 000000xxxxxxxxxx.moon moons.d
```

> .moon 配置文件的名一般为`10个前导零`+`本机的节点ID`

**重启 zerotier-one 服务**

```Shell
$ sudo systemctl restart zerotier-one
```

### 使用 Moon

普通的 Zerotier 成员使用 Moon 有两种方法，第一种方法是使用 `zerotier-cli orbit` 命令直接添加 Moon 节点ID；第二种方法是在 zerotier-one 程序的根目录创建`moons.d`文件夹，将 `xxx.moon` 复制到该文件夹中，我们采用第一种方法：

##### 

>  使用之前步骤中 moon.json 文件中的 id 值 (10 位的字符串，就是xxxxxxxxxx），不知道的话在服务器上执行如下命令可以得到id。
>
>  执行命令：grep id /var/lib/zerotier-one/moon.json | head -n 1

然后在客户端机器里执行命令：

```Shell
zerotier-cli orbit b66b85a05b b66b85a05b
```

此处的b66b85a05b刚刚在服务器得到的ID值









