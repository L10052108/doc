资料来源：<br/>
[Java中的5大队列，你知道几个？](https://www.toutiao.com/article/6886612634859536900/?log_from=ac58831c58baa_1650432268817)<br/>
[JAVA队列（ Queue ) 详解](https://www.toutiao.com/article/7082294108403892774/?channel=&source=search_tab)<br/>
[基础篇：JAVA集合，面试专用](https://juejin.cn/post/7024775152231514142)



##  Queue（队列）

- Queue的概念 队列是一种特殊的线性表，只允许元素从队列一端入队，而另一端出队（获取元素），就像我们平时排队结算一样（懂文明讲礼貌不插队）。Queue 的数据结构和 List 一样，可以基于数组，链表实现，队列通常都是一端进(offer)，另一端出(poll)，有序性

### PriorityQueue

- PriorityQueue是按优先级排序的队列，也就是说 vip 可以插队。优先队列要求使用 Java Comparable 和 Comparator 接口给对象排序，并且在排序时会按照优先级处理其中的元素
- PriorityBlockingQueue 是线程安全的PriorityQueue

### BlockingQueue

- BlockingQueue很好的解决了多线程中，如何高效安全“传输”数据的问题。通过这些高效并且线程安全的队列类，为我们快速搭建高质量的多线程程序带来极大的便利。常用于线程的任务队列
- DelayQueue
  - DelayQueue是一个没有边界BlockingQueue实现，加入元素必需实现Delayed接口。当生产者线程调用put之类的方法加入元素时，会触发 Delayed 接口中的compareTo方法进行排序
  - 消费者线程查看队列头部的元素，注意是查看不是取出。然后调用元素的getDelay方法，如果此方法返回的值小0或者等于0，则消费者线程会从队列中取出此元素，并进行处理。如果getDelay方法返回的值大于0，则消费者线程阻塞到第一元素过期

### Queue 的 API

- Queue的概念 队列是一种特殊的线性表，只允许元素从队列一端入队，而另一端出队（获取元素），就像我们平时排队结算一样（懂文明讲礼貌不插队）。Queue 的数据结构和 List 一样，可以基于数组，链表实现，队列通常都是一端进(offer)，另一端出(poll)，有序性

### PriorityQueue

- PriorityQueue是按优先级排序的队列，也就是说 vip 可以插队。优先队列要求使用 Java Comparable 和 Comparator 接口给对象排序，并且在排序时会按照优先级处理其中的元素
- PriorityBlockingQueue 是线程安全的PriorityQueue

### BlockingQueue

- BlockingQueue很好的解决了多线程中，如何高效安全“传输”数据的问题。通过这些高效并且线程安全的队列类，为我们快速搭建高质量的多线程程序带来极大的便利。常用于线程的任务队列
- DelayQueue
  - DelayQueue是一个没有边界BlockingQueue实现，加入元素必需实现Delayed接口。当生产者线程调用put之类的方法加入元素时，会触发 Delayed 接口中的compareTo方法进行排序
  - 消费者线程查看队列头部的元素，注意是查看不是取出。然后调用元素的getDelay方法，如果此方法返回的值小0或者等于0，则消费者线程会从队列中取出此元素，并进行处理。如果getDelay方法返回的值大于0，则消费者线程阻塞到第一元素过期

### Queue 的 API

Queue的概念 队列是一种特殊的线性表，只允许元素从队列一端入队，而另一端出队（获取元素），就像我们平时排队结算一样（懂文明讲礼貌不插队）。Queue 的数据结构和 List 一样，可以基于数组，链表实现，队列通常都是一端进(offer)，另一端出(poll)，有序性

### PriorityQueue

- PriorityQueue是按优先级排序的队列，也就是说 vip 可以插队。优先队列要求使用 Java Comparable 和 Comparator 接口给对象排序，并且在排序时会按照优先级处理其中的元素
- PriorityBlockingQueue 是线程安全的PriorityQueue

### BlockingQueue

- BlockingQueue很好的解决了多线程中，如何高效安全“传输”数据的问题。通过这些高效并且线程安全的队列类，为我们快速搭建高质量的多线程程序带来极大的便利。常用于线程的任务队列
- DelayQueue
  - DelayQueue是一个没有边界BlockingQueue实现，加入元素必需实现Delayed接口。当生产者线程调用put之类的方法加入元素时，会触发 Delayed 接口中的compareTo方法进行排序
  - 消费者线程查看队列头部的元素，注意是查看不是取出。然后调用元素的getDelay方法，如果此方法返回的值小0或者等于0，则消费者线程会从队列中取出此元素，并进行处理。如果getDelay方法返回的值大于0，则消费者线程阻塞到第一元素过期

### Queue 的 API

```java
boolean add(E e); //加入队列尾部
boolean offer(E e); // 加入队列尾部，并返回结果
E remove(); //移除头部元素
E poll();  // 获取头部元素，并移除
E element(); // 获取头部元素，不存在则报错
E peek(); // 获取头部元素，不移除
```

## Deque（双向队列）

- Deque接口代表一个"双端队列"，双端队列可以同时从两端来添加、删除元素，因此Deque的实现类既可以当成队列使用、也可以当成栈使用
- Deque 的子类 LinkedList，ArrayDeque，LinkedBlockingDeque

### Deque的 API

```java
void addFirst(E e); //加入头部
void addLast(E e);  //加入尾部
boolean offerFirst(E e); //加入头部，并返回结果
boolean offerLast(E e); //加入尾部，并返回结果
E removeFirst(); // 移除第一个元素
E removeLast(); // 移除最后一个元素
E getFirst(); //获取第一个元素,不存在则报错
E getLast();  //获取最后一个元素,不存在则报错
E pollFirst(); //获取第一个元素,并移除
E pollLast(); //获取最后一个元素,并移除
E peekFirst(); //获取第一个元素
E peekLast(); // 获取最后一个元素
void push(E e); //加入头部
E pop(); //弹出头部元素
```

