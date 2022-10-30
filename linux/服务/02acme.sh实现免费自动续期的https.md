资料来源：<br/>
[acme.sh实现免费自动续期的https](https://blog.csdn.net/qq_37816503/article/details/105102575)

acme.sh能做什么？
acme.sh 实现了 acme 协议, 可以从 let‘s encrypt（数字证书认证机构）生成免费的证书。并且可以自动化完成创建证书、安装证书、更新证书的流程。

### 安装acme.sh
~~~~~shell
curl https://get.acme.sh | sh
~~~~~

创建一个bash的别名, 方便使用:
~~~~~shell
alias acme.sh=~/.acme.sh/acme.sh
~~~~~
### 生成证书

生成证书需要验证你的域名所有权。acme.sh 实现了 acme 协议支持的所有验证协议，一般有 http 和 dns 两种验证方式。
这里介绍几种常用的验证方式。

##### Webroot mode:
如果已经运行了web服务器，可以指定网站的根目录使用 Webroot 模式生成证书。acme.sh 会自动的生成验证文件, 并放到网站的根目录, 然后自动完成验证. 最后会自行删除验证文件。
~~~~~shell
acme.sh --issue -d example.com -w /home/wwwroot/example.com
~~~~~
##### Standalone mode:
如果没有Web服务器，且80端口是空闲的，可以使用独立模式。acme.sh会用内置的独立网络服务器，监听80端口进行验证以颁发证书。
~~~~~shell
acme.sh  --issue  -d example.com  --standalone
~~~~~
##### dns 方式:
**手动模式**
~~~~~shell
acme.sh  --issue  --dns   -d example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
~~~~~
在域名解析后台添加这个 txt 记录。等解析完成后再次刷新证书。
~~~~~shell
acme.sh --renew -d example.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
~~~~~
这种方式是需要手动添加解析记录的，所以无法自动更新证书。

**自动模式**

acme.sh 集成支持了一些域名解析商的 api 可以自动添加记录以完成验证，实现自动更新。可以自动添加记录以完成验证，并实现自动更新。

以阿里云为例，首先需要登录到阿里云帐户以获取API密钥。 https://ak-console.aliyun.com/#/accesskey
~~~~~yaml
export Ali_Key="sdfsdfsdfljlbjkljlkjsdfoiwje"
export Ali_Secret="jlsdflanljkljlfdsaklkjflsa"
~~~~~
设置后可以自动验证颁发证书。
~~~~~yaml
acme.sh --issue --dns dns_aws -d example.com
~~~~~
**Nginx mode:**

如果使用 nginx 服务器可以自动从 nginx 配置中完成验证。
~~~~~shell
acme.sh  --issue  -d example.com  --nginx
~~~~~

### 安装证书

生成的证书默认放在 acme.sh 的安装目录下，不应该直接使用该目录下的文件，因为这里面的文件都是内部使用, 而且目录结构可能会发生变化。
可以使用 --install-cert 命令安装证书，把证书copy到相应的位置。

比如 nginx:

~~~~~shell
acme.sh --install-cert -d example.com \
--key-file  /path/to/keyfile/in/nginx/cert.key  \
--fullchain-file /path/to/fullchain/nginx/cert.pem \
--reloadcmd  "service nginx force-reload"
~~~~~

跟上的 --reloadcmd 命令，是指定重新加载服务器的命令，证书安装成功或自动更新之后会重新加载服务使新证书生效。

### 更新证书
目前通过 acme.sh 生成的证书会在60天过期，那怎么更新证书呢？

**手动更新**

~~~~~shell
acme.sh --renew -d example.com --force
~~~~~

**自动更新**

安装 acme.sh 时会自动创建一个 cronjob，每天定期检查所有证书，如果证书需要更新会自动更新证书。

通过 crontab -l 查看 crontab 任务:

~~~~~shell
46 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null
~~~~~

### 更新acme.sh
由于 acme 协议和 letsencrypt CA 都在频繁的更新, 因此 acme.sh 也经常更新以保持同步。
~~~~~shell
acme.sh --upgrade
~~~~~

保持自动升级。

~~~~~shell
acme.sh  --upgrade  --auto-upgrade
~~~~~

![img](pic\v2-a35ebec61efc321b29dd949b6f6c9bfe_r.jpg)