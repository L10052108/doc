资料来源：<br/>
[SQL 经典面试题 - 行列转换](https://www.toutiao.com/article/7067138670272496166/?log_from=11a11471af1538_1648437886126)


## 行列转换

> 第 30 期学生要毕业了，他们 Linux、MySQL、Java 成绩保存在数据表 tb_lemon_grade 中，表中字段 id，student_name，course，score 分别表示成绩 id，学生姓名，课程名称，课程成绩，表中数据表 1 所示。请写出一条 SQL，将表 1 的数据变成表 2 的形式

- 原始数据

| id   | 学生姓名 | 课程名称 | 课程成绩 |
| ---- | -------- | -------- | -------- |
| 1    | 张三     | Linux    | 85       |
| 2    | 张三     | MySQL    | 92       |
| 3    | 张三     | Java     | 87       |
| 4    | 李四     | Linux    | 96       |
| 5    | 李四     | MySQL    | 89       |
| 6    | 李四     | Java     | 100      |
| 7    | 王五     | Linux    | 91       |
| 8    | 王五     | MySQL    | 83       |
| 9    | 王五     | Java     | 98       |

- 转化后

| 学生姓名 | Linux | MySQL | Java |
| -------- | ----- | ----- | ---- |
| 张三     | 85    | 92    | 87   |
| 李四     | 96    | 89    | 100  |
| 王五     | 91    | 83    | 98   |

**原始数据**

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



### 思路

?> 思考：怎么处理

>1.把行转化成列 
>
>2.数据获取
>
>3.数据处理



整理后的结果

![img](img/2285f9722bff4f3e90971541e791a1f4~noop.image)

### 行转成列

把需要展示的列，列出来

~~~~java
select student_name,
0 as 'Linux',
0 as 'MySQL',
0   as 'Java'
 from tb_lemon_grade;
~~~~

展示效果

![img](img/263ff7084ba040149e8aa286483ee35f~noop.image)



### 数据填充

两种方法进行填充数据

比如 ID= 1的张三", "Linux", 85这条记录

进行列的判断，如果是linux，填入85其他的填入0

常用的判断方法，if和case两种方法

- if判断

~~~sql
SELECT student_name,
IF(COURSE = 'Linux',SCORE,0) 'Linux',
IF(COURSE = 'MySQL',SCORE,0) 'MySQL',
IF(COURSE = 'Java',SCORE,0) 'Java'
FROM tb_lemon_grade;
~~~

- case

~~~~sql
 SELECT student_name,
(CASE COURSE when 'Linux' THEN SCORE ELSE 0 END ) as 'Linux',
(CASE COURSE when 'MySQL' THEN SCORE ELSE 0 END ) as 'MySQL',
(CASE COURSE when 'Java' THEN SCORE ELSE 0 END ) as 'Java'
FROM tb_lemon_grade;
~~~~

运行结果

![img](img/2cc5258de96546069b9b32841a48029b~noop.image)

### 聚合运算

- 两种方案，一种是求和，一种是求最大值

- sum
~~~~sql
SELECT
	student_name,
	SUM( IF ( COURSE = 'Linux', SCORE, 0 ) ) 'Linux',
	SUM( IF ( COURSE = 'MySQL', SCORE, 0 ) ) 'MySQL',
	sum( IF ( COURSE = 'Java', SCORE, 0 ) ) 'Java' 
FROM
	tb_lemon_grade 
GROUP BY
	student_name
~~~~

- max

~~~~sql
SELECT
	student_name,
	MAX( IF ( COURSE = 'Linux', SCORE, 0 ) ) 'Linux',
	MAX( IF ( COURSE = 'MySQL', SCORE, 0 ) ) 'MySQL',
	MAX( IF ( COURSE = 'Java', SCORE, 0 ) ) 'Java' 
FROM
	tb_lemon_grade 
GROUP BY
	student_name
~~~~

![img](img/aa0f87f9d1cc47fc855703b45cb9d3b9~noop.image)

## 其他方案

>思路：先查询所有的学生名，通过学生名和课程两个条件可以查询学生的分数

~~~~sql
select DISTINCT(t1.student_name) as student_name ,
(select SCORE from tb_lemon_grade where student_name = t1.student_name and COURSE = 'Linux') as 'Linux',
(select SCORE from tb_lemon_grade where student_name = t1.student_name and COURSE = 'MySQL') as 'MySQL' ,
(select SCORE from tb_lemon_grade where student_name = t1.student_name and COURSE = 'Java') as 'Java' 
from tb_lemon_grade t1
~~~~

