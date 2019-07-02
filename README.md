# Book selling system

数据库课程设计代码及数据库备份

## Introduction

该系统为书店设计，用户主要有书店的柜台销售人员、书籍和信息管理人员以及系统操作员。系统包含以下功能：

1. **图书检索**：可以使用 ISBN、书名、作者、出版社等多种方式查找图书，并提供模糊查询的功能。

2. **图书零售购买**：顾客购书后收银台进行结账。不同等级的会员享有不同的折扣。输入需要购买的图书和数量、会员的电话号码和密码，计算出总金额，并打印销售小票作为销售的单据。

3. **图书零售退货**：顾客对已购买的图书进行退货。需要提供图书和销售小票作为购买凭证。系统查询数据库进行数据验证，对符合要求的图书进行退货。

4. **图书资料修改**：修改图书的 ISBN、书名、作者、出版社、零售价、进价等信息。

5. **图书进退货**：从出版社进货、退货、再进货图书，并计算金额。

6. **会员查找**：可以使用姓名、电话、身份证号等多种方式查找会员，并提供模糊查询的功能。

7. **会员添加**：添加新的会员，同时登记会员的基本信息、设置密码、指定会员组等。

8. **会员资料修改**：修改会员的姓名、电话、身份证号等信息。

9. **会员密码修改**：修改会员的密码。

10. **会员充值**：向会员的虚拟账户充值。

11. **会员挂失与解挂**：将会员的虚拟账户挂失或解挂，已挂失的会员无法购书。

12. **会员删除**：删除已存在的会员。

13. **查看会员最近购书记录**：从数据库中检索出会员最近的购书记录并显示。

14. **出版社管理**：添加、删除、修改出版社、查询出版社的资料。

15. **会员组管理**：添加、删除、查询会员组，修改会员组名、享有的折扣等信息。

16. **报表处理**：显示和打印图书销售单、图书进退货单、会员列表等报表。

17. **管理员管理**：添加、删除、修改系统操作员、为相应的操作员设置其控制权限、修改系统操作员的密码等。

18. **权限验证**：访问某个页面时验证系统操作员的权限，不同权限的操作员能访问的页面不同。

功能模块图：

![功能模块图](https://raw.githubusercontent.com/marsvet/Book_selling_system/master/assets/function_diagram.png)

数据库设计图：

![数据库设计图](https://raw.githubusercontent.com/marsvet/Book_selling_system/master/assets/db_diagram.png)

## 开发及运行环境

**开发工具**：eclipse，sql developer

**jdk 版本**：jdk1.8

**tomcat 版本**：tomcat 8.0 及以上

**数据库**：oracle 12c r2

## Usage

1. 恢复数据库

   - 创建一个用户，用户名密码随意，分配 **DBA** 角色。

   - 打开终端，输入命令：

   ```bash
   imp file='备份文件路径' FULL=Y
   ```

2. 运行系统

   - 导入项目：打开 eclipse，点击 file -> import，选择 Existing Projects into Workspace。

   - 修改项目属性：右键点击项目，点击 Properties，选择 Projects Facets，在 dynamic web module 前打钩，并将 jdk 版本改为 **1.8**。

   - 右键点击 WebContent/WEB-INF/lib/servlet-api.jar，选择 build path。

   - 将项目加入 tomcat 并启动 tomcat，访问 http://localhost:8080/Book_selling_system/。

## Screenshots

![登录页](https://raw.githubusercontent.com/marsvet/Book_selling_system/master/assets/screenshots1.png)

![图书管理页](https://raw.githubusercontent.com/marsvet/Book_selling_system/master/assets/screenshots2.png)

## TODO

- [ ] 根据会员充值金额提升其会员组等级

- [ ] “查看会员最近购书记录功能” 分页

- [ ] 系统所有日期时间信息精确到 “秒”

## License

This project is [MIT](https://github.com/marsvet/Book_selling_system/blob/master/LICENSE) Licensed.