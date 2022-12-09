----查询当前用户角色RESOURCE,CONNECT【角色不用，对应的权限不同】
select * from role_sys_privs;
------dba是oracle数据库中最高权限的角色
------切换到system用户下，来创建表空间
create tablespace itheima
datafile 'C:\itheima.dbf'
size 100m
autoextend on
next 10m;

----删除表空间
drop tablespace itheima;
----删除表空间，一起删除dbf文件
drop tablespace itheima including contents and datafiles;

----创建用户
create user itheima
identified by itheima
default tablespace itheima;

----用户授权
grant dba to itheima;
-----切换登录到itheima

------创建一个person表
create table person(
       pid number(10),
       pname varchar2(20)
);
------------修改表结构
-----添加一列
alter table person add gender char(1);
-----修改一列的类型
alter table person modify gender number(1);
-----把列名修改了
alter table person rename column gender to sex;
-----删除一列
alter table person drop column sex;


















