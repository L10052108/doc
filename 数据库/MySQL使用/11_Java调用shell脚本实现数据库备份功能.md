资料来源：<br/>
[Java调用shell脚本实现数据库备份功能](https://www.toutiao.com/article/7321210262080979482/?app=news_article&timestamp=1704617378&use_new_style=1&req_id=20240107164938272CC20262D2A16836F5&group_id=7321210262080979482&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=e72121bb-e426-4d51-babf-28b851d51b74&source=m_redirect)

本篇文章主要介绍怎样使用Java程序，执行服务器上的数据库备份Shell脚本进行MySQL数据库的备份功能。

## 学习目标

使用Java执行Shell脚本、实现MySQL数据库的备份功能。

## 学习内容

### 编写导出MySQL数据库的Shell脚本

以下是一个使用Bash脚本进行数据库备份的示例代码：

> xk_mysql.sh

```
#!/bin/bash
source  /etc/profile
# 设置备份目录和文件名
backup_directory="/root/xxkfz/service/db_backup"
backup_filename="xxkfz_$(date +%Y%m%d%H:%M:%S).sql"

# 设置MySQL连接参数
mysql_host="127.0.0.1"
mysql_user="root"
mysql_password="123456"
mysql_database="xxkfz"

# 创建备份目录
mkdir -p "$backup_directory"

echo   -e "\033[36m MYSQL数据库正在备份,请稍等......  \033[0m"

# 执行备份命令
mysqldump -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" "$mysql_database" > "$backup_directory/$backup_filename"


# 检查备份是否成功
if [ $? -eq 0 ]; then
  echo -e "\033[33m "MySQL数据库备份成功：$backup_directory/$backup_filename" \033[0m"
else
  echo -e "\033[35m 数据库备份失败 \033[0m"
fi
```

将以上程序代码保存为xk_mysql_backup.sh文件，并且执行以下命令给予执行的权限：

```
chmod +x xk_mysql.sh
```

**测试**

输入./xk_mysql.sh或者sh xk_mysql.sh执行脚本



![img](img/7435272157af4872a0f78b6a579127dc~noop.image)





数据库备份成功，查询备份的sql文件：

![img](img/3ad104b39ca84ab990e8fb0a13de9b39~noop.image)





![img](img/20d393643b0b47ff951b14e21dcbe17d~noop.image)





# 编写Java代码执行Shell脚本

```
   /**
    * 实现简单的数据库备份
   */
public void dbBackup() {
        log.debug("开始执行数据库备份......");
        long l = System.currentTimeMillis();
        try {
            String command = "sh xk_mysql.sh";
            // 
            Process process = Runtime.getRuntime().exec(command, null, new File("/root/xxkfz/service/shell"));
            // 获取Shell脚本输出结果
            InputStream inputStream = process.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
            String line;
            while ((line = reader.readLine()) != null) {
                log.debug("result = {}", line);
            }
        } catch (Exception ex) {
            log.error("数据库备份失败：{}", ex.getMessage());
        }
        long l1 = System.currentTimeMillis();
        log.debug("数据库备份完成,耗时：{}", l1 - l);
    }
```

我们可以通过定时任务的方式调用上面dbBackup方法，来实现每天的MySQL数据库的备份。

下面通过一个简单的定时任务进行测试：配置cron表达式每隔两小时进行备份一次。

> ScheduledService.java

```
@Component
@Slf4j
public class ScheduledService {


    /**
     * 实现简单的数据库备份
     * 每隔2小时执行一次
     */
    @Scheduled(cron = "0 0 */2 * * ?")
    public void dbBackup() {
        log.error("开始执行数据库备份......");
        long l = System.currentTimeMillis();
        try {
            String command = "sh xk_mysql.sh";
            Process process = Runtime.getRuntime().exec(command, null, new File("/root/xxkfz/service/shell"));
            // 获取Shell脚本输出结果
            InputStream inputStream = process.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
            String line;
            while ((line = reader.readLine()) != null) {
                log.error("result = {}", line);
            }
        } catch (Exception ex) {
            log.error("数据库备份失败：{}", ex.getMessage());
        }
        long l1 = System.currentTimeMillis();
        log.error("数据库备份完成,耗时：{}", l1 - l);
    }
}
```

在项目测试环境中进行效果展示：

![img](img/478d14591519452db55ffc7d029ad993~noop.image)