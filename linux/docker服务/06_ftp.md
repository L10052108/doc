资料来源：<br/>
[ftp](https://hub.docker.com/r/bogem/ftp/ )<br/>


## docker 运行

```
docker run -d -v /home/vsftpd:/home/vsftpd \
                -p 20:20 -p 21:21 -p 47400-47470:47400-47470 \
                -e FTP_USER=root \
                -e FTP_PASS=root \
                -e PASV_ADDRESS=0.0.0.0 \
                --name ftp \
                --restart=always bogem/ftp

```
> 登录的用户名：root  密码： root