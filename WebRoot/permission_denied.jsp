<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>

<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8" />
<title>您无权访问该页面！</title>
<link rel="stylesheet" href="css/style.css" />
<script>
	window.onload = function() {
		var layer = document.getElementById("layer");
		var failMessage = layer.querySelector(".fail-message");

		layer.style.display = "block";
		failMessage.style.display = "block";

		setTimeout(function() {
			history.back(-1);
		}, 1500)
	}
</script>
</head>
<body>
	<header>
		<h1>
			<img src="images/logo-line.png"> 图书销售系统
		</h1>
		<input type="text" name="search_input" id="search_input" disabled />
		<button type="button" id="select" disabled>查询</button>
	</header>
	<nav>
		<ul>
			<div>
				<li>图书出售</li>
				<li>零售退货</li>
				<li>会员管理</li>
			</div>
			<div>
				<li>图书管理</li>
				<li>出版社管理</li>
				<li>会员组管理</li>
				<li>打印报表</li>
			</div>
			<div>
				<li>系统设置</li>
			</div>
		</ul>
	</nav>
	<div id="layer">
		<div class="fail-message">
			<img src="images/error.png"> <span>您无权访问该页面！</span>
		</div>
	</div>
</body>
</html>
