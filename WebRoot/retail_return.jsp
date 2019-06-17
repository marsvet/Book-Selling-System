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
<script src="js/main.js"></script>
<script>
	window.onload = function() {
		var layer = document.getElementById("layer");
		var formWindow = layer.querySelector(".form-window");
		var confirmButton = formWindow.querySelector(".confirm");
		var cancelButton = formWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		layer.style.display = "block";
		formWindow.style.display = "block";
		
		cancelButton.onclick = function() {
			history.back(-1);
		}

		confirmButton.onclick = function() {
			var oInput = formWindow.querySelectorAll("input");
			
			if (!oInput[0].value || !oInput[1].value)
				return;

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
					if (xmlHttpRequest.responseText == "1") {
						formWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							history.back(-1);
						}, 1000);
					} else {
						formWindow.style.display = "none";
						failMessage.style.display = "block";
						setTimeout(function() {
							failMessage.style.display = "none";
							formWindow.style.display = "block";
						}, 2000);
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
		<div class="form-window">
			<h1>输入小票信息</h1>
			<span>流水号</span> <input type="text" />
			<span>会员姓名</span> <input type="text" />
			<button type="button" class="confirm">确定</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="success-message">
			<embed src="images/completed.svg" type="image/svg+xml" />
			<span>退货成功</span>
		</div>
		<div class="fail-message">
			<embed src="images/failed.svg" type="image/svg+xml" />
			<span>请检查流水号和会员姓名是否填写正确</span>
		</div>
	</div>
</body>
</html>
