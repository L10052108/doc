declare
  ena emp.ename%type;---引用型变量
  emprow emp%rowtype;---记录型变量
begin

end;

--------if
-----输入小于18的数字，输出未成年，输入大于18小于40的数字，输出中年人，输入大于40的数字，输出老年人
declare
  i number(3) := &iii;----用&表示输入一个值
begin
  if i<18 then
     dbms_output.put_line('未成年');
  elsif i<40 then
     dbms_output.put_line('中年人');
  else
     dbms_output.put_line('老年人');
  end if;
end;

-------loop
-----输出1到10的十个数字
----while循环
declare
  i number := 1;
begin
  while i<11 loop
    dbms_output.put_line(i);
    i := i+1;
  end loop;
end;
----exit循环
declare
  i number := 1;
begin
  loop
    exit when i>10;
    dbms_output.put_line(i);
    i := i+1;
  end loop;
end;

----for循环
declare

begin
  for i in 1..10 loop
    dbms_output.put_line(i);
  end loop;
end;


-----游标
---输出emp表中员工姓名和工作

declare
  cursor c1 is select * from emp;----定义一个游标类型的C1，并且给其赋值
  emprow emp%rowtype;----用户循环存放c1中的对象
begin
  open c1;---打开游标
     loop  
         fetch c1 into emprow;---用fetch循环取出游标中的对象，放入emprow中
         exit when c1%notfound;----退出条件
         dbms_output.put_line(emprow.ename || ':' || emprow.job);
     end loop;
  close c1;---关闭游标
end;


--------为指定部门涨工资,涨前的工资和涨后的工资输出出来
declare
  cursor c2(dno emp.deptno%type) is select empno from emp where deptno = dno;
  eno emp.empno%type;
  sa emp.sal%type;
begin
  open c2(10);
     loop
        fetch c2 into eno;
        exit when c2%notfound;
        select sal into sa from emp where empno = eno;
        dbms_output.put_line(sa);
        update emp set sal=sal+100 where empno = eno;
        commit;
        select sal into sa from emp where empno = eno;
        dbms_output.put_line(sa);
     end loop;
  close c2;
end;
------例外
declare
  i number(1);
begin
  i := 1/0;
exception
  when zero_divide then
    dbms_output.put_line('不能被0除');
  when others then 
    dbms_output.put_line('系统异常');
end;

-----自定义例外
----如果按照部门取不到员工，输出该部门没有人。
declare
    cursor c3(dno emp.deptno%type) is select * from emp where deptno = dno;
    emprow emp%rowtype;
    no_data_exception exception;
begin
    open c3(10);
         fetch c3 into emprow;
         if c3%notfound then
            raise no_data_exception;
         end if;
    close c3;
exception
    when no_data_exception then
      dbms_output.put_line('该部门没有人');
end;

------存储过程:过程的参数类型，不能带长度，如果用引用变量，长度自动过滤
-----给指定员工涨工资
create or replace procedure p1(eno emp.empno%type)
is---声明变量
  sa emp.sal%type;
begin
  select sal into sa from emp where empno = eno;
  dbms_output.put_line(sa);
  update emp set sal=sal+100 where empno = eno;
  commit;
  select sal into sa from emp where empno = eno;
  dbms_output.put_line(sa);
end;

--调用
declare

begin
  p1(7788);
end;

------使用存储函数查询指定员工的年薪:return后面的类型不能带长度
create or replace function f_yearsal(eno emp.empno%type) return number
is
   yearsal number(10);     
begin
   select sal*12+nvl(comm, 0) into yearsal from emp where empno = eno;
   return yearsal;
end;

---调用:存储函数，有返回值必须接收，否则报错
declare
   yearsal number(10);
begin
   yearsal := f_yearsal(7654);
   dbms_output.put_line(yearsal);
end;

------用存储过程算年薪
create or replace procedure p_yearsal(eno emp.empno%type, yearsal out number)
is
       s emp.sal%type;
       c emp.comm%type;
begin
       select sal, nvl(comm, 0) into s, c from emp where empno = eno;
       yearsal := s*12+c;
end;

-----调用
declare
  yearsal number(10);
begin
  p_yearsal(7654, yearsal);
  dbms_output.put_line(yearsal);
end;

---存储过程和存储函数的区别
----1，语法区别：存储函数比存储过程多了两个return
----2，存储函数本身有返回值，存储过程用out参数接收返回值
-----in,out参数类型的区别，如果用到into，或者:=等赋值操作的时候，参数类型必须为out
-----inout参数类型，技能当输入又能当输出参数，但是基本不用，因为inout类型消耗资源多。
----3，由于存储函数有返回值，可以通过这个特性来自定义函数
----通过部门编号查询部门名称
create or replace function f_dname(dno emp.deptno%type) return dept.dname%type
is
   dna dept.dname%type;
begin
   select dname into dna from dept where deptno = dno;
   return dna;
end;

------查询出员工的姓名和员工的部门名称
select e.ename, d.dname
from emp e,dept d
where e.deptno = d.deptno;
---用自定义函数来实现查询出员工的姓名和员工的部门名称
select e.ename, f_dname(e.deptno) from emp e;


-------用存储过程，输出指定部门的员工信息
----cd out sys_refcursor定义一个游标类型的输出参数
create or replace procedure pd(dno emp.deptno%type, cd out sys_refcursor)
is

begin
  open cd for select * from emp where deptno = dno;---给已经定义好的游标类型赋值
end;

------便利部门中的员工信息
declare
  cd sys_refcursor;--定义一个游标类型的参数
  emprow emp%rowtype;
begin
  pd(10, cd);
     loop
       fetch cd into emprow;
       exit when cd%notfound;
       dbms_output.put_line(emprow.ename || ':' || emprow.job);
     end loop;
  close cd;
end;


------oracle10g用ojdbc14驱动包
------oracle11g用ojdbc6驱动包
-------触发器
----插入一行数据，输出一个新员工入职
create or replace trigger t1
after
insert
on person
declare

begin
  dbms_output.put_line('一个新员工入职');
end;


select * from person;
truncate table person;
----触发t1
insert into person values (1, 'a');
commit;

---不能在休息时间办理入职
---raise_application_error(-20001~-20999, '错误提示');
create or replace trigger t2
before
insert
on person
declare
  d varchar2(10);
begin
  select to_char(sysdate, 'day') into d from dual;
  if trim(d) in ('sunday') then
    raise_application_error(-20001, '不能在休息时间办理入职');
  end if;
end;

----触发t2
insert into person values (3, 'a');
commit;

-------行级触发器
---不能给员工降薪
create or replace trigger t3
before
update
on emp
for each row
declare

begin
  if :new.sal < :old.sal then
     raise_application_error(-20002, '不能给员工降薪');
  end if;
end;

---触发T3
update emp set sal=sal-1 where empno = 7788;
commit;


-----用触发器自动给主键赋值
---思路：在即将插入数据的时候，拿到这条数据，并且给其主键赋值
create or replace trigger t4
before
insert
on person
for each row
declare

begin
  select s_person.nextval into :new.pid from dual;
end;

----用自动给主键赋值的触发器，来插入数据
insert into person values (null, 'a');
commit;
insert into person (pname) values ('a');
commit;


select * from person;






















