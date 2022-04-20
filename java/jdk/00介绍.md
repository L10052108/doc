## jdk介绍

资料来源：[如何理解 Java8 的函数式编程，面试必进](https://m.toutiaocdn.com/i7075583769079677452/?app=news_article&timestamp=1647577110&use_new_style=1&req_id=20220318121830010158156021082FD71F&group_id=7075583769079677452&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=4f1ac4d6-609a-4c85-98d9-659b9a6dea0c)

代码上传[参考代码](https://gitee.com/L10052108/springboot_project/tree/simple/src/test/java/xyz/guqing/project/simple)

### 介绍：

Java8 出现的时间已经不算短了，免费维护期马上也要到期了，官方已经开始推荐使用 Java11。

Java8 是革命性的一个版本，一直以来，Java 最受诟病的地方就是代码写起来很啰嗦，仅仅写一个 HelloWorld 都需要些很多的样板代码。

在 Java8 推出之后，啰嗦的代码有了很大的改观，Java 也可以写出简单优美的代码。最明显的改观就是 Java 开始支持函数式编程。

函数式编程的定义很晦涩，但是我们可以将函数式编程理解为函数本身可以作为参数进行传递，就是说，参数不仅仅可以是数据，也可以是行为（函数或者方法的实现其实就是逻辑行为）。

可能是 Java8 步子跨的太大，以至于现在还有很多人没有赶上来，依然用 Java8 在写 Java5 风格的代码。这篇文章的目的就是彻底说清楚 Java8 的变化，以及快速全面的使用 Java8 的特性，让 Java 代码优雅起来。

