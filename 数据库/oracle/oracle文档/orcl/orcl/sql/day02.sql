-----�������
----�ѿ�����
select *
from emp e, dept d;
----��ֵ����
select * 
from emp e, dept d
where e.deptno = d.deptno;
-----����ֵ����
select * 
from emp e, dept d
where e.deptno != d.deptno;
-----��ʾ�����в��ŵ���Ϣ
----�����ӡ�oracle��mysqlͨ��д����
select * 
from dept d left join emp e 
on d.deptno = e.deptno;
----�����ӡ�oracleר��д����
----Ҫ��ʾ�ıߵ�ȫ�����ݣ����ڸ������Ķ���д��(+)
select * 
from emp e, dept d
where e.deptno(+) = d.deptno;
--------��ʾ������Ա���������͸�Ա���쵼������
-----��˼·������Ҫ��Ա������쵼�����顿
------������
select e1.ename, e2.ename
from emp e1, emp e2
where e1.mgr = e2.empno;--������ȷ����e1��Ա����e2���쵼��

------Ա����������Ա���Ĳ������ƣ��쵼���������쵼�Ĳ�������
-----��ע�⣺���ű�Ҫ��Ա�����ű���쵼���ű�
select e1.ename, d1.dname, e2.ename, d2.dname
from emp e1, emp e2, dept d1, dept d2
where e1.mgr = e2.empno
and e1.deptno = d1.deptno
and e2.deptno = d2.deptno;

------Ա����������Ա���Ĳ������ƣ�Ա���Ĺ��ʵȼ�
------�쵼���������쵼�Ĳ������ƣ��쵼�Ĺ��ʵȼ�
select e1.ename, d1.dname, s1.grade, e2.ename, d2.dname, s2.grade
from emp e1, emp e2, dept d1, dept d2, salgrade s1, salgrade s2
where e1.mgr = e2.empno
and e1.deptno = d1.deptno
and e2.deptno = d2.deptno
and e1.sal between s1.losal and s1.hisal
and e2.sal between s2.losal and s2.hisal;

------Ա����������Ա���Ĳ������ƣ�Ա���Ĺ��ʵȼ�
------�쵼���������쵼�Ĳ������ƣ��쵼�Ĺ��ʵȼ�
------���ʵȼ���ʾ����
select e1.ename, d1.dname, 
       case s1.grade
         when 1 then 'һ��'
           when 2 then '����'
             when 3 then '����'
               when 4 then '�ļ�'
                 else '�弶'
                   end "���ʵȼ�", e2.ename, d2.dname, s2.grade
from emp e1, emp e2, dept d1, dept d2, salgrade s1, salgrade s2
where e1.mgr = e2.empno
and e1.deptno = d1.deptno
and e2.deptno = d2.deptno
and e1.sal between s1.losal and s1.hisal
and e2.sal between s2.losal and s2.hisal;

-----�Ӳ�ѯ
----�Ӳ�ѯ����һ��ֵ
----��ѯ�����ʺ�WARDһ����Ա����Ϣ
----��һ�������WARD�Ĺ���
select sal from emp where ename = 'WARD';
---�ڶ�������ѯ�����ʺ�WARDһ����Ա����Ϣ
select * from emp e
where e.sal = (select sal from emp where ename = 'WARD');
----�Ӳ�ѯ����һ������
----��ѯ����10�Ų�������һ��Ա������һ����Ա����Ϣ
----��һ�������10�Ų�������Ա�����ʵļ���
select sal from emp where deptno = 10;
----�ڶ�������ѯ����10�Ų�������һ��Ա������һ����Ա����Ϣ
select * from emp e 
where e.sal in (select sal from emp where deptno = 10);
----�Ӳ�ѯ��Ϊһ�ű�
----��ѯ��ƽ�����ʸ���2000�Ĳ���,������ʾ����������
----��һ������ѯ��ÿ�����ŵ�ƽ������
select e.deptno, avg(e.sal)
from emp e
group by e.deptno
----�ڶ�������ѯ��ƽ�����ʸ���2000�Ĳ���,������ʾ����������
select d.dname, t.asal
from (select e.deptno, avg(e.sal) asal
from emp e
group by e.deptno) t, dept d
where t.deptno = d.deptno
and asal > 2000;

-----�����7654���ʸߣ���7788����һ����Ա����Ϣ
---��һ�������7654���ʺ�7788�Ĺ���
select sal from emp where empno = 7654;
select job from emp where empno = 7788;
---�ڶ����������7654���ʸߣ���7788����һ����Ա����Ϣ
select * from emp e
where e.sal>(select sal from emp where empno = 7654)
and e.job = (select job from emp where empno = 7788);
------���ÿ��������͹��ʣ���͹��ʵ�Ա����������͹���Ա���Ĳ�������
---��һ�������ÿ��������͹���
select e.deptno, min(e.sal)
from emp e
group by e.deptno;
----�ڶ��������ÿ��������͹��ʣ���͹��ʵ�Ա����������͹���Ա���Ĳ�������
select d.dname, t.msal, ee.ename
from (select e.deptno, min(e.sal) msal
from emp e
group by e.deptno) t, emp ee, dept d
where t.deptno = ee.deptno---ȷ����һ������
and t.msal = ee.sal---����ò�����͹��ʵ�Ա��
and t.deptno = d.deptno;----��������

