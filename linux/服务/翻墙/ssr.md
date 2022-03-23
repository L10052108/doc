。。。。。。。

### ssr 下载

### mac

 客户端下载（文档）  https://ssr.tools/164 

下载地址: https://github.com/qinyuhang/ShadowsocksX-NG-R/releases/download/1.4.4-r8/ShadowsocksX-NG-R8.dmg



### 安卓

https://ssr.tools/97

### windows





https://rovast.github.io/2019/06/11/use-kcp/index.html



## 安装kcp

我们使用一键脚本安装

```
wget https://raw.githubusercontent.com/kuoruan/kcptun_installer/master/kcptun.sh

chmod +x ./kcptun.sh

./kcptun.sh

```

基本上一路回车就好了，最后会输出一个成功的信息，记得保存为单独的文件，后面用到。

```
恭喜! Kcptun 服务端安装成功。
服务器IP:  1.1.1.1
端口:  29900
加速地址:  127.0.0.1:12984
key:  111111
crypt:  aes
mode:  fast
mtu:  1350
sndwnd:  512
rcvwnd:  512
datashard:  10
parityshard:  3
dscp:  0
nocomp:  false
quiet:  false

当前安装的 Kcptun 版本为: 20190515
请自行前往:
  https://github.com/xtaci/kcptun/releases/tag/v20190515
手动下载客户端文件

可使用的客户端配置文件为:
{
  "localaddr": ":12984",
  "remoteaddr": "1.1.1.1:29900",
  "key": "111111",
  "crypt": "aes",
  "mode": "fast",
  "mtu": 1350,
  "sndwnd": 512,
  "rcvwnd": 512,
  "datashard": 10,
  "parityshard": 3,
  "dscp": 0,
  "nocomp": false,
  "quiet": false
}

手机端参数可以使用:
  key=111111;crypt=aes;mode=fast;mtu=1350;sndwnd=512;rcvwnd=512;datashard=10;parityshard=3;dscp=0

Kcptun 安装目录: /usr/local/kcptun

已将 Supervisor 加入开机自启,
Kcptun 服务端会随 Supervisor 的启动而启动

更多使用说明: ./kcptun.sh help

如果这个脚本帮到了你，你可以请作者喝瓶可乐:
  https://blog.kuoruan.com/donate

```

kcp 服务使用 supervisor 来管理，用于守护进程。安装完成后，可用的命令为

- 启动 kcptun `supervisorctl start kcptun`
- 重启 kcptun `supervisorctl restart kcptun`
- 关闭 kcptun `supervisorctl stop kcptun`
- 查看 kcptun 日志 `./kcptun.sh log`

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0jlwu15xfj212z0u0qa2.jpg)

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0jlx612bkj20mi0imq59.jpg)



### Windows 客户端

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0jlxdos5kj21dm0ton7l.jpg)

https://github.com/xtaci/kcptun/releases/download/v20210922/kcptun-linux-386-20210922.tar.gz