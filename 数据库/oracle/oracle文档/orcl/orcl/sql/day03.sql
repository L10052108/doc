----��ѯ��ǰ�û���ɫRESOURCE,CONNECT����ɫ���ã���Ӧ��Ȩ�޲�ͬ��
select * from role_sys_privs;
------dba��oracle���ݿ������Ȩ�޵Ľ�ɫ
------�л���system�û��£���������ռ�
create tablespace itheima
datafile 'C:\itheima.dbf'
size 100m
autoextend on
next 10m;

----ɾ����ռ�
drop tablespace itheima;
----ɾ����ռ䣬һ��ɾ��dbf�ļ�
drop tablespace itheima including contents and datafiles;

----�����û�
create user itheima
identified by itheima
default tablespace itheima;

----�û���Ȩ
grant dba to itheima;
-----�л���¼��itheima

------����һ��person��
create table person(
       pid number(10),
       pname varchar2(20)
);
------------�޸ı�ṹ
-----���һ��
alter table person add gender char(1);
-----�޸�һ�е�����
alter table person modify gender number(1);
-----�������޸���
alter table person rename column gender to sex;
-----ɾ��һ��
alter table person drop column sex;


















