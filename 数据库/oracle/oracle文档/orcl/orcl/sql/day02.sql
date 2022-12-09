-----多表联查
----笛卡儿积
select *
from emp e, dept d;
----等值连接
select * 
from emp e, dept d
where e.deptno = d.deptno;
-----不等值连接
select * 
from emp e, dept d
where e.deptno != d.deptno;
-----显示出所有部门的信息
----外链接【oracle和mysql通用写法】
select * 
from dept d left join emp e 
on d.deptno = e.deptno;
----外链接【oracle专用写法】
----要显示哪边的全部数据，就在该条件的对面写上(+)
select * 
from emp e, dept d
where e.deptno(+) = d.deptno;
--------显示出所有员工的姓名和该员工领导的姓名
-----【思路：我们要拿员工表和领导表联查】
------自链接
select e1.ename, e2.ename
from emp e1, emp e2
where e1.mgr = e2.empno;--该条件确定了e1是员工表，e2是领导表

------员工的姓名，员工的部门名称，领导的姓名，领导的部门名称
-----【注意：部门表，要分员工部门表和领导部门表】
select e1.ename, d1.dname, e2.ename, d2.dname
from emp e1, emp e2, dept d1, dept d2
where e1.mgr = e2.empno
and e1.deptno = d1.deptno
and e2.deptno = d2.deptno;

------员工的姓名，员工的部门名称，员工的工资等级
------领导的姓名，领导的部门名称，领导的工资等级
select e1.ename, d1.dname, s1.grade, e2.ename, d2.dname, s2.grade
from emp e1, emp e2, dept d1, dept d2, salgrade s1, salgrade s2
where e1.mgr = e2.empno
and e1.deptno = d1.deptno
and e2.deptno = d2.deptno
and e1.sal between s1.losal and s1.hisal
and e2.sal between s2.losal and s2.hisal;

------员工的姓名，员工的部门名称，员工的工资等级
------领导的姓名，领导的部门名称，领导的工资等级
------工资等级显示汉字
select e1.ename, d1.dname, 
       case s1.grade
         when 1 then '一级'
           when 2 then '二级'
             when 3 then '三级'
               when 4 then '四级'
                 else '五级'
                   end "工资等级", e2.ename, d2.dname, s2.grade
from emp e1, emp e2, dept d1, dept d2, salgrade s1, salgrade s2
where e1.mgr = e2.empno
and e1.deptno = d1.deptno
and e2.deptno = d2.deptno
and e1.sal between s1.losal and s1.hisal
and e2.sal between s2.losal and s2.hisal;

-----子查询
----子查询返回一个值
----查询出工资和WARD一样的员工信息
----第一步：查出WARD的工资
select sal from emp where ename = 'WARD';
---第二步：查询出工资和WARD一样的员工信息
select * from emp e
where e.sal = (select sal from emp where ename = 'WARD');
----子查询返回一个集合
----查询出和10号部门任意一个员工工资一样的员工信息
----第一步：查出10号部门所有员工工资的集合
select sal from emp where deptno = 10;
----第二步：查询出和10号部门任意一个员工工资一样的员工信息
select * from emp e 
where e.sal in (select sal from emp where deptno = 10);
----子查询作为一张表
----查询出平均工资高于2000的部门,并且显示出部门名称
----第一步：查询出每个部门的平均工资
select e.deptno, avg(e.sal)
from emp e
group by e.deptno
----第二步：查询出平均工资高于2000的部门,并且显示出部门名称
select d.dname, t.asal
from (select e.deptno, avg(e.sal) asal
from emp e
group by e.deptno) t, dept d
where t.deptno = d.deptno
and asal > 2000;

-----查出比7654工资高，和7788工作一样的员工信息
---第一步：查出7654工资和7788的工作
select sal from emp where empno = 7654;
select job from emp where empno = 7788;
---第二步：查出比7654工资高，和7788工作一样的员工信息
select * from emp e
where e.sal>(select sal from emp where empno = 7654)
and e.job = (select job from emp where empno = 7788);
------查出每个部门最低工资，最低工资的员工姓名，最低工资员工的部门名称
---第一步：查出每个部门最低工资
select e.deptno, min(e.sal)
from emp e
group by e.deptno;
----第二步：查出每个部门最低工资，最低工资的员工姓名，最低工资员工的部门名称
select d.dname, t.msal, ee.ename
from (select e.deptno, min(e.sal) msal
from emp e
group by e.deptno) t, emp ee, dept d
where t.deptno = ee.deptno---确定在一个部门
and t.msal = ee.sal---查出该部门最低工资的员工
and t.deptno = d.deptno;----部门名称

------------查询出不是领导的员工。
----1:查出所有领导的编号
select mgr from emp;
----2:把领导编号的集合作为条件，排除该条件
select * from emp e 
where e.empno not in (select mgr from emp);
-----问题：in或者not in后面，用集合作为条件的时候，该集合内不能有null值
-----解决方案
-----第一种：
select * from emp e 
where e.empno not in 
(select mgr from emp where mgr is not null);
-----第二种：
select * from emp e 
where e.empno not in (select nvl(mgr, '') from emp);
-----第三种：
select * from emp e 
where e.empno not in 
(select e2.empno
from emp e1, emp e2
where e1.mgr = e2.empno)

---总结：用in或者not in的时候，后面集合的条件必须加 is not null

------exists
----第一种用法
select * from emp where exists 
(select * from dept where deptno = 10);
select * from emp where exists 
(select * from dept where deptno = 50);

----第二种用法
----查询出有员工的部门
-----【其实就是查询出dept表中主键deptno作为emp表的外键
-------在emp表中有数据的记录】
select * from dept d where exists
(select * from emp e where e.deptno = d.deptno);
----exists的第二种用法。有点类似于in
select * from dept d where d.deptno in
(select deptno from emp);
----在数据量大的情况下exists的效率远高于in

-------rownum 伪列：在执行select操作的时候，每加载一行数据
--------------------就在该数据上加上一个序列
select rownum, e.* from emp e;
select e.* from emp e where rownum < 3;

-----查询出工资最高的前三名
-----【先select，再order by】
select rownum, e.* from emp e order by e.sal desc;
----解决方案，子查询
select * from emp order by sal desc;---该次查询后rownum的顺序已经被order by弄乱了
----所以我重新嵌套一层select
select rownum, t.* from 
(select * from emp order by sal desc) t
where rownum < 4;

------找到薪水大于本部门平均工资的员工信息
---第一步：查询出每个部门平均工资
select e.deptno, avg(e.sal)
from emp e
group by e.deptno;
---第二步：找到薪水大于本部门平均工资的员工信息
select ee.ename, ee.job, t.asal, ee.sal
from (select e.deptno, avg(e.sal) asal
from emp e
group by e.deptno) t, emp ee
where t.deptno = ee.deptno
and ee.sal>t.asal;

-------统计每年入职的员工个数
select to_char(e.hiredate, 'yyyy') y, count(1) n
from emp e
group by to_char(e.hiredate, 'yyyy');

-----第一步：算出总人数
select sum(n) total
from (select to_char(e.hiredate, 'yyyy') y, count(1) n
from emp e
group by to_char(e.hiredate, 'yyyy'));
-----第二步：把1987放倒
select case y
         when '1987' then n
           end "1987"
from (select to_char(e.hiredate, 'yyyy') y, count(1) n
from emp e
group by to_char(e.hiredate, 'yyyy'));
-----第三步：把第一步和第二步的结果并起来
select sum(n) total,
       max(case y
         when '1987' then n
           end) "1987"
from (select to_char(e.hiredate, 'yyyy') y, count(1) n
from emp e
group by to_char(e.hiredate, 'yyyy'));
-----最后一步：把其余列补齐
select sum(n) total,
       max(case y
         when '1987' then n
           end) "1987",
       min(case y
         when '1980' then n
           end) "1980",
       sum(case y
         when '1982' then n
           end) "1982",
       avg(case y
         when '1981' then n
           end) "1981"
from (select to_char(e.hiredate, 'yyyy') y, count(1) n
from emp e
group by to_char(e.hiredate, 'yyyy'));

-------oracle中的分页【rownum】

select rownum, e.* from emp e order by sal desc;
-----查询出emp表中每页5条数据，的第二页数据
select * from
(select e.* from emp e order by sal desc)
where rownum < 11 and rownum > 5;
-----rownum 不能直接用where rownum > 正数
-----原因：where操作是优先于select操作
-----------当我们即将select第一条数据的时候，应该给rownum赋1
-----------此时rownum的值来判断where后面的条件where rownum > 5
-----------1>5????那么该条数据显示吗？那么后面还执行吗？？

----解决办法：我们要间接使用rownum
select * from
    (select rownum rn, tt.* from(
        select e.* from emp e order by sal desc---1000行sql
    ) tt where rownum < 11)
where rn > 5;

------rowid: 行号，代表一行存储的物理地址，不会改变
----------可以用来在plsql中修改数据
------rownum：伪列，随时可能改变

select rowid,s.* from salgrade s;

----------------集合运算
----查询出工资等级是1的员工
select * from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal;
----查询出工资等级是2的员工
select * from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;
------集合运算不能直接写*
-------union all 联合所有
select e.* from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal
union all
select e.* from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;
----union 联合去重
select e.* from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal
union
select e.* from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;
-------intersect 交集
select e.* from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal
intersect
select e.* from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;
-----minus  差集
select e.* from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal
minus
select e.* from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;

--------应用场景：集合运算，主要应用在老数据的表和新数据的表联查
--------注意事项！集合查询的双方，数据的数量，以及对应的类型必须一致
-----------------如果上下字段数量无法一直，要补null或者同类型的值
select e.ename, e.sal, e.mgr from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal 
union
select e.job, e.comm, null from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;








