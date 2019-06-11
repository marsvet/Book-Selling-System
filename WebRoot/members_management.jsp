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
<title>图书销售系统 | 会员管理</title>
<link rel="stylesheet" href="css/style.css" />
<style>
#result .column4 {
	position: relative;
	top: 35px;
}
</style>
<script src="js/main.js"></script>
<script>
	window.onload = function() {
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
	};

	function ajaxSearch() {
		var searchInput = document.getElementById("search_input");

		var value = searchInput.value;
		if (value) {
			var xmlHttpRequest = new XMLHttpRequest();

			xmlHttpRequest.open("POST", "Member_search", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send("value=" + value);

			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					var oUl = document.querySelector("div#result>ul");
					var jsonObj = JSON.parse(xmlHttpRequest.responseText);

					oUl.innerHTML = "";

					for (var i = 0; i < jsonObj.length; i++) {
						var liHTML = '<li><div class="column1"><h1>';

						liHTML += jsonObj[i]["MNAME"] + "</h1>";
						liHTML += "<p>电话号码：" + jsonObj[i]["PHONE_NUMBER"] + "</p>";
						liHTML += "<p>身份证号码：" + jsonObj[i]["IDENTIFICATION_NUMBER"] + "</p>";
						liHTML += "<p>会员组：" + jsonObj[i]["MGNAME"] + "</p>";
						liHTML += "<p>有效期至：" + jsonObj[i]["VALID_UNTIL"] + "</p>";
						liHTML += '</div><div class="column2">';
						liHTML += "<p>购书数量：" + "</p>";
						liHTML += "<p>余额：" + "</p>";
						liHTML += "<p>积分：" + "</p>";
						liHTML += "<p>状态：" + "</p>";
						liHTML += '</div><div class="column3">';
						liHTML += "<p>" + jsonObj[i]["BOOK_PURCHASE"] + "</p>";
						liHTML += "<p>" + jsonObj[i]["BALANCE"] + "</p>";
						liHTML += "<p>" + jsonObj[i]["INTEGRAL"] + "</p>";
						if (jsonObj[i]["STATUS"] == 1)
							liHTML += "<p>正常</p>";
						else
							liHTML += "<p>黑名单</p>";
						liHTML += '</div><div class="column4"><button type="button">充值</button><button type="button">删除</button><br><button type="button">资料修改</button><br><button type="button">挂失与特别处理</button></div></li>';

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
			placeholder="输入姓名、电话 或 身份证号" />
		<button type="button" id="select">查询</button>
	</header>
	<nav>
		<ul>
			<div>
				<li>图书检索</li>
				<li>零售退货</li>
				<li class="current">会员管理</li>
				<li>会员注册</li>
			</div>
			<div>
				<li>打印报表</li>
				<li>出版社管理</li>
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
