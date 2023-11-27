资料来源：<br/>
[再见丑陋的 SwaggerUI，这款API文档生成神器界面更炫酷，逼格更高！](https://mp.weixin.qq.com/s/qWfdhx-b28NP6--xeTePSg)<br/>
[Swagger使用和注释介绍](https://juejin.cn/post/6844903901724950535)<br/>

## 什么是Swagger

Swagger是一个规范和完整的框架，用于生成、描述、调用和可视化 RESTful 风格的 Web 服务。总体目标是使客户端和文件系统作为服务器以同样的速度来更新。文件的方法，参数和模型紧密集成到服务器端的代码，允许API来始终保持同步。

**作用**

- 接口文档在线自动生成
- 功能测试

**Swagger是一组开源项目，其中主要要项目如下：**

- **Swagger-tools**:提供各种与Swagger进行集成和交互的工具。例如模式检验、Swagger 1.2文档转换成Swagger 2.0文档等功能。
- **Swagger-core**: 用于Java/Scala的的Swagger实现。与JAX-RS(Jersey、Resteasy、CXF...)、Servlets和Play框架进行集成。
- **Swagger-js**: 用于JavaScript的Swagger实现。
- **Swagger-node-express**: Swagger模块，用于node.js的Express web应用框架。
- **Swagger-ui**：一个无依赖的HTML、JS和CSS集合，可以为Swagger兼容API动态生成优雅文档。
- **Swagger-codegen**：一个模板驱动引擎，通过分析用户Swagger资源声明以各种语言生成客户端代码。

## 在Spring使用Swagger

在Spring中集成Swagger会使用到`springfox-swagger`，它对Spring和Swagger的使用进行了整合

```xml
		<!--swagger 配置-->
		<dependency>
			<groupId>com.github.xiaoymin</groupId>
			<artifactId>knife4j-spring-boot-starter</artifactId>
			<version>${swagger-version}</version>
		</dependency>
```

- 版本

```
<swagger-version>3.0.3</swagger-version>
```

### 配置

- 四川文渊阁的配置

```java

import com.github.xiaoymin.knife4j.spring.annotations.EnableKnife4j;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.*;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spi.service.contexts.SecurityContext;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;
import store.liuwei.shiyi.summary.util.EnvironmentUtil;

import java.util.ArrayList;
import java.util.List;

@Configuration
@EnableSwagger2
@EnableKnife4j
@Slf4j
public class SwaggerConfig {

    /**
     * 环境标识符
     */
//    @Value("${spring.profiles.active}")
    private String env = EnvironmentUtil.getEnvFlag();

    private List<SecurityScheme> securitySchemes() {
        List<SecurityScheme> apiKeys = new ArrayList<>();
        apiKeys.add(new ApiKey("token", "token", "header"));
        return apiKeys;
    }

    private List<SecurityContext> securityContexts() {
        List<SecurityContext> securityContexts = new ArrayList<>();
        securityContexts.add(SecurityContext.builder()
                .securityReferences(defaultAuth())
                .forPaths(PathSelectors.regex("^(?!auth).*$")).build());
        return securityContexts;
    }

    private List<SecurityReference> defaultAuth() {
        AuthorizationScope authorizationScope = new AuthorizationScope("global", "accessEverything");
        AuthorizationScope[] authorizationScopes = new AuthorizationScope[1];
        authorizationScopes[0] = authorizationScope;
        List<SecurityReference> securityReferences = new ArrayList<>();
        securityReferences.add(new SecurityReference("satoken", authorizationScopes));
        return securityReferences;
    }


    @Bean
    public Docket zzzRestInner() {
        return new Docket(DocumentationType.SWAGGER_2)
                .groupName("inner 接口文档")
                .enable("prd".equals(env))
                .apiInfo(apiInfo()).select()
                .apis(RequestHandlerSelectors.basePackage("store.liuwei.shiyi.summary.controller"))
                .paths(PathSelectors.any())
                .build()
                .securitySchemes(securitySchemes())
                .securityContexts(securityContexts());
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("统计系统")
                .description("统计系统接口文档")
                .build();
    }
}
```

### 放行的接口

如果项目中加了权限认证的话，记得给 Knife4j 添加白名单。我的项目用的是 SpringSecurity，所以需要在 application.yml 文件中添加。

```yaml
secure:
  ignored:
    urls: #安全路径白名单
      - /doc.html
      - /swagger-ui/**
      - /swagger/**
      - /swagger-resources/**
      - /**/v3/api-docs
```

## API注解

### @Api

用在类上，该注解将一个Controller（Class）标注为一个swagger资源（API）。在默认情况下，Swagger-Core只会扫描解析具有@Api注解的类，而会自动忽略其他类别资源（JAX-RS endpoints，Servlets等等）的注解。该注解包含以下几个重要属性

- tags API分组标签。具有相同标签的API将会被归并在一组内展示。
- value 如果tags没有定义，value将作为Api的tags使用
- description API的详细描述，在1.5.X版本之后不再使用，**但实际发现在2.0.0版本中仍然可以使用**

### @ApiOperation

在指定的（路由）路径上，对一个操作或HTTP方法进行描述。具有相同路径的不同操作会被归组为同一个操作对象。不同的HTTP请求方法及路径组合构成一个唯一操作。此注解的属性有：

- value 对操作的简单说明，长度为120个字母，60个汉字。
- notes 对操作的详细说明。
- httpMethod HTTP请求的动作名，可选值有："GET", "HEAD", "POST", "PUT", "DELETE", "OPTIONS" and "PATCH"。
- code 默认为200，有效值必须符合标准的[HTTP Status Code Definitions](https://link.juejin.cn?target=https%3A%2F%2Flink.jianshu.com%2F%3Ft%3Dhttp%3A%2F%2Fwww.w3.org%2FProtocols%2Frfc2616%2Frfc2616-sec10.html)。

### @ApiImplicitParams

用在方法上，注解ApiImplicitParam的容器类，以数组方式存储。

### @ApiImplicitParam

对API的单一参数进行注解。虽然注解@ApiParam同JAX-RS参数相绑定，但这个@ApiImplicitParam注解可以以统一的方式定义参数列表，也是在Servelet及非JAX-RS环境下，唯一的方式参数定义方式。注意这个注解@ApiImplicitParam必须被包含在注解@ApiImplicitParams之内。可以设置以下重要参数属性：

- name 参数名称
- value 参数的简短描述
- required 是否为必传参数
- dataType 参数类型，可以为类名，也可以为基本类型（String，int、boolean等）
- paramType 参数的传入（请求）类型，可选的值有path, query, body, header or form。

### @ApiParam

增加对参数的元信息说明。这个注解只能被使用在JAX-RS 1.x/2.x的综合环境下。其主要的属性有

- required 是否为必传参数，默认为false
- value 参数简短说明

### @ApiResponses

注解@ApiResponse的包装类，数组结构。即使需要使用一个@ApiResponse注解，也需要将@ApiResponse注解包含在注解@ApiResponses内。

### @ApiResponse

描述一个操作可能的返回结果。当REST API请求发生时，这个注解可用于描述所有可能的成功与错误码。可以用，也可以不用这个注解去描述操作的返回类型，但成功操作的返回类型必须在@ApiOperation中定义。如果API具有不同的返回类型，那么需要分别定义返回值，并将返回类型进行关联。但Swagger不支持同一返回码，多种返回类型的注解。注意：这个注解必须被包含在@ApiResponses注解中。

- code HTTP请求返回码。有效值必须符合标准的[HTTP Status Code Definitions](https://link.juejin.cn?target=https%3A%2F%2Flink.jianshu.com%2F%3Ft%3Dhttp%3A%2F%2Fwww.w3.org%2FProtocols%2Frfc2616%2Frfc2616-sec10.html)。
- message 更加易于理解的文本消息
- response 返回类型信息，必须使用完全限定类名，比如“com.xyz.cc.Person.class”。
- responseContainer 如果返回类型为容器类型，可以设置相应的值。有效值为 "List", "Set" or "Map"，其他任何无效的值都会被忽略。

## Model注解

对于Model的注解，Swagger提供了两个：@ApiModel及@ApiModelProperty，分别用以描述Model及Model内的属性。

### @ApiModel

描述一个Model的信息（一般用在请求参数无法使用@ApiImplicitParam注解进行描述的时候）

提供对Swagger model额外信息的描述。在标注@ApiOperation注解的操作内，所有的类将自动被内省（introspected），但利用这个注解可以做一些更加详细的model结构说明。主要属性有：

- value model的别名，默认为类名
- description model的详细描述

### @ApiModelProperty

描述一个model的属性

对model属性的注解，主要的属性值有：

- value 属性简短描述
- example 属性的示例值
- required 是否为必须值

## 注解示例

Api 示例

```java
@AllArgsConstructor
@RestController
@RequestMapping("/api/category")
@Api(value = "/category", tags = "组件分类")
public class BizCategoryController {

    private IBizCategoryService bizCategoryService;

    @GetMapping("/list")
    @ApiOperation(value = "列表", notes = "分页列表")
    public R<PageModel<BizCategory>> list(PageQuery pageQuery,
                                          @RequestParam @ApiParam("组件分类名称") String name) {
        IPage<BizCategory> page = bizCategoryService.page(pageQuery.loadPage(),
                new LambdaQueryWrapper<BizCategory>().like(BizCategory::getName, name));
        return R.success(page);
    }

    @GetMapping("/list/all")
    @ApiOperation(value = "查询所有", notes = "分页列表")
    public R<List<BizCategory>> listAll() {
        List<BizCategory> categories = bizCategoryService.list();
        return R.success(categories);
    }

    @GetMapping("/{categoryId}")
    @ApiOperation(value = "详情", notes = "组件分类详情")
    public R<BizCategory> detail(@PathVariable @ApiParam("分类Id") Long categoryId) {
        BizCategory category = bizCategoryService.getById(categoryId);
        return R.success(category);
    }

    @PostMapping("/save")
    @ApiOperation(value = "保存", notes = "新增或修改")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType = "form", name = "categoryId", value = "组件id（修改时为必填）"),
            @ApiImplicitParam(paramType = "form", name = "name", value = "组件分类名称", required = true)
    })
    public R<BizCategory> save(Long categoryId, String name) {
        BizCategory category = new BizCategory();
        category.setId(categoryId);
        category.setName(name);
        bizCategoryService.saveOrUpdate(category);
        return R.success(category);
    }

    @DeleteMapping("/{categoryId}")
    @ApiOperation(value = "删除", notes = "删除")
    public R delete(@PathVariable @ApiParam("分类Id") Long categoryId) {
        bizCategoryService.delete(categoryId);
        return R.success();
    }
}
```

ApiModel 示例

```java
@Data
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@ApiModel(value="BizComponent对象", description="组件")
public class BizComponent implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    @ApiModelProperty(value = "分类")
    private Long categoryId;

    @ApiModelProperty(value = "组件名称")
    private String name;

    @ApiModelProperty(value = "组件描述")
    private String description;

    @ApiModelProperty(value = "日期字段")
    private LocalDateTime componentTime;

    @ApiModelProperty(value = "创建时间")
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @ApiModelProperty(value = "修改时间")
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime modifiedTime;
}
```

# swagger-ui界面

swagger生成的api文档信息接口为`/v2/api-docs`，不过我们可以使用ui界面更加清晰的查看**文档说明**，并且还能够**在线调试**

## springfox-swagger-ui

```xml
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger-ui</artifactId>
    <version>${springfox.swagger.version}</version>
</dependency>
```

如果是使用`springfox-swagger-ui`，启动项目后的api文档访问路径是 /swagger-ui.html



![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/7/29/16c3b9f055e7fa5e~tplv-t2oaga2asx-jj-mark:3024:0:0:0:q75.awebp)



## swagger-bootstrap-ui

[swagger-bootstrap-ui](https://link.juejin.cn?target=https%3A%2F%2Fgitee.com%2Fxiaoym%2Fswagger-bootstrap-ui)是springfox-swagger的增强UI实现，我个人更推荐使用这个ui，api文档结构更加清晰，在线调试也很方便

```xml
<dependency>
    <groupId>com.github.xiaoymin</groupId>
    <artifactId>swagger-bootstrap-ui</artifactId>
    <version>${swagger.bootstrap.ui.version}</version>
</dependency>
```

访问的url为 `/doc.html`



![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/7/29/16c3b9f061f3755e~tplv-t2oaga2asx-jj-mark:3024:0:0:0:q75.awebp)



# Swagger分组

Swagger的分组接口是通过后端配置不同的扫描包，将后端的接口，按配置的扫描包基础属性响应给前端

后端java的配置如下，指定分组名和各自要扫描的包

```java
@Bean(value = "defaultApi")
public Docket defaultApi() {
    return new Docket(DocumentationType.SWAGGER_2)
        .apiInfo(apiInfo())
        .groupName("默认接口")
        .select()
        .apis(RequestHandlerSelectors.basePackage("com.example.demo.controller"))
        .paths(PathSelectors.any())
        .build();
}
@Bean(value = "groupApi")
public Docket groupRestApi() {
    return new Docket(DocumentationType.SWAGGER_2)
        .apiInfo(groupApiInfo())
        .groupName("分组接口")
        .select()
        .apis(RequestHandlerSelectors.basePackage("com.example.demo.group"))
        .paths(PathSelectors.any())
        .build();
}
```

分组信息的接口为 `/swagger-resources`

```properties
[
    {
        "name": "分组接口",
        "url": "/v2/api-docs?group=分组接口",
        "swaggerVersion": "2.0",
        "location": "/v2/api-docs?group=分组接口"
    },{
        "name": "默认接口",
        "url": "/v2/api-docs?group=默认接口",
        "swaggerVersion": "2.0",
        "location": "/v2/api-docs?group=默认接口"
    }
]
```

在swagger-ui中也可以通过分组来查看api文档



![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/7/29/16c3b9f053420aa5~tplv-t2oaga2asx-jj-mark:3024:0:0:0:q75.awebp)



