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
<title>图书销售系统 | 图书出售</title>
<link rel="stylesheet" href="css/style.css" />
<style>
#window button {
	margin-left: auto;
	margin-right: auto;
}
</style>
<script src="js/main.js"></script>
<script>
	window.onload = function() {
		var layer = document.getElementById("layer");
		var theWindow = layer.querySelector("#window");
		var oButton = theWindow.querySelector("button");
		var retailReturnMessage = layer.querySelector("#retail-return-message");

		layer.style.display = "block";
		theWindow.style.display = "block";

		oButton.onclick = function() {
			var oInput = theWindow.querySelectorAll("input");

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Retail_return", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"serial_number=" + oInput[0].value + "&mname=" + oInput[1].value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					if (xmlHttpRequest.responseText == 1) {
						retailReturnMessage.innerHTML = '<embed src="images/completed.svg" type="image/svg+xml" />退货成功';
						theWindow.style.display = "none";
						retailReturnMessage.style.display = "block";
						setTimeout(function() {
							history.back(-1);
						}, 1000);
					} else {
						retailReturnMessage.innerHTML = '<embed src="images/failed.svg" type="image/svg+xml" />请检查流水号和会员姓名是否填写正确';
						theWindow.style.display = "none";
						retailReturnMessage.style.display = "block";
						setTimeout(function() {
							retailReturnMessage.style.display = "none";
							theWindow.style.display = "block";
						}, 1500);
					}
				}
			};
		};
	};
</script>
</head>
<body>
	<header>
		<h1>
			<embed src="images/logo-line.svg" type="image/svg+xml" />
			图书销售系统
		</h1>
		<input type="text" name="search_input" id="search_input" disabled />
		<button type="button" id="select" disabled>查询</button>
	</header>
	<nav>
		<ul>
			<div>
				<li>图书出售</li>
				<li class="current">零售退货</li>
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
				<li>备份与恢复</li>
			</div>
		</ul>
	</nav>
	<div id="layer">
		<div id="window">
			<h1>输入小票信息</h1>
			<span>流水号</span> <input type="text" /> <span>会员姓名</span> <input
				type="text" />
			<button type="button">确认退货</button>
		</div>
		<div id="retail-return-message"></div>
	</div>
</body>
</html>
