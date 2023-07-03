资料来源：<br/>
[jquery获取input type=text中的值的各种方式(总结)](https://www.jb51.net/article/98834.htm)<br/>
[「input type=“text“」和「textarea」的区别](https://blog.csdn.net/weixin_45701180/article/details/107317800)


## jquery获取input type=text中的值的各种方式

下面小编就为大家带来一篇jquery获取input type=text中的值的各种方式

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml>

<html xmlns="http://www.w3.org/1999/xhtml">

  <head>
    <title>JQuery获取文本框的值</title>
    <meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
    <script src="jquery-1.5.1.min.js" type="text/javascript"></script>
    
    <script type="text/javascript">
    //使用id的方式获取
    $(document).ready(function(){
      //1
      $("#button_text1").click(function(){
        var result1 = $("#input_text1").val();
        alert("result1 = " + result1);
      });
      //2
      $("#button_text2").click(function(){
        var result2 = $("input[id='input_text2']").val();
        alert("result2 = " + result2);
      });
      //3
      $("#button_text3").click(function(){
        var result3 = $("input[id='input_text3']").attr("value");
        alert("result3 = " + result3);
      });
      //4. 可以通过type的值来获取input中的值（未演示）
      /*
      $("#button_text4").click(function(){
        var result4 = $("input[type='text']").val();
        alert("result4 = " + result4);
      });
      */
      //5. 可以通过name的值来获取input中的值（未演示）
      /*
      $("#button_text5").click(function(){
        var result5 = $("input[name='text']").val();
        alert("result5 = " + result5);
      });      
      */
    });
    </script>
  </head>

  <body>
    <!-- 获取文本框的值：方式一 -->
    <div id="test1">
      <input id="input_text1" type="text" value="test1" style="width: 100px;" />
      <button id="button_text1">test1</button>
    </div>
    <!-- 获取文本框的值：方式二 -->
    <div id="test2">
      <input id="input_text2" type="text" value="test2" style="width: 100px;" />
      <button id="button_text2">test2</button>
    </div>
    <!-- 获取文本框的值：方式三 -->
    <div id="test3">
      <input id="input_text3" type="text" value="test3" style="width: 100px;" />
      <button id="button_text3">test3</button>
    </div>
  </body>

</html>
```

以上这篇jquery获取input type=text中的值的各种方式(总结)就是小编分享给大家的全部内容了，希望能给大家一个参考，也希望大家多多支持脚本之家。

## 「input type=“text“」和「textarea」的区别

在我们开发时经常需要用到输入框，通常解决办法就是`<input type="text"`和`<textarea>`,那么这两个标签有什么区别呢？
一：`<input type="text">` 标签

text标签是单行文本框，不会换行。

通过size属性指定显示字符的长度，注意：当使用css限定了宽高，那么size属性就不再起作用。

value属性指定初始值，Maxlength属性指定文本框可以输入的最长长度。
　　
可以通过width和height设置宽高，但是也不会增加行数，下面是一个例子：

```
 <input type="text" style="width: 200px; height: 100px" value="我是设置过宽高的text">  
```

　　结果：文本依然只有一行，并且居中显示。

![img](img\20200713152151906.png)

### 二：`<textarea> 标签`

`<textarea>`是多行文本输入框，文本区中可容纳无限数量的文本，其中的文本的默认字体是等宽字体（通常是 Courier），可以通过 cols 和 rows 属性来规定 textarea 的尺寸，不过更好的办法是使用 CSS 的 height 和 width 属性。下面是一个例子：


```
<textarea rows="5" cols="5">我是通过cols和rows定的大小，我的cols是20，rows是10</textarea>
```



![在这里插入图片描述](img\20200713152837276.png)



```html
<textarea style="width: 200px; height: 100px">我是通过width和height定的大小，我的width是200px，heigh是100px</textarea>
```

![img](img\20200713153009207.png)

简而言之，他们最大的区别就是text是单行文本框，textarea是多行文本框。


