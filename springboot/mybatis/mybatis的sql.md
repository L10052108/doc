资料来源：

[Mybatis union 循环](https://blog.csdn.net/sinat_36454672/article/details/109287098)

[union all和union的区别用法](https://xue.baidu.com/okam/pages/strategy-tp/index?source=aladdin_36402&sa=aladdin_36402&strategyId=129466835353908)



### mybatis union

~~~~sql
	<foreach collection="nameList" item="name" separator="union">
		select id  from table where name = #{name}
	</foreach>

   List<Object> getList(@Param("nameList")String[] nameList);  
~~~~
union all和union的区别：取结果的交集，union对两个结果集进行并集操作，不包括重复行，相当于distinct，同时进行默认规则的排序;union all：对两个结果集进行并集操作，包括重复行，即所有的结果全部显示，不管是不是重复。

Union因为要进行重复值扫描，所以效率低。如果合并没有刻意要删除重复行，那么就使用Union All。

两个要联合的SQL语句 字段个数必须一样，而且字段类型要“相容”(一致);

如果我们需要将两个select语句的结果作为一个整体显示出来，我们就需要用到union或者union all关键字。union(或称为联合)的作用是将多个结果合并在一起显示出来。

union和union all的区别是,union会自动压缩多个结果集合中的重复结果，而union all则将所有的结果全部显示出来，不管是不是重复。

Union：对两个结果集进行并集操作，不包括重复行，同时进行默认规则的排序;

Union All：对两个结果集进行并集操作，包括重复行，不进行排序;

Intersect：对两个结果集进行交集操作，不包括重复行，同时进行默认规则的排序;

Minus：对两个结果集进行差操作，不包括重复行，同时进行默认规则的排序。