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
<title>图书销售系统 | 出版社管理</title>
<link rel="stylesheet" href="css/style.css" />
<style>
#result .column4 {
	position: relative;
	top: 7px;
}
</style>
<script src="js/main.js"></script>
<script>
	window.onload = function() {
		var oButton = document.querySelectorAll("header>div>button");
		var searchInput = document.getElementById("search_input");
		var selectButton = document.getElementById("select");
		var oLi = document.querySelectorAll("nav>ul li");

		for (var i = 0; i < oLi.length; i++) {
			oLi[i].onclick = redirect;
		}

		selectButton.onclick = ajaxSearch;
		searchInput.onkeypress = function(eOb) {
			if (eOb.keyCode == 13)
				// 判断是否为回车键
				ajaxSearch();
		};

		for (var i = 0; i < oButton.length; i++) {
			oButton[i].onclick = function() {
				searchInput.placeholder = "按" + this.innerHTML + "查询";
				for (var j = 0; j < oButton.length; j++) {
					oButton[j].className = "";
				}
				this.className = "current";
			};
		}
	};

	function ajaxSearch() {
		var searchInput = document.getElementById("search_input");

		var key = searchInput.placeholder.slice(1, -2);
		var value = searchInput.value;

		if (value) {
			var xmlHttpRequest = new XMLHttpRequest();

			xmlHttpRequest.open("POST", "Publisher_search", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send("key=" + key + "&value=" + value);

			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					var oUl = document.querySelector("div#result>ul");
					var jsonObj = JSON.parse(xmlHttpRequest.responseText);
					var thText = [ "出版社所在地", "出版社名" ];

					oUl.innerHTML = "";

					for (var i = 0; i < jsonObj.length; i++) {
						var liHTML = '<li><div class="column1"><h1>';
						liHTML += jsonObj[i][thText[0]] +
							"：" +
							jsonObj[i][thText[1]] +
							"</h1>";
						liHTML += '</div><div class="column4"><button type="button">资料修改</button></div></li>';
						oUl.innerHTML += liHTML;
					}
				}
			};
		}
	}
</script>
</head>
<body>
	<header>
		<h1>
			<embed src="images/logo-line.svg" type="image/svg+xml" />
			图书销售系统
		</h1>
		<input type="text" name="search_input" id="search_input"
			placeholder="按出版社名查询" />
		<button type="button" id="select">查询</button>
		<span>查询依据：</span>
		<div>
			<button type="button" class="current">出版社名</button>
			<br />
			<button type="button">出版社所在地</button>
		</div>
	</header>
	<nav>
		<ul>
			<div>
				<li>图书检索</li>
				<li>零售退货</li>
				<li>会员查找</li>
				<li>会员注册</li>
			</div>
			<div>
				<li>打印报表</li>
				<li class="current">出版社管理</li>
				<li>会员组管理</li>
			</div>
			<div>
				<li>系统设置</li>
				<li>备份与恢复</li>
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
