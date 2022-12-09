select t.TABLE_NAME "表名" from tabs t;
-----解决乱码：当客户端和服务端编码不一致的情况下，出现乱码。
----查询服务端编码
select userenv('language') from dual;----AMERICAN_AMERICA.ZHS16GBK
----查询客户端编码
select * from V$NLS_PARAMETERS;---AMERICAN
------配置环境变量来解决中文乱码

-------解锁scott用户
alter user scott account unlock;
alter user scott identified by tiger;

-----就可以切换到scott用户下了
----查看emp表数据
select * from emp;

------要求把ename和job在一列上显示
---第一步查出ename和job
select e.ename, e.job from emp e;
---第二步把ename和job和成一列【concat字符串链接符，oracle和mysql通用】
select concat(e.ename, e.job) from emp e;
--------oracle中concat只能链接两个字符串，链接多个用||
select concat(e.ename,'的工作为：', e.job) from emp e;--错误写法
----正确写法
select e.ename || '的工作为：' || e.job "员工的工作" from emp e;

---------where
---查询出工资高于2000的员工信息
-----select是在where之后执行
select e.ename, e.sal s from emp e where s>2000;

----------order by【注意排序中的null值问题】
---按照奖金从高到底排序
select * from emp e where e.comm is not null order by e.comm desc;
select * from emp e order by e.comm desc nulls last;

------模糊查询
-----查询出名字中含有M的员工
select * from emp e where e.ename like '_M%';

-------null 不是0，而且不是''
-----算出每个员工的年薪【null和任意值相加等于null】
select e.sal*12+nvl(e.comm, 0) from emp e;

------什么时候用''什么时候用""？别名的时候用""，其余都用''


----sql语言是一门独立的编程语言。sql支持oracle，mysql等等等数据库

-------dual 虚表：没有任何的意义，只是为了补全语法
-----mysql中查询当前时间
select sysdate();
----oracle中查询当前时间
select sysdate from dual;

------字符函数
select lower('YES') from dual;---大写变小写
select upper('yes') from dual;---小写变大写
select substr('abcdefg', 3, 2) from dual;---截取字符串
select length('abcdefg') from dual;---获取字符串长度
----第二个字符串在第一个字符串中的位置
select instr('ababcdefg', 'ab') from dual;
----用第三个字符在左边补齐第一个字符串，长度是第二个参数
select lpad('abc', 6, 'h') from dual;
----去空格
select trim('   a   '), '   a   ' from dual;
---替换字符串
select replace('abcdefg', 'ab', 'sss') from dual;

----数值函数
select round(26.16, -2) from dual;--四舍五入
select trunc(26.16, 1) from dual;--直接截取
select mod(12, 5) from dual;--求余

----日期函数
---算出每个员工入职距离现在多少月
select round(months_between(sysdate, e.hiredate)) from emp e;
---算出每个员工入职距离现在多少天
select sysdate-e.hiredate from emp e;
---算出每个员工入职距离现在多少周
select (sysdate-e.hiredate)/7 from emp e;
---明天这个时候
select sysdate-365 from dual;
---日期精确到年月日【常用按天统计或者按天分组】
select trunc(sysdate) from dual;
---日期的四舍五入
select round(sysdate) from dual;

-----转换函数
select * from emp e where e.empno = '7788';---隐式转换
----to_number
select to_number('11111'), '11111' from dual;
----to_char
---把时间类型转换成字符串
select to_char(sysdate, 'fm yyyy-mm-dd hh24:mi:ss') from dual;
---
select to_char(sysdate, 'year') from dual;---只取年【英文】
select to_char(sysdate, 'yyyy') from dual;---只取年
select to_char(sysdate, 'mm') from dual;---只取月
select to_char(sysdate, 'month') from dual;---只取月【英文】
select to_char(sysdate, 'day') from dual;---周几
select to_char(sysdate, 'dd') from dual;---只取天
select to_char(sysdate, 'dy') from dual---只取周号【简写】
select to_char(123456, 'L999,999.999') from dual;---格式化数字
----to_date
select to_date('2017-03-04 17:55:27', 'yyyy-mm-dd hh24:mi:ss') from dual;
-----通用函数
select nvl(7, 6) from dual;---第一个参数为null显示第二个，否则显示第一个
select nvl2(3, 1, 8) from dual;---第一个参数为null显示第三个，否则显示第二个
select nullif(8, 8) from dual;---两个参数一样显示null。不一样显示第一个
select coalesce(null, 1, null, 2, null, 3) from dual;---输出第一个不为null的值

-----条件表达式
-----给emp表中的员工起中文名
----【oracle和mysql通用】
select case e.ename
       when 'SMITH' then '诸葛小儿'
         when 'ALLEN' then '曹贼'
           when 'WARD' then '大耳贼'
             when 'JONES' then '宋三郎'
               --else '武大郎'
                 end "中文名"
from emp e;
----【oracle专用条件表达式】
select  decode(e.ename,
        'SMITH',  '诸葛小儿',
          'ALLEN',  '曹贼',
            'WARD',  '大耳贼',
              'JONES',  '宋三郎')
                --'武大郎')
                  "中文名"
from emp e;

----多行函数
select count(1) from emp e;
select sum(e.sal) from emp e;
select max(e.sal) from emp e;
select min(e.sal) from emp e;
select avg(e.sal) from emp e;

----多行函数：作用于多行，返回一个值
------算出各个部门的平均工资
------分组：如果要在select后面出现的原始列，必须在group by后面出现
-----------如果在group by后面出现的原始列，可以不在select后面出现
select e.deptno, avg(e.sal)
from emp e group by e.deptno;

-----查询出平均工资高于2000的部门
select e.deptno, avg(e.sal) asal
from emp e group by e.deptno
having avg(e.sal)>2000;

-----查询出各个部门工资高于1000的员工的平均工资
select e.deptno, avg(e.sal)
from emp e
where e.sal > 1000
group by e.deptno;

-----先查询出各个部门工资高于1000的员工的平均工资，
-----再查询出平均工资高于2000的部门
select e.deptno, avg(e.sal)
from emp e
where e.sal > 1000
group by e.deptno
having avg(e.sal)>2000;
-------where必须用在group by 之前，对分组前的数据进行过滤
-------having必须用在group by 之后，对分组后的数据进行过滤





