## httpClient

资料来源

[官网](https://www.jetbrains.com/help/idea/http-client-in-product-code-editor.html)

[Idea自带http测试功能真香](https://blog.csdn.net/heshuncheng/article/details/107709913)

### 简介

在工作中接触的大多数项目都采用前后端分离方式，常用postman免费版来进行api接口测试。

> postman缺点：<br/>
> 1.无法保存测试脚本到文件，不方便前端查看。<br/>
> 2.需要下载单独安装包安装到系统中。<br/>

使用举例

![httpClinent](file/httpClinent.gif  ':size=70%')

## 简单使用

### 发送get请求

~~~~
### GET request with a header
GET https://httpbin.org/ip
Accept: application/json

### GET request with parameter
GET https://httpbin.org/get?show_env=1
Accept: application/json

### GET request with environment variables
GET {{host}}/get?show_env={{show_env}}
Accept: application/json

### GET request with disabled redirects
# @no-redirect
GET http://httpbin.org/status/301

### GET request with dynamic variables
GET http://httpbin.org/anything?id={{$uuid}}&ts={{$timestamp}}
~~~~

### 发送POST请求

````
### Send POST request with json body
POST https://httpbin.org/post
Content-Type: application/json

{
  "id": 999,
  "value": "content"
}

### Send POST request with body as parameters
POST https://httpbin.org/post
Content-Type: application/x-www-form-urlencoded

id=999&value=content

### Send a form with the text and file fields
POST https://httpbin.org/post
Content-Type: multipart/form-data; boundary=WebAppBoundary

--WebAppBoundary
Content-Disposition: form-data; name="element-name"
Content-Type: text/plain

Name
--WebAppBoundary
Content-Disposition: form-data; name="data"; filename="data.json"
Content-Type: application/json

< ./request-form-data.json
--WebAppBoundary--

### Send request with dynamic variables in request's body
POST https://httpbin.org/post
Content-Type: application/json

{
  "id": {{$uuid}},
  "price": {{$randomInt}},
  "ts": {{$timestamp}},
  "value": "content"
}

````

### 认证请求

~~~~
### Basic authorization.
GET https://httpbin.org/basic-auth/user/passwd
Authorization: Basic user passwd

### Basic authorization with variables.
GET https://httpbin.org/basic-auth/user/passwd
Authorization: Basic {{username}} {{password}}

### Digest authorization.
GET https://httpbin.org/digest-auth/realm/user/passwd
Authorization: Digest user passwd

### Digest authorization with variables.
GET https://httpbin.org/digest-auth/realm/user/passwd
Authorization: Digest {{username}} {{password}}

### Authorization by token, part 1. Retrieve and save token.
POST https://httpbin.org/post
Content-Type: application/json

{
  "token": "my-secret-token"
}

> {% client.global.set("auth_token", response.body.json.token); %}

### Authorization by token, part 2. Use token to authorize.
GET https://httpbin.org/headers
Authorization: Bearer {{auth_token}}

~~~~

### 测试响应

```
### Successful test: check response status is 200
GET https://httpbin.org/status/200

> {%
client.test("Request executed successfully", function() {
  client.assert(response.status === 200, "Response status is not 200");
});
%}

### Failed test: check response status is 200
GET https://httpbin.org/status/404

> {%
client.test("Request executed successfully", function() {
  client.assert(response.status === 200, "Response status is not 200");
});
%}

### Check response status and content-type
GET https://httpbin.org/get

> {%
client.test("Request executed successfully", function() {
  client.assert(response.status === 200, "Response status is not 200");
});

client.test("Response content-type is json", function() {
  var type = response.contentType.mimeType;
  client.assert(type === "application/json", "Expected 'application/json' but received '" + type + "'");
});
%}

### Check response body
GET https://httpbin.org/get

> {%
client.test("Headers option exists", function() {
  client.assert(response.body.hasOwnProperty("headers"), "Cannot find 'headers' option in response");
});
%}
```

## 实际使用

### 添加环境变量

通过选择添加环境后，生一个http-client.env.json文件，可以配置环境变量

![Snipaste_2022-03-16_13-33-39](file/Snipaste_2022-03-16_13-33-39.png)

我自己配置的local环境

```
{
  "local": {
    "server": "localhost:4002",
    "authorization": "06f2165baa7047b9bd8a272f0f3c927d"
  }
}
```

- 实际效果

![Mar-16-2022_13-32-21](file/Mar-16-2022_13-32-21.gif ':size=50%')

### 响应处理脚本

[资料来源](https://blog.csdn.net/LawssssCat/article/details/105228894)

- 我们很多时候不会一个 `会话` 只发送一个 `请求` ，而是在一个会话中发送多个请求。
- 并且，会根据不同响应，发送不同的请求或者请求体。

这就需要响应脚本进行处理。
刚好 idea 的 http client 提供了 `响应处理脚本` 的功能

（下面看 Examples 里面的一个例子）

![img](img/20200331095756238.png)

>  脚本使用方法两个（下图）
>
> 脚本使用方法两个（下图）
>
> 在 .http 文件中直接写脚本，用 >{% ... %} 包裹
> 直接导入 js脚本 ， 用 > 文件url 的方式
> （这种方式，需要引入 JavaScript Library | HTTP Response Handler.）
>

![在这里插入图片描述](img/20200330183942892.png)

**脚本的编写**

脚本可以 javascript（ECMAScript 5.1）写。
主要涉及到两个类：

- client：存储了会话（session）元数据（metadata）。

- response：存储响应信息（content type、status、response body 等等）

```java
    
    client.test("Request executed successfully", function() {
        client.assert(response.status === 200, "Response status is not 200");
    });
```

### RestfulToolkit

[来源](https://blog.csdn.net/minkeyto/article/details/104411616)

- RestfulToolkit 同样是个插件

![img](img/fewfewfwe.png ':size=90%')

