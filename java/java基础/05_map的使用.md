资料来源：<br/>
[Java集合(三) -- 并发安全Map](https://juejin.cn/post/6844903632178003982?searchId=202307190953280901DF2137D2292ABA81)<br/>
[Java如何删除map中的元素](https://blog.csdn.net/weixin_37646636/article/details/132706279)<br/>
[Java删除Map中元素](https://juejin.cn/post/6844903859580567559?searchId=20230719095120BF9BFEA34091611B54B4)

## map

### 误用 map.remove会报错

```java
for (Map.Entry<Integer, String> entry : map.entrySet()) {
    Integer key = entry.getKey();
    if (key % 2 == 0) {
        map.remove(key);
    }
}
# 此时就会报java.util.ConcurrentModificationException错误

```

#### 原因

> 基本上java集合类（包括list和map）在遍历时没用迭代器进行删除了都会报ConcurrentModificationException错误，这是一种fast-fail的机制，初衷是为了检测bug。通俗一点来说，这种机制就是为了防止高并发的情况下，多个线程同时修改map或者list的元素导致的数据不一致，这是只要判断当前modCount != expectedModCount即可以知道有其他线程修改了集合。
>

### 解决方案

#### 用迭代器的remove方法。

```java
# 迭代器删除元素
# 会删除所有符合条件的元素
Map<Integer, String> map = new HashMap<>();

Iterator<Map.Entry<Integer, String>> iterator = map.entrySet().iterator();
while (iterator.hasNext()) {
    Map.Entry<Integer, String> entry = iterator.next();
    if (entry.getKey() == 1) {
        iterator.remove();
    }
}
```

#### removeIf

```java
# java8 removeIf删除元素
Map<Integer, String> map = new HashMap<>();

map.entrySet().removeIf(entry -> entry.getKey() != 1);   删除符合条件的Entry
map.keySet().removeIf(key -> key != 1);                  删除符合条件的Entry
map.values().removeIf(value -> value.contains("1"));     删除符合条件的Entry
```