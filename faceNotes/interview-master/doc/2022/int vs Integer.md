  
> 重要说明：本篇为博主《面试题精选-基础篇》系列中的一篇，查看系列面试文章**请关注我**。
> Gitee 开源地址：[https://gitee.com/mydb/interview](https://gitee.com/mydb/interview)



Java 是一种强数据类型的语言，因此所有的属性必须有一个数据类型。就像麦德龙超市一样，想要进去购物，先要有一个会员卡才行（刷卡入内）。
​

> PS：Java 10 有了局部变量类型推导，可以使用 var 来替代某个具体的数据类型，但在字节码阶段，Java 的变量仍有着明确的数据类型，且局部变量类型推导有着很多限制和不完善之处，也不是目前主流的应用版本，所以这里不做深入讨论。

​

回到主题，要理解 int 和 Integer 的区别，要先从 Java 的基础数据类型说起。
## 基本数据类型
在 Java 中，一共有 8 种基本类型（primitive type），其中有 4 种整型、2 种浮点类型、1 种用于表示 Unicode 编码的字符类型 char 和 1 种用于表示真假值的 boolean 类型。

- 4 种整型：int、short、long、byte
- 2 种浮点类型：float、double
- 字符类型：char
- 真假类型：boolean

基本数据类型是指不可再分的原子数据类型，内存中直接存储此类型的值，通过内存地址即可直接访问到数据，并且此内存区域只能存放这种类型的值，**int 就是 Java 中一种常用的基础数据类型**。
## 包装类及其作用
因为 Java 的设计理念是一切皆是对象，在很多情况下，需要以对象的形式操作，比如 hashCode() 获取哈希值，或者 getClass() 获取类等。
​

#### 包装类的作用
在 Java 中每个基本数据类型都对应了一个包装类，而 **int 对应的包装类就是 Integer**，**包装类的存在解决了基本数据类型无法做到的事情泛型类型参数、序列化、类型转换、高频区间数据缓存等问题**。
​


| **基础类型** | **包装类型** |
| --- | --- |
| int | Integer |
| short | Short |
| byte | Byte |
| long | Long |
| float | Float |
| double | Double |
| char | Character |
| boolean | Boolean |

## int 和 Integer 的区别
int 和 Integer的区别主要体现在以下几个方面：

1. 数据类型不同：int 是基础数据类型，而 Integer 是包装数据类型；
1. 默认值不同：int 的默认值是 0，而 Integer 的默认值是 null；
1. 内存中存储的方式不同：int 在内存中直接存储的是数据值，而 Integer 实际存储的是对象引用，当 new 一个 Integer 时实际上是生成一个指针指向此对象；
1. 实例化方式不同：Integer 必须实例化才可以使用，而 int 不需要；
1. 变量的比较方式不同：int 可以使用 == 来对比两个变量是否相等，而 Integer 一定要使用 equals 来比较两个变量是否相等。
## 总结
Integer 是 int 的包装类，它们的区别主要体现在 5 个方面：数据类型不同、默认值不同、内存中存储的方式不同、实例化方式不同以及变量的比较方式不同。包装类的存在解决了基本数据类型无法做到的事情泛型类型参数、序列化、类型转换、高频区间数据缓存等问题。
​

#### 参考 & 鸣谢
《码出高效：Java开发手册》
​

> 关注公众号：Java面试真题解析，查看更多 Java 面试题。