------------��ѯ�������쵼��Ա����
----1:��������쵼�ı��
select mgr from emp;
----2:���쵼��ŵļ�����Ϊ�������ų�������
select * from emp e 
where e.empno not in (select mgr from emp);
-----���⣺in����not in���棬�ü�����Ϊ������ʱ�򣬸ü����ڲ�����nullֵ
-----�������
-----��һ�֣�
select * from emp e 
where e.empno not in 
(select mgr from emp where mgr is not null);
-----�ڶ��֣�
select * from emp e 
where e.empno not in (select nvl(mgr, '') from emp);
-----�����֣�
select * from emp e 
where e.empno not in 
(select e2.empno
from emp e1, emp e2
where e1.mgr = e2.empno)

---�ܽ᣺��in����not in��ʱ�򣬺��漯�ϵ���������� is not null

------exists
----��һ���÷�
select * from emp where exists 
(select * from dept where deptno = 10);
select * from emp where exists 
(select * from dept where deptno = 50);

----�ڶ����÷�
----��ѯ����Ա���Ĳ���
-----����ʵ���ǲ�ѯ��dept��������deptno��Ϊemp������
-------��emp���������ݵļ�¼��
select * from dept d where exists
(select * from emp e where e.deptno = d.deptno);
----exists�ĵڶ����÷����е�������in
select * from dept d where d.deptno in
(select deptno from emp);
----����������������exists��Ч��Զ����in

-------rownum α�У���ִ��select������ʱ��ÿ����һ������
--------------------���ڸ������ϼ���һ������
select rownum, e.* from emp e;
select e.* from emp e where rownum < 3;

-----��ѯ��������ߵ�ǰ����
-----����select����order by��
select rownum, e.* from emp e order by e.sal desc;
----����������Ӳ�ѯ
select * from emp order by sal desc;---�ôβ�ѯ��rownum��˳���Ѿ���order byŪ����
----����������Ƕ��һ��select
select rownum, t.* from 
(select * from emp order by sal desc) t
where rownum < 4;

------�ҵ�нˮ���ڱ�����ƽ�����ʵ�Ա����Ϣ
---��һ������ѯ��ÿ������ƽ������
select e.deptno, avg(e.sal)
from emp e
group by e.deptno;
---�ڶ������ҵ�нˮ���ڱ�����ƽ�����ʵ�Ա����Ϣ
select ee.ename, ee.job, t.asal, ee.sal
from (select e.deptno, avg(e.sal) asal
from emp e
group by e.deptno) t, emp ee
where t.deptno = ee.deptno
and ee.sal>t.asal;

-------ͳ��ÿ����ְ��Ա������
select to_char(e.hiredate, 'yyyy') y, count(1) n
from emp e
group by to_char(e.hiredate, 'yyyy');

-----��һ�������������
select sum(n) total
from (select to_char(e.hiredate, 'yyyy') y, count(1) n
from emp e
group by to_char(e.hiredate, 'yyyy'));
-----�ڶ�������1987�ŵ�
select case y
         when '1987' then n
           end "1987"
from (select to_char(e.hiredate, 'yyyy') y, count(1) n
from emp e
group by to_char(e.hiredate, 'yyyy'));
-----���������ѵ�һ���͵ڶ����Ľ��������
select sum(n) total,
       max(case y
         when '1987' then n
           end) "1987"
from (select to_char(e.hiredate, 'yyyy') y, count(1) n
from emp e
group by to_char(e.hiredate, 'yyyy'));
-----���һ�����������в���
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

-------oracle�еķ�ҳ��rownum��

select rownum, e.* from emp e order by sal desc;
-----��ѯ��emp����ÿҳ5�����ݣ��ĵڶ�ҳ����
select * from
(select e.* from emp e order by sal desc)
where rownum < 11 and rownum > 5;
-----rownum ����ֱ����where rownum > ����
-----ԭ��where������������select����
-----------�����Ǽ���select��һ�����ݵ�ʱ��Ӧ�ø�rownum��1
-----------��ʱrownum��ֵ���ж�where���������where rownum > 5
-----------1>5????��ô����������ʾ����ô���滹ִ���𣿣�

----����취������Ҫ���ʹ��rownum
select * from
    (select rownum rn, tt.* from(
        select e.* from emp e order by sal desc---1000��sql
    ) tt where rownum < 11)
where rn > 5;

------rowid: �кţ�����һ�д洢�������ַ������ı�
----------����������plsql���޸�����
------rownum��α�У���ʱ���ܸı�

select rowid,s.* from salgrade s;

----------------��������
----��ѯ�����ʵȼ���1��Ա��
select * from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal;
----��ѯ�����ʵȼ���2��Ա��
select * from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;
------�������㲻��ֱ��д*
-------union all ��������
select e.* from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal
union all
select e.* from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;
----union ����ȥ��
select e.* from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal
union
select e.* from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;
-------intersect ����
select e.* from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal
intersect
select e.* from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;
-----minus  �
select e.* from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal
minus
select e.* from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;

--------Ӧ�ó������������㣬��ҪӦ���������ݵı�������ݵı�����
--------ע��������ϲ�ѯ��˫�������ݵ��������Լ���Ӧ�����ͱ���һ��
-----------------��������ֶ������޷�һֱ��Ҫ��null����ͬ���͵�ֵ
select e.ename, e.sal, e.mgr from emp e, salgrade s 
where s.grade = 1 and e.sal between s.losal and s.hisal 
union
select e.job, e.comm, null from emp e, salgrade s 
where s.grade = 2 and e.sal between s.losal and s.hisal;








