## json

### JSON 的语法

JSON(JavaScript Object Notation)：是 ECMAScript 的子集。作用是进行数据的交换。语法更为简洁，网络传输、机器解析都更为迅速。

语法规则：

-   数据在键值对中

-   数据由逗号分隔

-   花括号保存对象

-   方括号保存数组

数据类型：

-   数字（整数或浮点数）

-   字符串（在双引号中）

-   逻辑值（true 或 false）

-   数组（在方括号中）

-   对象（在花括号中）

-   null

示例：

```json
// 对象
{
  "name":"fox",
  "age":"18",
  "sex":"true",
  "car":null
}

// 数组
[
  {
      "name":"小小胡",
      "age":"1"
  },
  {
      "name":"小二胡",
      "age":"2"
  }
]
```

### JavaScript 中：json 字符串 <--> js 对象

基本上，所有的语言都有**将 json 字符串转化为该语言对象**的语法。

比如在 js 中：

-   JSON.parse()：将 JSON 字符串转化为 js 对象。例如：

```javascript
// 将 JSON 字符串格式化为 js 对象
var jsObj = JSON.parse(ajax.responseText);
```

-   JSON.stringify()：将 JS 对象转化为 JSON 字符串。例如：

```javascript
var Obj = {
    name: 'fox',
    age: 18,
    skill: '撩妹',
};

console.log(Obj);

// 将 js 对象格式化为 JSON 字符串
var jsonStr = JSON.stringify(Obj);
```