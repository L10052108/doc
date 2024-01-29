资料来源：<br/>
[JVM系列-6.java垃圾回收](https://juejin.cn/post/7327642905244893219)<br/>

# 垃圾回收

在C/C++这类没有自动垃圾回收机制的语言中，一个对象如果不再使用，需要手动释放，否则就会出现**内存泄漏**。我们称这种释放对象的过程为垃圾回收，而需要程序员编写代码进行回收的方式为**手动回收**。

**内存泄漏**指的是不再使用的对象在系统中未被回收，内存泄漏的积累可能会导致**内存溢出**。

![1.png](img/Yr6pdnD318kXhfK.png)

Java中为了简化对象的释放，引入了自动的**垃圾回收（Garbage Collection简称GC）\**机制。通过垃圾回收器来对不再使用的对象完成自动的回收，垃圾回收器主要负责对\**堆上**的内存进行回收。其他很多现代语言比如C#、Python、Go都拥有自己的垃圾回收器。

![2.png](img/a9ULXSNPzcH5bsY.png)

**垃圾回收器的对比**

![3.png](img/hL24RClcgkMqn1r.png)

**应用场景**

![4.png](img/iUGh6N8snHfI1YD.png)

## 方法区的回收

Java虚拟机在运行Java程序过程中管理的内存区域，称之为**运行时数据区**。

《Java虚拟机规范》中规定了每一部分的作用

![5.png](img/8XtPLNYpcoB6yMf.png)

线程不共享的部分，都是**伴随着线程的创建而创建，线程的销毁而销毁**。而方法的栈帧在执行完方法之后就会自动弹出栈并释放掉对应的内存。

![6.png](img/n6kIgO1rYpEGT7W.png)

方法区中能回收的内容主要就是不再使用的类。判定一个类可以被卸载。需要同时满足下面三个条件：

**此类所有实例对象都已经被回收，在堆中不存在任何该类的实例对象以及子类对象。**

![7.png](img/JFKuo69Ljp2eQAl.png)

**加载该类的类加载器已经被回收。**

![8.png](img/WODToGNMHpuVSU4.png)

**该类对应的 java.lang.Class 对象没有在任何地方被引用。**

![9.png](img/JzgkLois5cVjQGy.png)

### 手动触发回收

如果需要手动触发垃圾回收，可以调用System.gc()方法。

语法： System.gc()

但是调用System.gc()方法并不一定会立即回收垃圾，仅仅是向Java虚拟机发送一个垃圾回收的请求，具体是否需要执行垃圾回收Java虚拟机会自行判断。

![10.png](img/e3vSFayXOIrslmR.png)

现在这段代码，如果不打开注释的话，可以触发gc上的回收，因为我们使用的是while，当我们的循环进入到下一轮的时候，上一轮创建的三个对象就已经没有人在使用了，那么此时java虚拟机就会把这三个对象回收掉。所以没有必要添加 o = null。

但是如果把 objs.add(o) 注释打开，那么就不会触发gc。

其他 方法注释打开也一样，相当于破坏了三个必要条件。

**当然在开发中此类场景一般很少出现，主要在如 OSGi、JSP 的热部署等应用场景中。每个jsp文件对应一个唯一的类加载器，当一个jsp文件修改了，就直接卸载这个jsp类加载器。重新创建类加载器，重新加载jsp文件。**

## 堆内存的回收

一个很关键的问题，如何判断堆上的对象可以被回收？

Java中的对象是否能被回收，是根据对象是否被**引用**来决定的。如果对象被引用了，说明该对象还在使用，不允许被回收。

![11.png](img/kels3rD4z2u8jLX.png)

demo = null导致堆上的引用失效，所以堆上的Demo实例对象就可以被垃圾回收。

上述的案例比较简单，但是如果对象之间互相包含着引用呢？比如这样。

![12.png](img/rIHuztn9Mk6LqNU.png)

只有无法通过引用获取到对象时，该对象才能被回收。

图中A的实例对象要回收，有两个引用要去除：

1.栈中a1变量到对象的引用

2.B对象到A对象的引用

![13.png](img/cSnRVZGrD3TAvLU.png)

如果在main方法中最后执行 a1 = null ，b1 = null，是否能回收A和B对象呢？ 可以回收，方法中已经没有办法使用引用去访问A和B对象了。

![14.png](img/SlY73PMFDW6ZvnU.png)

常见的有两种判断方法：引用计数法和可达性分析法。

引用计数法会为每个对象维护一个引用计数器，当对象被引用时加1，取消引用时减1。

![15.png](img/MrglnLXAvJbsQ8f.png)

引用计数法的优点是实现简单，C++中的智能指针就采用了引用计数法，但是它也存在缺点，主要有两点：

1.每次引用和取消引用都需要维护计数器，对系统性能会有一定的影响。

2.存在循环引用问题，所谓循环引用就是当A引用B，B同时引用A时会出现对象无法回收的问题。

![16.png](img/9r2OW6bn1HmRq5S.png)

**如果想要查看垃圾回收的信息，可以使用-verbose:gc参数。**

语法： **-verbose:gc**

![17.png](img/PuAUGd45hbDiXaM.png)

运行之后分析，java虚拟机在上述代码中其实是没有出现内存泄漏的，也就是有效地进行了垃圾回收。

java虚拟机在实现对象的引用判断的时候，有两种可能性，第一种使用了引用计数法并且用一种特殊的方式解决掉了循环引用的问题。第二种java虚拟机根本就没有使用引用计数法。

Java使用的是**可达性分析算法**来判断对象是否可以被回收。可达性分析将对象分为两类：垃圾回收的根对象（GC Root）和普通对象，对象与对象之间存在引用关系。

**下图中A到B再到C和D，形成了一个引用链，可达性分析算法指的是如果从某个到GC Root对象是可达的，对象就不可被回收。**

![18.png](img/g7Eh9b6FWpfsPjO.png)

那么在可达性分析算法中，那些对象被称之为GC ROOT对象呢？

**线程Thread对象**

![19.png](img/2lB7ex1c35iQusa.png)

此时如果设置了a1 = null b1 = null，此时就相当于将堆内存上的引用去掉了，此时堆内存就到不到了GC Root了，所以会被回收。

**系统类加载器加载的java.lang.Class对象，引用类中的静态变量。**

![20.png](img/YKVfjbTe5sSitqJ.png)

**监视器对象，用来保存同步锁synchronized关键字持有的对象。**

![21.png](img/lQoxu2Nd5AqcWh3.png)

**本地方法调用时使用的全局对象。**

### 查看GC Root

通过arthas和eclipse Memory Analyzer (MAT) 工具可以查看GC Root，MAT工具是eclipse推出的Java堆内存检测工具。具体操作步骤如下：

1、使用arthas的heapdump命令将堆内存快照保存到本地磁盘中。

2、使用MAT工具打开堆内存快照文件。

3、选择GC Roots功能查看所有的GC Root。

![22.png](img/ow5OFTpSARLUMdx.png)

### 五种引用状态

#### 强引用

可达性算法中描述的对象引用，一般指的是强引用，即是GCRoot对象对普通对象有引用关系，只要这层关系存在，普通对象就不会被回收。

#### 软引用

软引用相对于强引用是一种比较弱的引用关系，如果一个对象只有软引用关联到它，**当程序内存不足时，就会将软引用中的数据进行回收。**

在JDK 1.2版之后提供了SoftReference类来实现软引用，软引用常用于缓存中。

在代码中软引用的使用流程：

1.将对象使用软引用包装起来，**new SoftReference<对象类型>(对象)。**

2.内存不足时，虚拟机尝试进行垃圾回收。

3.如果垃圾回收仍不能解决内存不足的问题，回收软引用中的对象。

4.如果依然内存不足，抛出OutOfMemory异常。

![23.png](img/WQClI4mPUJGdM2D.png)

在java中有一款比较有名的缓存框架Caffeine，在创建缓存对象的时候，可以将value值设置成soft也就是软引用。

```java
java
复制代码Cache<Object,Object> build = Caffeine.newBuilder().softValues().build();
```

进入softvalues方法里面，就会看到注释，调用这个，创建的对象的值会使用SoftReference来封装，这样当你的内存不足的时候，就会释放掉。同时如果不使用这个方法，默认是强引用。

通过这个方法可以看到，在缓存中，这个方法的使用还是比较普遍的。

```java
java复制代码byte[] bytes = new byte[1024 * 1024 * 100];

SoftReference<byte[]> softReference = new SoftReference<byte[]>(bytes);

bytes = null;

System.out.println(softReference.get);

byte[] bytes2 = new byte[1024 * 1024 * 100];

System.out.println(softReference.get);
```

然后将堆内存设置为200M,其中实际能用的只有100多M，观察输出就可以看到，实际上软引用是被回收了的。原因就是因为内存不够被回收了。而如果将堆内存设置为400M，那么软引用是不会被回收的。

软引用中的对象如果在内存不足时回收，SoftReference对象本身也需要被回收。如何知道哪些SoftReference对象需要回收呢？

SoftReference提供了一套队列机制：

1、软引用创建时，通过构造器传入引用队列

![24.png](img/jzcMNK5tdHwIRDG.png)

2、在软引用中包含的对象被回收时，该软引用对象会被放入引用队列

![25.png](img/FauETylcPs2LUeC.png)

3、通过代码遍历引用队列，将SoftReference的强引用删除

代码如下：

![26.png](img/GiVhwgFj5n9JzpX.png)

假如说堆内存设置为200M，那么输出为9。

##### 软引用的使用场景-缓存

软引用也可以使用继承自SoftReference类的方式来实现，StudentRef类就是一个软引用对象。通过构造器传入软引用包含的对象，以及引用队列。

![27.png](img/IxFzN1XowUfmpl4.png)

使用软引用实现学生数据的缓存：

![28.png](img/d7XqGtEsg56ux8r.png)

实现代码如下：

```java
package chapter04.soft;

import java.lang.ref.ReferenceQueue;
import java.lang.ref.SoftReference;
import java.util.HashMap;
import java.util.Map;
/**
 * 软引用案例4 - 学生信息的缓存
 */
public class StudentCache {

    private static StudentCache cache = new StudentCache();

    public static void main(String[] args) {
        for (int i = 0; ; i++) {
            StudentCache.getInstance().cacheStudent(new Student(i, String.valueOf(i)));
        }
    }

    private Map<Integer, StudentRef> StudentRefs;// 用于Cache内容的存储
    private ReferenceQueue<Student> q;// 垃圾Reference的队列

    // 继承SoftReference，使得每一个实例都具有可识别的标识。
    // 并且该标识与其在HashMap内的key相同。
    private class StudentRef extends SoftReference<Student> {
        private Integer _key = null;

        public StudentRef(Student em, ReferenceQueue<Student> q) {
            super(em, q);
            _key = em.getId();
        }
    }

    // 构建一个缓存器实例
    private StudentCache() {
        StudentRefs = new HashMap<Integer, StudentRef>();
        q = new ReferenceQueue<Student>();
    }

    // 取得缓存器实例
    public static StudentCache getInstance() {
        return cache;
    }

    // 以软引用的方式对一个Student对象的实例进行引用并保存该引用
    private void cacheStudent(Student em) {
        cleanCache();// 清除垃圾引用
        StudentRef ref = new StudentRef(em, q);
        StudentRefs.put(em.getId(), ref);
        System.out.println(StudentRefs.size());
    }

    // 依据所指定的ID号，重新获取相应Student对象的实例
    public Student getStudent(Integer id) {
        Student em = null;
// 缓存中是否有该Student实例的软引用，如果有，从软引用中取得。
        if (StudentRefs.containsKey(id)) {
            StudentRef ref = StudentRefs.get(id);
            em = ref.get();
        }
// 如果没有软引用，或者从软引用中得到的实例是null，重新构建一个实例，
// 并保存对这个新建实例的软引用
        if (em == null) {
            em = new Student(id, String.valueOf(id));
            System.out.println("Retrieve From StudentInfoCenter. ID=" + id);
            this.cacheStudent(em);
        }
        return em;
    }

    // 清除那些所软引用的Student对象已经被回收的StudentRef对象
    private void cleanCache() {
        StudentRef ref = null;
        while ((ref = (StudentRef) q.poll()) != null) {
            StudentRefs.remove(ref._key);
        }
    }

//    // 清除Cache内的全部内容
//    public void clearCache() {
//        cleanCache();
//        StudentRefs.clear();
//        //System.gc();
//        //System.runFinalization();
//    }
}

class Student {
    int id;
    String name;

    public Student(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

#### 弱引用

弱引用的整体机制和软引用基本一致，**区别在于弱引用包含的对象在垃圾回收时，不管内存够不够都会直接被回收。**

在JDK 1.2版之后提供了WeakReference类来实现弱引用，弱引用主要在ThreadLocal中使用。

弱引用对象本身也可以使用引用队列进行回收。

```java
byte[] bytes = new byte[1024 * 1024 * 100];
        WeakReference<byte[]> weakReference = new WeakReference<byte[]>(bytes);
        bytes = null;
        System.out.println(weakReference.get());

        System.gc();

        System.out.println(weakReference.get());
```

#### 虚引用和终结器引用

这两种引用在常规开发中是不会使用的。

虚引用也叫幽灵引用/幻影引用，不能通过虚引用对象获取到包含的对象。虚引用唯一的用途是当对象被垃圾回收器回收时可以接收到对应的通知。Java中使用PhantomReference实现了虚引用，直接内存中为了及时知道直接内存对象不再使用，从而回收内存，使用了虚引用来实现。

终结器引用指的是在对象需要被回收时，终结器引用会关联对象并放置在Finalizer类中的引用队列中，在稍后由一条由FinalizerThread线程从队列中获取对象，然后执行对象的finalize方法，在对象第二次被回收时，该对象才真正的被回收。在这个过程中可以在finalize方法中再将自身对象使用强引用关联上，但是不建议这样做。

### 垃圾回收算法

Java是如何实现垃圾回收的呢？简单来说，垃圾回收要做的有两件事：

1、找到内存中存活的对象

2、释放不再存活对象的内存，使得程序能再次利用这部分空间

##### 垃圾回收算法的历史和分类

1960年John McCarthy发布了第一个GC算法：标记-清除算法。

1963年Marvin L. Minsky 发布了复制算法。

本质上后续所有的垃圾回收算法，都是在上述两种算法的基础上优化而来。

![29.png](img/l7XqtgAdEw6FoiS.png)

##### 垃圾回收算法的评价标准

Java垃圾回收过程会通过单独的GC线程来完成，但是不管使用哪一种GC算法，都会有部分阶段需要停止所有的用户线程。这个过程被称之为Stop The World简称STW，如果STW时间过长则会影响用户的使用。

![30.png](img/Bcd9IXFksY8NP1b.png)

所以判断GC算法是否优秀，可以从三个方面来考虑：

1.吞吐量

吞吐量指的是 CPU 用于执行用户代码的时间与 CPU 总执行时间的比值，即吞吐量 = 执行用户代码时间 /（执行用户代码时间 + GC时间）。吞吐量数值越高，垃圾回收的效率就越高。

比如：虚拟机总共运行了 100 分钟，其中GC花掉 1 分钟，那么吞吐量就是 99%

2.最大暂停时间

最大暂停时间指的是所有在垃圾回收过程中的STW时间最大值。比如如下的图中，黄色部分的STW就是最大暂停时间，显而易见上面的图比下面的图拥有更少的最大暂停时间。最大暂停时间越短，用户使用系统时受到的影响就越短。

![31.png](img/UGd9y3ErQI8TCVK.png)

3.堆使用效率

不同垃圾回收算法，对堆内存的使用方式是不同的。比如标记清除算法，可以使用完整的堆内存。而复制算法会将堆内存一分为二，每次只能使用一半内存。从堆使用效率上来说，标记清除算法要优于复制算法。

上述三种评价标准：堆使用效率、吞吐量，以及最大暂停时间不可兼得。

**一般来说，堆内存越大，最大暂停时间就越长。想要减少最大暂停时间，就会降低吞吐量。（将很长的最大暂停时间拆分成几次）**

**不同的垃圾回收算法，适用于不同的场景。**

![32.png](img/xGeuIzbLgDSRBJo.png)

##### 标记清除算法

标记清除算法的核心思想分为两个阶段：

1.标记阶段，将所有存活的对象进行标记。Java中使用可达性分析算法，从GC Root开始通过引用链遍历出所有存活对象。

2.清除阶段，从内存中删除没有被标记也就是非存活对象。

###### 优缺点

优点：实现简单，只需要在第一阶段给每个对象维护标志位，第二阶段删除对象即可。

缺点：1.碎片化问题

由于内存是连续的，所以在对象被删除之后，内存中会出现很多细小的可用内存单元。如果我们需要的是一 个比较大的空间，很有可能这些内存单元的大小过小无法进行分配。

![33.png](img/vfKIPJrp9kXFn4l.png)

2.分配速度慢。由于内存碎片的存在，需要维护一个空闲链表，极有可能发生每次需要遍历到链表的最后才 能获得合适的内存空间。

![34.png](img/sPrAf2XRaMHyk9p.png)

##### 复制算法

**复制算法的核心思想是：**

1.准备两块空间From空间和To空间，每次在对象分配阶段，只能使用其中一块空间（From空间）。

2.在垃圾回收GC阶段，将From中存活对象复制到To空间。

3.将两块空间的From和To名字互换。

**完整的复制算法的例子：**

1.将堆内存分割成两块From空间 To空间，对象分配阶段，创建对象。

2.GC阶段开始，将GC Root搬运到To空间

3.将GC Root关联的对象，搬运到To空间

4.清理From空间，并把名称互换

###### 优缺点

![35.png](img/RmZTPakt4yndjo1.png)

##### 标记整理法

标记整理算法也叫标记压缩算法，是对标记清理算法中容易产生内存碎片问题的一种解决方案。

核心思想分为两个阶段：

1.标记阶段，将所有存活的对象进行标记。Java中使用可达性分析算法，从GC Root开始通过引用链遍历出所有存活对象。

2.整理阶段，将存活对象移动到堆的一端。清理掉存活对象的内存空间。

![36.png](img/VeadSy9BbQnmMJ5.png)

###### 优缺点

![37.png](img/fr4txGUNXvoyVYL.png)

##### 分代垃圾回收算法

现代优秀的垃圾回收算法，会将上述描述的垃圾回收算法组合进行使用，其中应用最广的就是分代垃圾回收算法(Generational GC)。

分代垃圾回收将整个内存区域划分为年轻代和老年代：

![38.png](img/3IhK8sbVL7cfZOA.png)

**arthas查看分代之后的内存情况**

在JDK8中，添加-XX:+UseSerialGC参数使用分代回收的垃圾回收器，运行程序。

在arthas中使用memory命令查看内存，显示出三个区域的内存情况。

![39.png](img/VXdqbscmBNkZYWo.png)

**根据以下虚拟机参数，调整堆的大小并观察结果。注意加上-XX:+UseSerialGC**

| 参数名            | 参数含义                                                     | 示例                                                    |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------- |
| -Xmn              | 新生代的大小                                                 | 新生代256 MB的写法： -Xmn256m -Xmn262144k -Xmn268435456 |
| -XX:SurvivorRatio | 伊甸园区和幸存区的比例，默认为8 新生代1g内存，伊甸园区800MB,S0和 S1各100MB | 比例调整为4的写法： -XX:SurvivorRatio=4                 |
| -XX:NewRatio      | 新生代和老年代的比例，默认情况下，新生代和老年代的比例是1:2，即新生代占整个堆空间的1/3，而老年代占整体的2/3 | -XX:NewRatio=0.5                                        |
| -Xms              | 设置堆的最小和初始大小，必须是 1024倍数且大于1MB             | 比如初始大小6MB的写法： -Xms6291456 -Xms6144k -Xms6m    |
| -Xmx              | 设置最大堆的大小，必须是1024倍数 且大于2MB                   | 比如最大堆80 MB的写法： -Xmx83886080 -Xmx81920k -Xmx80m |

之所以不设置老年代的大小，一个是可以通过设置堆的大小，在减去老年代即可，或者通过设置比例。

分代回收时，创建出来的对象，首先会被放入Eden伊甸园区。

随着对象在Eden区越来越多，如果Eden区满，新创建的对象已经无法放入，就会触发年轻代的GC，称为Minor GC或者Young GC。

Minor GC会把需要eden中和From需要回收的对象回收，把没有回收的对象放入To区。

![40.png](img/jfMucvkUApV9qKt.png)

![41.png](img/rYy84lAIapbXCFn.png)

通过分析可知，年轻代使用的是复制算法

接下来，S0会变成To区，S1变成From区。当eden区满时再往里放入对象，依然会发生Minor GC。

此时会回收eden区和S1(from)中的对象，并把eden和from区中剩余的对象放入S0。

![42.png](img/UkafXtjFgEQwP5e.png)

注意：每次Minor GC中都会为对象记录他的年龄，初始值为0，每次GC完加1。

![43.png](img/LXi8vD5lRxZ3pF4.png)

如果Minor GC后对象的年龄达到阈值（最大15，默认值和垃圾回收器有关），对象就会被晋升至老年代。

![44.png](img/3FlZRrBoaNAXtih.png)

![45.png](img/QWwKYEviXZBI4jM.png)

当老年代中空间不足，无法放入新的对象时，先尝试minor gc如果还是不足，就会触发Full GC，Full GC会对整个堆进行垃圾回收。

如果Full GC依然无法回收掉老年代的对象，那么当对象继续放入老年代时，就会抛出Out Of Memory异常。

下图中的程序为什么会出现OutOfMemory？

![46.png](img/ZkcnlCJfj6Ie1sF.png)

从上图可以看到，Full GC无法回收掉老年代的对象，那么当对象继续放入老年代时，就会抛出Out Of Memory异常。

### 垃圾回收器

为什么分代GC算法要把堆分成年轻代和老年代？

![47.png](img/EMXnuI9DjdayCbh.png)

系统中的大部分对象，都是创建出来之后很快就不再使用可以被回收，比如用户获取订单数据，订单数据返回给用户之后就可以释放了。

老年代中会存放长期存活的对象，比如Spring的大部分bean对象，在程序启动之后就不会被回收了。

在虚拟机的默认设置中，新生代大小要远小于老年代的大小。

![48.png](img/LSM4QWY9IaAfDrP.png)

分代GC算法将堆分成年轻代和老年代主要原因有：

1、可以通过调整年轻代和老年代的比例来适应不同类型的应用程序，提高内存的利用率和性能。

2、新生代和老年代使用不同的垃圾回收算法，新生代一般选择复制算法，老年代可以选择标记-清除和标记-整理算法，由程序员来选择灵活度较高。

3、分代的设计中允许只回收新生代（minor gc），如果能满足对象分配的要求就不需要对整个堆进行回收(full gc),STW时间就会减少。

**垃圾回收器的组合关系**

垃圾回收器是垃圾回收算法的具体实现。

由于垃圾回收器分为年轻代和老年代，除了G1之外其他垃圾回收器必须成对组合进行使用。

![49.png](img/GQMhHk29eOlC47n.png)

#### 年轻代-Serial垃圾回收器

Serial是是一种**单线程串行**回收年轻代的垃圾回收器

![50.png](img/kjsqVQRvBEcAeKw.png)

![51.png](img/BfGTCbXvz73ZsHO.png)

#### 老年代-SerialOld垃圾回收器

SerialOld是Serial垃圾回收器的老年代版本，采用**单线程串行回收**

**-XX:+UseSerialGC 新生代、老年代都使用串行回收器。**

![52.png](img/wtJTkBGWSCfeERj.png)

![53.png](img/OuThLjp4NMk8zva.png)

#### 年轻代-ParNew垃圾回收器

ParNew垃圾回收器本质上是对Serial在多CPU下的优化，使用**多线程**进行垃圾回收**-XX:+UseParNewGC 新生代使用ParNew回收器， 老年代使用串行回收器**

![54.png](img/AoRSnhMfYaL8Pi6.png)

![55.png](img/sL2W9zr1lvM65St.png)

#### 老年代- CMS(Concurrent Mark Sweep)垃圾回收器

CMS垃圾回收器关注的是系统的**暂停时间**，**允许用户线程和垃圾回收线程在某些步骤中同时执行，减少了用户线程的等待时间**。

参数：XX:+UseConcMarkSweepGC

![56.png](img/vh1QbGSsMRdK9Yk.png)

![57.png](img/rLCzwmVt1EWZcnS.png)

**CMS执行步骤：**

1.初始标记，用极短的时间标记出GC Roots能直接关联到的对象。

2.并发标记, 标记所有的对象，用户线程不需要暂停。

3.重新标记，由于并发标记阶段有些对象会发生了变化，存在错标、漏标等情况，需要重新标记。

4.并发清理，清理死亡的对象，用户线程不需要暂停。

**缺点：**

1、CMS使用了标记-清除算法，在垃圾收集结束之后会出现大量的内存碎片，CMS会在Full GC时进行碎片的整理。这样会导致用户线程暂停，可以使用-XX:CMSFullGCsBeforeCompaction=N 参数（默认0）调整N次Full GC之 后再整理。

2.、无法处理在并发清理过程中产生的“浮动垃圾”（也就是在并发清理的过程中，又产生了一些不使用的对象，只能下一次在清理），不能做到完全的垃圾回收。

3、如果老年代内存不足无法分配对象，CMS就会退化成Serial Old单线程回收老年代。

##### 线程资源争抢问题

在CMS中并发阶段运行时的线程数可以通过-XX:ConcGCThreads参数设置，默认值为0，由系统计算得出。

计算公式为(-XX:ParallelGCThreads定义的线程数 + 3) / 4， ParallelGCThreads是STW停顿之后的并行线程数

ParallelGCThreads是由处理器核数决定的：

1、当cpu核数小于8时，ParallelGCThreads = CPU核数

2、否则 ParallelGCThreads = 8 + (CPU核数 – 8 )*5/8

![58.png](img/wG7AafYxvEOFdUr.png)

由于CPU的核心数有限，就会影响用户线程执行的性能。

![59.png](img/ESme39ytvoGzpWM.png)

#### 年轻代-Parallel Scavenge垃圾回收器

Parallel Scavenge是JDK8默认的年轻代垃圾回收器，**多线程并行回收，关注的是系统的吞吐量。具备自动调整堆内存大小的特点。**

![60.png](img/wY1qm9jgfzHsi6r.png)

![61.png](img/q9bfnxPvpkoFid3.png)

#### 老年代-Parallel Old垃圾回收器

Parallel Old是为Parallel Scavenge收集器设计的老年代版本，利用多线程并发收集。

参数： -XX:+UseParallelGC 或-XX:+UseParallelOldGC可以使用

Parallel Scavenge + Parallel Old这种组合。

![62.png](img/RpD6tg3iK7IO8Mu.png)

![63.png](img/uCqSDNpGxHv75yX.png)

Parallel Scavenge允许手动设置最大暂停时间和吞吐量。

Oracle官方建议在使用这个组合时，**不要设置堆内存的最大值**，垃圾回收器会根据最大暂停时间和吞吐量自动调整内存大小。

![c788f888712](img/c788f888712.png)

#### G1垃圾回收器

JDK9之后默认的垃圾回收器是G1（Garbage First）垃圾回收器。

Parallel Scavenge关注吞吐量，允许用户设置最大暂停时间 ，但是会减少年轻代可用空间的大小。

CMS关注暂停时间，但是吞吐量方面会下降。

而G1设计目标就是将上述两种垃圾回收器的优点融合：

1.支持巨大的堆空间回收，并有较高的吞吐量。

2.支持多CPU并行垃圾回收。

3.允许用户设置最大暂停时间。

**JDK9之后强烈建议使用G1垃圾回收器。**

##### 内存结构

G1出现之前的垃圾回收器，内存结构一般是连续的，如下图：

![65.png](img/LbuQP2IgSzcsmBv.png)

G1的整个堆会被划分成多个大小相等的区域，称之为区Region，区域不要求是连续的。分为Eden、Survivor、Old区。Region的大小通过堆空间大小/2048计算得到，也可以通过参数-XX:G1HeapRegionSize=32m指定(其中32m指定region大小为32M)，Region size必须是2的指数幂，取值范围从1M到32M。

![66.png](img/tI5l4FDnr1M2863.png)

G1垃圾回收有两种方式：

1、年轻代回收（Young GC）

2、混合回收（Mixed GC）

##### 年轻代回收

年轻代回收（Young GC），回收Eden区和Survivor区中不用的对象。会导致STW，G1中可以通过参数-XX:MaxGCPauseMillis=n（默认200） 设置每次垃圾回收时的最大暂停时间毫秒数，G1垃圾回收器会尽可能地保证暂停时间。

###### 执行流程

1、新创建的对象会存放在Eden区。当G1判断年轻代区不足（max默认60%），无法分配对象时需要回收时会执行Young GC。

2、标记出Eden和Survivor区域中的存活对象。

3、根据配置的最大暂停时间选择某些区域将存活对象复制到一个新的Survivor区中（年龄+1），清空这些区域。

G1在进行Young GC的过程中会去记录每次垃圾回收时每个Eden区和Survivor区的平均耗时，以作为下次回收时的参考依据。这样就可以根据配置的最大暂停时间计算出本次回收时最多能回收多少个Region区域了。

比如 -XX:MaxGCPauseMillis=n（默认200），每个Region回收耗时40ms，那么这次回收最多只能回收4个Region。

4、后续Young GC时与之前相同，只不过Survivor区中存活对象会被搬运到另一个Survivor区。

5、当某个存活对象的年龄到达阈值（默认15），将被放入老年代。

6、部分对象如果大小超过Region的一半，会直接放入老年代，这类老年代被称为Humongous区。比如堆内存是4G，每个Region是2M，只要一个大对象超过了1M就被放入Humongous区，如果对象过大会横跨多个Region。

##### 混合回收

7、多次回收之后，会出现很多Old老年代区，此时总堆占有率达到阈值时

（-XX:InitiatingHeapOccupancyPercent默认45%）会触发混合回收MixedGC。回收所有年轻代和部分老年代的对象以及大对象区。采用复制算法来完成。

![67.png](img/rdIBY2Zo3g9bifj.png)

混合回收分为：初始标记（initial mark）、并发标记（concurrent mark）、最终标记（remark或者Finalize Marking）、并发清理（cleanup）

![68.png](img/o4gTQjpAFd39xLW.png)

G1对老年代的清理会选择存活度最低的区域来进行回收，这样可以保证回收效率最高，这也是G1（Garbage first）名称的由来。

最后清理阶段使用复制算法，不会产生内存碎片。

![69.png](img/l6bwuSLxMzaKI3J.png)

注意：如果清理过程中发现没有足够的空Region存放转移的对象，会出现Full GC。单线程执行标记-整理算法，此时会导致用户线程的暂停。所以尽量保证应该用的堆内存有一定多余的空间。

其中G1可以设置的一些参数

参数1： -XX:+UseG1GC 打开G1的开关，JDK9之后默认不需要打开

参数2：-XX:MaxGCPauseMillis=毫秒值最大暂停的时间

![70.png](img/ZSlVdiFqasOWnhD.png)



作者：爱吃芝士的土豆倪<br/>
链接：https://juejin.cn/post/7327642905244893219<br/>
来源：稀土掘金<br/>
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。<br/>