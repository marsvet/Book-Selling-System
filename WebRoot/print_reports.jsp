<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8
" />
<title>图书销售系统 | 备份与恢复</title>
<link rel="stylesheet" href="css/style.css" />
<style>
#result .column4 {
	position: relative;
	top: 42px;
}
</style>
<script src="js/main.js"></script>
</head>
<body>
	<header>
		<h1>
			<img src="images/logo-line.png">
			图书销售系统
		</h1>
		<input type="text" name="search_input" id="search_input"
			placeholder="输入书名、作者、ISBN 或 出版社" />
		<button type="button" id="select">查询</button>
	</header>
	<nav>
		<ul>
			<div>
				<li>图书出售</li>
				<li>零售退货</li>
				<li>会员管理</li>
			</div>
			<li>图书管理</li>
			<li>出版社管理</li>
			<li>会员组管理</li>
			<li>打印报表</li>
			</div>
			<div>
				<li>系统设置</li>
				<li class="current">备份与恢复</li>
			</div>
		</ul>
	</nav>
	<main>
		<div id="result">
			<ul></ul>
		</div>
	</main>
</body>
</html>
