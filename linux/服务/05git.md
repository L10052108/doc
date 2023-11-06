资料来源：<br/>
[linux 保存git的账号密码](https://www.yii666.com/article/40090.html)

一、通过文件方式

1.在~下， touch创建文件 .git-credentials, 用vim编辑此文件，输入内容格式：

```shell
cd ~
touch .git-credentials
vim .git-credentials
```

在里面按“i”然后输入： `https://{username}:{password}@github.com`

比如我的码云账号

```shell
 https://{acccount}:{password}@gitee.com
```

2.  在终端下执行

```shell
git config --global credential.helper store
```

3. 可以看到.gitconfig文件，会多了一项：

```
[credential]
helper = store
```

查看结果

![image-20231106152726947](img/image-20231106152726947.png)

说明成功了