资料来源：<br/>
[03-Ajax传输json和XML](https://github.com/qianguyihao/Web/blob/master/06-JavaScript%E5%9F%BA%E7%A1%80%EF%BC%9A%E5%BC%82%E6%AD%A5%E7%BC%96%E7%A8%8B/03-Ajax%E4%BC%A0%E8%BE%93json%E5%92%8CXML.md)<br/>



## ajax请求

后端的常用的有`get`,`post`请求两种，post请求常用的一种是请求体（json）格式，一种是请求内容

```java

@RestController
public class ControllerDemo {


    @GetMapping("/say")
    public Map<String,Object> sayHello(String name, Integer age){
        Map<String,Object> map = new HashMap<>();
        map.put("hello", "hello world");
        System.out.println("name:" + name);
        System.out.println("age:" + age);
        return map;
    }

    @PostMapping("/say")
    public Map<String,Object> sayHello2(@RequestBody Map<String , Object> map){
        Object s = map.get("name");
        System.out.println(s);
        return map;
    }

    @PostMapping("/say3")
    public Map<String,Object> sayHello3(String name ,Integer age){
        Map<String,Object> map = new HashMap<>();
        map.put("hello", "hello world");
        System.out.println("name:" + name);
        System.out.println("age:" + age);
        return map;
    }
}

```



使用js地址

```java
https://code.jquery.com/jquery-1.11.2.js
```

### get请求

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>jquery-ajax</title>
</head>
<body>
<input type="button" value="点击" id="btn" />
<div id="showInfo"></div>
<script type="text/javascript" src="js/jquery-1.11.2.js"></script>
<script type="text/javascript">
  $(function () {
    $('#btn').click(function () {
      $.ajax({
        url: 'hello', // 接口的请求地址
        dataType: 'text',
        data: 'name=fox&age=18', // 请求参数
        type: 'get',
        success: function (data) {
          console.log('接口请求成功');
          alert(data);
          $("#showInfo").html(data);
        },
        error: function (err) {
          console.log('接口请求失败：' + err);
        },
      });
    });
  });
</script>
</body>
</html>
```

### post请求(json)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>jquery-ajax</title>
</head>
<body>
<input type="button" value="点击" id="btn" />
<div id="showInfo"></div>
<script type="text/javascript" src="js/jquery-1.11.2.js"></script>
<script type="text/javascript">
  $(function () {
    $('#btn').click(function () {
      $.ajax({
        url: 'http://127.0.0.1/say', // 接口的请求地址
        dataType: 'json',
        type: 'post',
        headers:{'Content-Type':'application/json;charset=utf8'},
        data: '{"name":"liuwei"}', // 请求参数
        success: function (data) {
          let s = JSON.stringify(data);
          alert(s);
          $("#showInfo").html(data.name);
        },
        error: function (err) {
          console.log('接口请求失败：' + err);
        },
      });
    });
  });
</script>
</body>
</html>
```

### post请求(请求体)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>jquery-ajax</title>
</head>
<body>
<input type="button" value="点击" id="btn" />
<div id="showInfo"></div>
<script type="text/javascript" src="js/jquery-1.11.2.js"></script>
<script type="text/javascript">
  $(function () {
    $('#btn').click(function () {
      $.ajax({
        url: 'http://127.0.0.1/say3', // 接口的请求地址
        dataType: 'json',
        type: 'post',
        headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
        data: 'name=fox&age=18', // 请求参数
        success: function (data) {
          console.log('接口请求成功');
          alert(data);
          $("#showInfo").html(data);
        },
        error: function (err) {
          console.log('接口请求失败：' + err);
        },
      });
    });
  });
</script>
</body>
</html>
```

### json