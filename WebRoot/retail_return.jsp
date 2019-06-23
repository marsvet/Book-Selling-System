<%@ page language="java"
	import="java.util.*, models.ManagerDao, org.json.JSONArray, org.json.JSONObject"
	pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<%
	String mname = null;
	String passwd = null;
	Cookie[] cookies = request.getCookies(); // 获取 cookies

	if (cookies == null) { // 如果没有 cookies，重定向到 index.jsp
		response.sendRedirect("index.jsp");
		return;
	}

	for (int i = 0; i < cookies.length; i++) { // 获取 cookies 中的 mname 和 passwd
		if ("mname".equals(cookies[i].getName()))
			mname = cookies[i].getValue();
		if ("passwd".equals(cookies[i].getName()))
			passwd = cookies[i].getValue();
	}

	if (mname != null && passwd != null) {
		ManagerDao managerDao = new ManagerDao();

		String managerJsonString = managerDao.search_manager(new String[]{"PASSWD"}, "MNAME", mname, -1);
		JSONArray managerJsonArray = new JSONArray(managerJsonString);
		if (managerJsonArray.length() != 1) { // 如果找不到该用户名，重定向到 index.jsp
			response.sendRedirect("index.jsp");
			return;
		}
		JSONObject managerJsonObject = managerJsonArray.getJSONObject(0);
		if (!passwd.equals(managerJsonObject.getString("PASSWD"))) { // 如果 passwd 与数据库中的 passwd 不相同，重定向到 index.jsp
			response.sendRedirect("index.jsp");
			return;
		}
	} else // 如果没有指定 cookie，重定向页面到 index.jsp
		response.sendRedirect("index.jsp");
%>

<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8" />
<title>图书销售系统 | 零售退货</title>
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
			<img src="images/logo-line.png"> 图书销售系统
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
			<span>流水号</span> <input type="text" /> <span>会员姓名</span> <input
				type="text" />
			<button type="button" class="confirm">确定</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="success-message">
			<img src="images/completed.png"> <span>退货成功</span>
		</div>
		<div class="fail-message">
			<img src="images/error.png"> <span>请检查流水号和会员姓名是否填写正确</span>
		</div>
	</div>
</body>
</html>
