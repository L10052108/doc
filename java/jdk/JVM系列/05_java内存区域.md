资料来源：<br/>
[JVM系列-5.java内存区域](https://juejin.cn/post/7327116051438256168)<br/>

# Java内存区域

![1.png](img/mezlSWLT2Bkvo9d.png)

Java虚拟机在运行Java程序过程中管理的内存区域，称之为**运行时数据区**。

《Java虚拟机规范》中规定了每一部分的作用。

![2.png](img/6SqhJxT5MmKiAZk.png)

**运行时数据区 – 应用场景**

![3.png](img/xE4hlmufeZ1TKgw.png)

![4.png](img/BQXE3PTvZwzubkq.png)

通过上面的问题，可以知道java内存模型实际上是非常重要的，那么如何去学习它呢？

![5.png](img/9YTHQXZ5cV6yOrF.png)

## 程序计数器

程序计数器（**Program Counter Register**）也叫**PC**寄存器，每个线程会通过程序计数器记录当前要执行的的字节码指令的地址。

![6.png](img/3jWDBEPgYbNkKci.png)

一个程序计数器的具体案例：

![7.png](img/qZ6rUy1oWS2P5a7.png)

在加载阶段，虚拟机将字节码文件中的指令读取到内存之后，会将原文件中的偏移量转换成内存地址。每一条字节码指令都会拥有一个内存地址。

![8.png](img/5AKbWmvBsTPdeZw.png)

在代码执行过程中，程序计数器会记录下一行字节码指令的地址。执行完当前指令之后，虚拟机的执行引擎根据程序计数器执行下一行指令。

![9.png](img/TvDzs9ioMAKPI1q.png)

![10.png](img/4Tqn2FPWLkA3zC7.png)

![11.png](img/FRHjPz6fxrnEGaB.png)

![12.png](img/xH1z2LeGXc5NnSD.png)

![13.png](img/gQswnL46ZGVzDmt.png)

![14.png](img/iychJ4zkNRpowY6.png)

![15.png](img/EYp8WA4SJgO6x5R.png)

程序计数器可以控制程序指令的进行，实现分支、跳转、异常等逻辑。

![16.png](img/NdSD2MOEqa8JQ1m.png)

在多线程执行情况下，Java虚拟机需要通过程序计数器记录CPU切换前解释执行到那一句指令并继续解释运行。

![17.png](img/G16Ofvw8xDUuHFW.png)

但是随之而来的有一个问题需要思考：

程序计数器在运行中会出现内存溢出吗？

**内存溢出**指的是程序在使用某一块内存区域时，存放的数据需要占用的内存 大小超过了虚拟机能提供的内存上限。

因为每个线程只存储一个固定长度的内存地址，**程序计数器是不会发生内存** **溢出的。**

**程序员无需对程序计数器做任何处理。**

## 栈

### JAVA虚拟机栈

**Java**虚拟机栈（**Java Virtual Machine Stack**）采用栈的数据结构来管理方法调用中的基本数据，先进后出（**First In Last Out**）,每一个方法的调用使用一个栈帧（**Stack Frame**）来保存。

![18.png](img/AB1fUNnswjYKFak.png)

通过Idea的debug工具查看栈帧的内容

![19.png](img/JQs9FqaXhHpdmCg.png)

Java虚拟机栈随着线程的创建而创建，而回收则会在线程的销毁时进行。由于方法可能会在不同线程中执行，每个线程都会包含一个自己的虚拟机栈。

![20.png](img/DnGQajNUd5sLRY1.png)

#### Java虚拟机栈 - 栈帧的组成

![21.png](img/YhX6a5pIJwm3QVA.png)

#### 局部变量表

局部变量表的作用是在方法执行过程中存放所有的局部变量。编译成字节码文件时就可以确定局部变量表的内容。

![22.png](img/5zeklrXIBW76sO1.png)

![23.png](img/qfN9m8lUBuOZ4FA.png)

![24.png](img/XauzEGNPjpUIrkL.png)

栈帧中的局部变量表是一个数组，数组中每一个位置称之为槽(slot) ，**long和double类型占用两个槽，其他类型占用一个槽。**

![25.png](img/ig4D8b7kfl3nVm5.png)

**实例方法**中的序号为0的位置存放的是this，指的是当前调用方法的对象，运行时会在内存中存放实例对象的地址。

![26.png](img/Yyh4ClKOjbtWVnL.png)

方法参数也会保存在局部变量表中，其顺序与方法中参数定义的顺序一致。

局部变量表保存的内容有：实例方法的this对象，方法的参数，方法体中声明的局部变量。

![27.png](img/7I4aKRQgj9vnepX.png)

然后来看一道思考题，以下代码的局部变量表中会占用几个槽？为什么？

![28.png](img/i8VvWmGaSJyhr5D.png)

为了节省空间，局部变量表中的槽是可以复用的，一旦某个局部变量不再生效，当前槽就可以再次被使用。

![29.png](img/BtjHqVz8Jndgf7T.png)

![30.png](img/wtUB7PaldFDIs8W.png)

![31.png](img/SjK7ABrJGvubtqx.png)

![32.png](img/1EpADfMHngrYuUK.png)

![33.png](img/qct6NGaTCUAewri.png)

![34.png](img/45JZTPbVazwXt91.png)

#### 操作数栈

操作数栈是栈帧中虚拟机在执行指令过程中用来存放中间数据的一块区域。他是一种栈式的数据结构，如果一条指令将一个值压入操作数栈，则后面的指令可以弹出并使用该值。

在**编译期**就可以确定操作数栈的最大深度，从而在执行时正确的分配内存大小。

![35.png](img/4xicO2rpkjYqz53.png)

![36.png](img/yj2WOeMLCauRlHs.png)

#### 帧数据

当前类的字节码指令引用了其他类的属性或者方法时，需要将符号引用（编号）转换成对应的运行时常量池中的内存地址。动态链接就保存了编号到运行时常量池的内存地址的映射关系。

![37.png](img/Fsrqm3Re6xgfzlv.png)

方法出口指的是方法在正确或者异常结束时，当前栈帧会被弹出，同时程序计数器应该指向上一个栈帧中的下一条指令的地址。所以在当前栈帧中，需要存储此方法出口的地址。

![38.png](img/ce2dAMbr8Gay1Jh.png)

**异常表存放的是代码中异常的处理信息，包含了异常捕获的生效范围以及异常发生后跳转到的字节码指令位置。**

![39.png](img/GnpkUMm25DB9FAE.png)

#### 栈内存溢出

java虚拟机栈是否会存在栈内存溢出呢？

Java虚拟机栈如果栈帧过多，占用内存超过栈内存可以分配的最大大小就会出现**内存溢出**。

Java虚拟机栈内存溢出时会出现**StackOverflowError**的错误

![40.png](img/8QXe9wmdARYW5nh.png)

如果我们不指定栈的大小，JVM 将创建一个具有**默认大小的栈**。大小取决于操作系统和计算机的体系结构。

![41.png](img/VZp7dGfveA3Lq4Q.png)

![42.png](img/Zxnk7iTJ895ulEF.png)

如果要来模拟一个栈内存溢出呢？

使用递归让方法调用自身，但是不设置退出条件。定义调用次数的变量，每一次调用让变量加1。查看错误发生时总调用的次数。

![43.png](img/fOKo4aCVLcHgnRM.png)

当然我们可以动态的设置虚拟机栈的大小

**要修改Java虚拟机栈的大小，可以使用虚拟机参数 -Xss 。**

语法：-Xss栈大小

单位：字节（默认，必须是 1024 的倍数）、k或者K(KB)、m或者M(MB)、g或者G(GB)

![44.png](img/6rZhDu5B9oE4USI.png)

**注意事项**

1、与-Xss类似，也可以使用 -XX:ThreadStackSize 调整标志来配置堆栈大小。 格式为： -XX:ThreadStackSize=1024

2、HotSpot JVM对栈大小的最大值和最小值有要求： 比如测试如下两个参数: -Xss1k -Xss1025m Windows（64位）下的JDK8测试最小值为180k，最大值为1024m。

3、局部变量过多、操作数栈深度过大也会影响栈内存的大小。

一般情况下，工作中即便使用了递归进行操作，栈的深度最多也只能到几百,不会出现栈的溢出。所以此参数可以手动指定为-Xss256k节省内存。

### 本地方法栈

Java虚拟机栈存储了Java方法调用时的栈帧，而本地方法栈存储的是native本地方法的栈帧。

在Hotspot虚拟机中，**Java虚拟机栈和本地方法栈实现上使用了同一个栈空间**。本地方法栈会在栈内存上生成一个栈帧，临时保存方法的参数同时方便出现异常时也把本地方法的栈信息打印出来。

![45.png](img/cPw1ZhIsYoVirHm.png)

## 堆

一般Java程序中堆内存是空间最大的一块内存区域。创建出来的对象都存在于堆上。

栈上的局部变量表中，可以存放堆上对象的引用。静态变量也可以存放堆对象的引用，通过静态变量就可以实现**对象在线程之间共享**。

![46.png](img/XurVqKiPSAJHmda.png)

**需求：**

通过new关键字不停创建对象，放入集合中，模拟堆内存的溢出，观察堆溢出之后的异常信息。

**现象：**

堆内存大小是有上限的，当对象一直向堆中放入对象达到上限之后，就会抛出**OutOfMemory**错误。

![47.png](img/koZXriSA8cPC6qQ.png)

堆空间有三个需要关注的值，used total max。

used指的是当前已使用的堆内存，total是java虚拟机已经分配的可用堆内存，max是java虚拟机可以分配的最大堆内存。

![48.png](img/apLStbqsMDnTGdw.png)

**arthas中堆内存相关的功能**

堆内存used total max三个值可以通过dashboard命令看到。

手动指定刷新频率（不指定默认5秒一次）：dashboard –i 刷新频率(毫秒)

![49.png](img/QXfHxWNUeO9wJCA.png)

按住ctrl + c 退出程序刷新

随着堆中的对象增多，当total可以使用的内存即将不足时，java虚拟机会继续分配内存给堆。

![50.png](img/cTZKndwe6o8tkQv.png)

![51.png](img/SFkviyMBO9qlaVc.png)

如果堆内存不足，java虚拟机就会不断的分配内存，total值会变大。total最多只能与max相等。

![52.png](img/NrMuzs3RiIFpkTQ.png)

但是存在一个问题，就是是不是当used = max = total的时候，堆内存就溢出了呢？

其实并不是，因为堆内存溢出的判断条件比较复杂，里面涉及到了垃圾回收机制。

如果不设置任何的虚拟机参数，max默认是系统内存的1/4，total默认是系统内存的1/64。**在实际应用中一般都需要设置total和max的值。**

**设置大小**

- 要修改堆的大小，可以使用虚拟机参数 –Xmx（max最大值）和-Xms (初始的total)。
- 语法：-Xmx值 -Xms值
- 单位：字节（默认，必须是 1024 的倍数）、k或者K(KB)、m或者M(MB)、g或者G(GB)
- 限制：Xmx必须大于 2 MB，Xms必须大于1MB

比如：

-Xms6291456

-Xms6144k

-Xms6m

-Xmx83886080

-Xmx81920k

-Xmx80m

还存在一个问题，就是为什么arthas中显示的heap堆大小与设置的值不一样呢？

arthas中的heap堆内存使用了**JMX技术**中内存获取方式，这种方式与垃圾回 收器有关，计算的是**可以分配对象的内存**，而不是整个内存。

![53.png](img/JsKqN7WCtX3TFh5.png)

Java服务端程序开发时，建议将-Xmx和-Xms设置为相同的值，这样在程序启动之后可使用的总内存就是最大内存，**而无需向java虚拟机再次申请，减少了申请并分配内存时间上的开销**，**同时也不会出现内存过剩之后堆收缩的情况**。

-Xmx具体设置的值与实际的应用程序运行环境有关

![54.png](img/25cAsXKTnIRfqB4.png)

## 方法区

方法区是存放基础信息的位置，线程共享，主要包含三部分内容：

![55.png](img/pTFmA7t3qIfYxjK.png)

方法区是用来存储每个类的基本信息（元信息），一般称之为InstanceKlass对象。在类的**加载阶段**完成。

![56.png](img/wQEPiSGe4rUhdIc.png)

方法区除了存储类的元信息之外，还存放了运行时常量池。常量池中存放的是字节码中的常量池内容。

字节码文件中通过编号查表的方式找到常量，这种常量池称为**静态常量池**。当常量池加载到内存中之后，可以通过内存地址快速的定位到常量池中的内容，这种常量池称为**运行时常量池**。

![57.png](img/ey9jJMEBdmGXSgF.png)

方法区是《Java虚拟机规范》中设计的虚拟概念，每款Java虚拟机在实现上都各不相同。Hotspot设计如下：

**JDK7及之前的版本**将方法区存放在**堆区域中的永久代空间**，堆的大小由虚拟机参数来控制。

**JDK8及之后的版本**将方法区存放在**元空间**中，元空间位于操作系统维护的直接内存中，默认情况下只要不超过操作系统承受的上限，可以一直分配。

![58.png](img/VX2ZQqMLh1U3TFG.png)

**arthas中查看方法区**

使用memory打印出内存情况，JDK7及之前的版本查看ps_perm_gen属性。

JDK8及之后的版本查看metaspace属性。

![59.png](img/y1XvOePEC58kQdu.png)

-1代表不设上限，前提是不超过操作系统的上限。

### 实验-模拟方法区的溢出

通过ByteBuddy框架，动态生成字节码数据，加载到内存中。通过死循环不停地加载到方法区，观察方法区是否会出现内存溢出的情况。分别在JDK7和JDK8上运行上述代码。

**ByteBuddy框架的基本使用方法**

![60.png](img/OIrwgS12VWoGsZA.png)

核心代码为：

![61.png](img/wLat6157e2FVKiu.png)

实验发现，JDK7上运行大概十几万次，就出现了错误。在JDK8上运行百万次，**程序都没有出现任何错误，但是内存会直线升高**，这样有可能影响其他功能的正常使用。这说明JDK7和JDK8在方法区的存放上，采用了不同的设计。

JDK7将方法区存放在**堆区域中的永久代空间**，堆的大小由虚拟机参数-XX:MaxPermSize=值来控制。

JDK8将方法区存放在**元空间**中，元空间位于操作系统维护的直接内存中，默认情况下只要不超过操作系统承受的上限，可以一直分配。可以使用**-XX:MaxMetaspaceSize=值**将元空间最大大小进行限制。

![62.png](img/gCvRO36M8iLT4pt.png)

### 字符串常量池

方法区中除了类的元信息、运行时常量池之外，还有一块区域叫字符串常量池(**StringTable**)。

字符串常量池存储在代码中定义的常量字符串内容。比如“123” 这个123就会被放入字符串常量池。

![63.png](img/WpBVG4eq3HAhtbK.png)

字符串常量池和运行时常量池有什么关系？

早期设计时，字符串常量池是属于运行时常量池的一部分，他们存储的位置也是一致的。后续做出了调整，将字符串常量池和运行时常量池做了拆分。

![64.png](img/39wIRWms4PGhnZq.png)

### StringTable练习题

**需求：**

通过字节码指令分析如下代码的运行结果？

![65.png](img/pdLUl5CVFbBkQ7E.png)

![66.png](img/8CScejdPsDuZpny.png)

最终是不想相等的，因为c是指向了字符串常量池中的"12"，而d是指向了堆内存中的"12"。之所以是这样是因为变量连接是使用StringBuilder的。

再看另一个案例。

![67.png](img/VrXZeFqBNaYfnkz.png)

其是常量，编译阶段直接连接，所以返回true。

## 直接内存

直接内存（Direct Memory）并不在《Java虚拟机规范》中存在，所以并不属于Java运行时的内存区域。 在 JDK 1.4 中引入了 NIO 机制，使用了直接内存，主要为了解决以下两个问题:

1、Java堆中的对象如果不再使用要回收，回收时会影响对象的创建和使用。

2、IO操作比如读文件，需要先把文件读入直接内存（缓冲区）再把数据复制到Java堆中。

现在直接放入直接内存即可，同时Java堆上维护直接内存的引用，减少了数据复制的开销。写文件也是类似的思路。

![68.png](img/eLH1mifKulnBgzV.png)

**要创建直接内存上的数据，可以使用ByteBuffer。**

语法： ByteBuffer directBuffer = ByteBuffer.allocateDirect(size);

注意事项： arthas的memory命令可以查看直接内存大小，属性名direct。

![69.png](img/nbwGfK7WTJldFrg.png)

如果需要手动调整直接内存的大小，可以使用-XX:MaxDirectMemorySize=大小

单位k或K表示千字节，m或M表示兆字节，g或G表示千兆字节。默认不设置该参数情况下，JVM 自动选择 最大分配的大小。

以下示例以不同的单位说明如何将 直接内存大小设置为 1024 KB：

-XX:MaxDirectMemorySize=1m

-XX:MaxDirectMemorySize=1024k

-XX:MaxDirectMemorySize=1048576



作者：爱吃芝士的土豆倪<br/>
链接：https://juejin.cn/post/7327116051438256168<br/>
来源：稀土掘金<br/>
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。<br/>