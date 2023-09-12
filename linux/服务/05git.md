资料来源：<br/>
[linux 保存git的账号密码](https://www.yii666.com/article/40090.html)

一、通过文件方式**文章来源地址:https://www.yii666.com/article/40090.html**

1.在~/下， touch创建文件 .git-credentials, 用vim编辑此文件，输入内容格式：

```
touch .git-credentials
vim .git-credentials
```

在里面按“i”然后输入： https://{username}:{password}@github.com

比如 https://account:password@github.com

2. 在终端下执行文章来源地址https://www.yii666.com/article/40090.html*文章地址https://www.yii666.com/article/40090.html*

```
git config --global credential.helper store
```

3. 可以看到~/.gitconfig文件，会多了一项：

```
[credential]
helper = store
```

4.OK