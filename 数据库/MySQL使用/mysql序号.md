资料来源：<br/>
[SQL 经典面试题 - 行列转换](https://blog.csdn.net/BestEternity/article/details/88249601)

## mysql查询显示行号

### 介绍

> **racle中有专门的rownum()显示行号的函数，而MySQL没有专门的显示行号函数，但可以通过用@rownum自定义变量显示行号。**

- 主要代码

`(SELECT @rownum := 0) AS rn`

`(@rownum := @rownum + 1) rownum`

### 举例

原始数据

~~~~sql
  CREATE TABLE tb_lemon_grade (
 id INT(10) NOT NULL AUTO_INCREMENT PRIMARY KEY,
 student_name VARCHAR(20) DEFAULT NULL,
 course VARCHAR(20) DEFAULT NULL,
 score FLOAT DEFAULT '0');
 
   INSERT INTO tb_lemon_grade (student_name, course, score) VALUES
("张三", "Linux", 85),
("张三", "MySQL", 92),
("张三", "Java", 87),
("李四", "Linux", 96),
("李四", "MySQL", 89),
("李四", "Java", 100),
("王五", "Linux", 91),
("王五", "MySQL", 83),
("王五", "Java", 98);
~~~~

### 一次性查询

~~~~sql
SELECT
	@rownum := 0;
SELECT
	( @rownum := @rownum + 1 ) AS rownum,
	student_name,
	course,
	score 
FROM
	tb_lemon_grade;
~~~~

### 优化后

上面的sql 可以看出，是两条SQL，第一条sql，是rownum 设置成0，第二条sql。每条记录rownum值进行递增。如果有并发，就会出现问题，因而需要优化。整合成一条记录

~~~~sql
SELECT (@rownum := @rownum + 1) AS rownum,
	t1.student_name,
	t1.course,
	t1.score 
	from tb_lemon_grade t1,
	(SELECT 
    @rownum := 0) AS rn;
~~~~



