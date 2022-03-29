https://www.toutiao.com/article/7067138670272496166/?log_from=11a11471af1538_1648437886126

## 行列转换

> 第 30 期学生要毕业了，他们 Linux、MySQL、Java 成绩保存在数据表 tb_lemon_grade 中，表中字段 id，student_name，course，score 分别表示成绩 id，学生姓名，课程名称，课程成绩，表中数据表 1 所示。请写出一条 SQL，将表 1 的数据变成表 2 的形式

- 原始数据

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h0ps701qpqj20hy0bgwew.jpg ":size=40%")

- 转化后

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h0ps8bopqjj20j006874d.jpg ":size=40%")





#### 原始数据

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



if

~~~~sql
SELECT student_name,
IF(COURSE = 'Linux',SCORE,0) 'Linux',
IF(COURSE = 'MySQL',SCORE,0) 'MySQL',
IF(COURSE = 'Java',SCORE,0) 'Java'
FROM tb_lemon_grade;
;
~~~~





