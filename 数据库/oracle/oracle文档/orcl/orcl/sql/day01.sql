select t.TABLE_NAME "����" from tabs t;
-----������룺���ͻ��˺ͷ���˱��벻һ�µ�����£��������롣
----��ѯ����˱���
select userenv('language') from dual;----AMERICAN_AMERICA.ZHS16GBK
----��ѯ�ͻ��˱���
select * from V$NLS_PARAMETERS;---AMERICAN
------���û��������������������

-------����scott�û�
alter user scott account unlock;
alter user scott identified by tiger;

-----�Ϳ����л���scott�û�����
----�鿴emp������
select * from emp;

------Ҫ���ename��job��һ������ʾ
---��һ�����ename��job
select e.ename, e.job from emp e;
---�ڶ�����ename��job�ͳ�һ�С�concat�ַ������ӷ���oracle��mysqlͨ�á�
select concat(e.ename, e.job) from emp e;
--------oracle��concatֻ�����������ַ��������Ӷ����||
select concat(e.ename,'�Ĺ���Ϊ��', e.job) from emp e;--����д��
----��ȷд��
select e.ename || '�Ĺ���Ϊ��' || e.job "Ա���Ĺ���" from emp e;

---------where
---��ѯ�����ʸ���2000��Ա����Ϣ
-----select����where֮��ִ��
select e.ename, e.sal s from emp e where s>2000;

----------order by��ע�������е�nullֵ���⡿
---���ս���Ӹߵ�������
select * from emp e where e.comm is not null order by e.comm desc;
select * from emp e order by e.comm desc nulls last;

------ģ����ѯ
-----��ѯ�������к���M��Ա��
select * from emp e where e.ename like '_M%';

-------null ����0�����Ҳ���''
-----���ÿ��Ա������н��null������ֵ��ӵ���null��
select e.sal*12+nvl(e.comm, 0) from emp e;

------ʲôʱ����''ʲôʱ����""��������ʱ����""�����඼��''


----sql������һ�Ŷ����ı�����ԡ�sql֧��oracle��mysql�ȵȵ����ݿ�

-------dual ���û���κε����壬ֻ��Ϊ�˲�ȫ�﷨
-----mysql�в�ѯ��ǰʱ��
select sysdate();
----oracle�в�ѯ��ǰʱ��
select sysdate from dual;

------�ַ�����
select lower('YES') from dual;---��д��Сд
select upper('yes') from dual;---Сд���д
select substr('abcdefg', 3, 2) from dual;---��ȡ�ַ���
select length('abcdefg') from dual;---��ȡ�ַ�������
----�ڶ����ַ����ڵ�һ���ַ����е�λ��
select instr('ababcdefg', 'ab') from dual;
----�õ������ַ�����߲����һ���ַ����������ǵڶ�������
select lpad('abc', 6, 'h') from dual;
----ȥ�ո�
select trim('   a   '), '   a   ' from dual;
---�滻�ַ���
select replace('abcdefg', 'ab', 'sss') from dual;

----��ֵ����
select round(26.16, -2) from dual;--��������
select trunc(26.16, 1) from dual;--ֱ�ӽ�ȡ
select mod(12, 5) from dual;--����

----���ں���
---���ÿ��Ա����ְ�������ڶ�����
select round(months_between(sysdate, e.hiredate)) from emp e;
---���ÿ��Ա����ְ�������ڶ�����
select sysdate-e.hiredate from emp e;
---���ÿ��Ա����ְ�������ڶ�����
select (sysdate-e.hiredate)/7 from emp e;
---�������ʱ��
select sysdate-365 from dual;
---���ھ�ȷ�������ա����ð���ͳ�ƻ��߰�����顿
select trunc(sysdate) from dual;
---���ڵ���������
select round(sysdate) from dual;

-----ת������
select * from emp e where e.empno = '7788';---��ʽת��
----to_number
select to_number('11111'), '11111' from dual;
----to_char
---��ʱ������ת�����ַ���
select to_char(sysdate, 'fm yyyy-mm-dd hh24:mi:ss') from dual;
---
select to_char(sysdate, 'year') from dual;---ֻȡ�꡾Ӣ�ġ�
select to_char(sysdate, 'yyyy') from dual;---ֻȡ��
select to_char(sysdate, 'mm') from dual;---ֻȡ��
select to_char(sysdate, 'month') from dual;---ֻȡ�¡�Ӣ�ġ�
select to_char(sysdate, 'day') from dual;---�ܼ�
select to_char(sysdate, 'dd') from dual;---ֻȡ��
select to_char(sysdate, 'dy') from dual---ֻȡ�ܺš���д��
select to_char(123456, 'L999,999.999') from dual;---��ʽ������
----to_date
select to_date('2017-03-04 17:55:27', 'yyyy-mm-dd hh24:mi:ss') from dual;
-----ͨ�ú���
select nvl(7, 6) from dual;---��һ������Ϊnull��ʾ�ڶ�����������ʾ��һ��
select nvl2(3, 1, 8) from dual;---��һ������Ϊnull��ʾ��������������ʾ�ڶ���
select nullif(8, 8) from dual;---��������һ����ʾnull����һ����ʾ��һ��
select coalesce(null, 1, null, 2, null, 3) from dual;---�����һ����Ϊnull��ֵ

-----�������ʽ
-----��emp���е�Ա����������
----��oracle��mysqlͨ�á�
select case e.ename
       when 'SMITH' then '���С��'
         when 'ALLEN' then '����'
           when 'WARD' then '�����'
             when 'JONES' then '������'
               --else '�����'
                 end "������"
from emp e;
----��oracleר���������ʽ��
select  decode(e.ename,
        'SMITH',  '���С��',
          'ALLEN',  '����',
            'WARD',  '�����',
              'JONES',  '������')
                --'�����')
                  "������"
from emp e;

----���к���
select count(1) from emp e;
select sum(e.sal) from emp e;
select max(e.sal) from emp e;
select min(e.sal) from emp e;
select avg(e.sal) from emp e;

----���к����������ڶ��У�����һ��ֵ
------����������ŵ�ƽ������
------���飺���Ҫ��select������ֵ�ԭʼ�У�������group by�������
-----------�����group by������ֵ�ԭʼ�У����Բ���select�������
select e.deptno, avg(e.sal)
from emp e group by e.deptno;

-----��ѯ��ƽ�����ʸ���2000�Ĳ���
select e.deptno, avg(e.sal) asal
from emp e group by e.deptno
having avg(e.sal)>2000;

-----��ѯ���������Ź��ʸ���1000��Ա����ƽ������
select e.deptno, avg(e.sal)
from emp e
where e.sal > 1000
group by e.deptno;

-----�Ȳ�ѯ���������Ź��ʸ���1000��Ա����ƽ�����ʣ�
-----�ٲ�ѯ��ƽ�����ʸ���2000�Ĳ���
select e.deptno, avg(e.sal)
from emp e
where e.sal > 1000
group by e.deptno
having avg(e.sal)>2000;
-------where��������group by ֮ǰ���Է���ǰ�����ݽ��й���
-------having��������group by ֮�󣬶Է��������ݽ��й���





