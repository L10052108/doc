declare
  ena emp.ename%type;---�����ͱ���
  emprow emp%rowtype;---��¼�ͱ���
begin

end;

--------if
-----����С��18�����֣����δ���꣬�������18С��40�����֣���������ˣ��������40�����֣����������
declare
  i number(3) := &iii;----��&��ʾ����һ��ֵ
begin
  if i<18 then
     dbms_output.put_line('δ����');
  elsif i<40 then
     dbms_output.put_line('������');
  else
     dbms_output.put_line('������');
  end if;
end;

-------loop
-----���1��10��ʮ������
----whileѭ��
declare
  i number := 1;
begin
  while i<11 loop
    dbms_output.put_line(i);
    i := i+1;
  end loop;
end;
----exitѭ��
declare
  i number := 1;
begin
  loop
    exit when i>10;
    dbms_output.put_line(i);
    i := i+1;
  end loop;
end;

----forѭ��
declare

begin
  for i in 1..10 loop
    dbms_output.put_line(i);
  end loop;
end;


-----�α�
---���emp����Ա�������͹���

declare
  cursor c1 is select * from emp;----����һ���α����͵�C1�����Ҹ��丳ֵ
  emprow emp%rowtype;----�û�ѭ�����c1�еĶ���
begin
  open c1;---���α�
     loop  
         fetch c1 into emprow;---��fetchѭ��ȡ���α��еĶ��󣬷���emprow��
         exit when c1%notfound;----�˳�����
         dbms_output.put_line(emprow.ename || ':' || emprow.job);
     end loop;
  close c1;---�ر��α�
end;


--------Ϊָ�������ǹ���,��ǰ�Ĺ��ʺ��Ǻ�Ĺ����������
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
------����
declare
  i number(1);
begin
  i := 1/0;
exception
  when zero_divide then
    dbms_output.put_line('���ܱ�0��');
  when others then 
    dbms_output.put_line('ϵͳ�쳣');
end;

-----�Զ�������
----������ղ���ȡ����Ա��������ò���û���ˡ�
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
      dbms_output.put_line('�ò���û����');
end;

------�洢����:���̵Ĳ������ͣ����ܴ����ȣ���������ñ����������Զ�����
-----��ָ��Ա���ǹ���
create or replace procedure p1(eno emp.empno%type)
is---��������
  sa emp.sal%type;
begin
  select sal into sa from emp where empno = eno;
  dbms_output.put_line(sa);
  update emp set sal=sal+100 where empno = eno;
  commit;
  select sal into sa from emp where empno = eno;
  dbms_output.put_line(sa);
end;

--����
declare

begin
  p1(7788);
end;

------ʹ�ô洢������ѯָ��Ա������н:return��������Ͳ��ܴ�����
create or replace function f_yearsal(eno emp.empno%type) return number
is
   yearsal number(10);     
begin
   select sal*12+nvl(comm, 0) into yearsal from emp where empno = eno;
   return yearsal;
end;

---����:�洢�������з���ֵ������գ����򱨴�
declare
   yearsal number(10);
begin
   yearsal := f_yearsal(7654);
   dbms_output.put_line(yearsal);
end;

------�ô洢��������н
create or replace procedure p_yearsal(eno emp.empno%type, yearsal out number)
is
       s emp.sal%type;
       c emp.comm%type;
begin
       select sal, nvl(comm, 0) into s, c from emp where empno = eno;
       yearsal := s*12+c;
end;

-----����
declare
  yearsal number(10);
begin
  p_yearsal(7654, yearsal);
  dbms_output.put_line(yearsal);
end;

---�洢���̺ʹ洢����������
----1���﷨���𣺴洢�����ȴ洢���̶�������return
----2���洢���������з���ֵ���洢������out�������շ���ֵ
-----in,out�������͵���������õ�into������:=�ȸ�ֵ������ʱ�򣬲������ͱ���Ϊout
-----inout�������ͣ����ܵ��������ܵ�������������ǻ������ã���Ϊinout����������Դ�ࡣ
----3�����ڴ洢�����з���ֵ������ͨ������������Զ��庯��
----ͨ�����ű�Ų�ѯ��������
create or replace function f_dname(dno emp.deptno%type) return dept.dname%type
is
   dna dept.dname%type;
begin
   select dname into dna from dept where deptno = dno;
   return dna;
end;

------��ѯ��Ա����������Ա���Ĳ�������
select e.ename, d.dname
from emp e,dept d
where e.deptno = d.deptno;
---���Զ��庯����ʵ�ֲ�ѯ��Ա����������Ա���Ĳ�������
select e.ename, f_dname(e.deptno) from emp e;


-------�ô洢���̣����ָ�����ŵ�Ա����Ϣ
----cd out sys_refcursor����һ���α����͵��������
create or replace procedure pd(dno emp.deptno%type, cd out sys_refcursor)
is

begin
  open cd for select * from emp where deptno = dno;---���Ѿ�����õ��α����͸�ֵ
end;

------���������е�Ա����Ϣ
declare
  cd sys_refcursor;--����һ���α����͵Ĳ���
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


------oracle10g��ojdbc14������
------oracle11g��ojdbc6������
-------������
----����һ�����ݣ����һ����Ա����ְ
create or replace trigger t1
after
insert
on person
declare

begin
  dbms_output.put_line('һ����Ա����ְ');
end;


select * from person;
truncate table person;
----����t1
insert into person values (1, 'a');
commit;

---��������Ϣʱ�������ְ
---raise_application_error(-20001~-20999, '������ʾ');
create or replace trigger t2
before
insert
on person
declare
  d varchar2(10);
begin
  select to_char(sysdate, 'day') into d from dual;
  if trim(d) in ('sunday') then
    raise_application_error(-20001, '��������Ϣʱ�������ְ');
  end if;
end;

----����t2
insert into person values (3, 'a');
commit;

-------�м�������
---���ܸ�Ա����н
create or replace trigger t3
before
update
on emp
for each row
declare

begin
  if :new.sal < :old.sal then
     raise_application_error(-20002, '���ܸ�Ա����н');
  end if;
end;

---����T3
update emp set sal=sal-1 where empno = 7788;
commit;


-----�ô������Զ���������ֵ
---˼·���ڼ����������ݵ�ʱ���õ��������ݣ����Ҹ���������ֵ
create or replace trigger t4
before
insert
on person
for each row
declare

begin
  select s_person.nextval into :new.pid from dual;
end;

----���Զ���������ֵ�Ĵ�����������������
insert into person values (null, 'a');
commit;
insert into person (pname) values ('a');
commit;


select * from person;






















