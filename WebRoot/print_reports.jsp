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
<title>图书销售系统 | 打印报表</title>
<link rel="stylesheet" href="css/style.css" />
<style>
#layer, #print-window {
	display: block;
}

#print-option {
	font-size: 0;
	text-align: center;
	margin-bottom: 30px;
}

#print-option button {
	border: none;
	padding: 10px 15px;
	background-color: rgb(209, 228, 233);
	width: 150px;
}

#print-option button:nth-child(1) {
	border-radius: 15px 0 0 15px;
	background-color: #7879bb;
}

#print-option button:nth-child(3) {
	border-radius: 0 15px 15px 0;
}
</style>
<script src="js/main.js"></script>
<script>
	window.onload = function() {
		var printOptionButton = document.querySelectorAll("#print-option>button");
		for (var i = 0; i < printOptionButton.length; i++) {
			printOptionButton[i].onclick = showTable;
			printOptionButton[i].mark = i; // 做一个标记，方便调用 showTable 时判断是哪一个按钮
		}
		printOptionButton[0].click(); // 模拟点击第一个按钮以调用 showTable 函数。
	};

	function showTable() {
		var printOptionButton = document.querySelectorAll("#print-option>button");
		for (var i = 0; i < printOptionButton.length; i++) {
			printOptionButton[i].style.backgroundColor = "rgb(209, 228, 233)";
		}
		this.style.backgroundColor = "#7879bb";

		var mark = this.mark;
		var xmlHttpRequest = new XMLHttpRequest();
		xmlHttpRequest.open("POST", "Get_reports", true);
		xmlHttpRequest.setRequestHeader(
			"Content-Type",
			"application/x-www-form-urlencoded"
		);
		xmlHttpRequest.send("option=" + mark);
		xmlHttpRequest.onreadystatechange = function() {
			if (
				xmlHttpRequest.readyState == 4 &&
				xmlHttpRequest.status == 200 &&
				xmlHttpRequest.responseText != "0" // "0" 代表获取数据时出错了
			) {
				var tableWindow = document.querySelector("#print-window>.table-window");
				var jsonObj = JSON.parse(xmlHttpRequest.responseText);

				if (mark == 0) {
					var tableHtml = '<table><tr><th>流水号</th><th>ISBN</th><th>会员 ID</th><th>售出日期</th><th>售价</th><th>数量</th><th>是否有效</th></tr>';
					for (var i = 0; i < jsonObj.length && i < 15; i++)
						tableHtml += '<tr><td>' + jsonObj[i]["SERIAL_NUMBER"]
							+ '</td><td>' + jsonObj[i]["ISBN"]
							+ '</td><td>' + jsonObj[i]["MEMBER_ID"]
							+ '</td><td>' + jsonObj[i]["DATE_OF_SALE"]
							+ '</td><td>' + jsonObj[i]["PRICE"]
							+ '</td><td>' + jsonObj[i]["QUANTITY"]
							+ '</td><td>' + jsonObj[i]["IS_VALID"]
							+ '</td></tr>';
					tableHtml += '</table>';
					tableWindow.innerHTML = tableHtml;
				} else if (mark == 1) {
					var tableHtml = '<table><tr><th>流水号</th><th>ISBN</th><th>出版社 ID</th><th>进货日期</th><th>进价</th><th>数量</th></tr>';
					for (var i = 0; i < jsonObj.length && i < 15; i++)
						tableHtml += '<tr><td>' + jsonObj[i]["SERIAL_NUMBER"]
							+ '</td><td>' + jsonObj[i]["ISBN"]
							+ '</td><td>' + jsonObj[i]["PUBLISHER_ID"]
							+ '</td><td>' + jsonObj[i]["DATE_OF_PURCHASE"]
							+ '</td><td>' + jsonObj[i]["UNIT_PRICE"]
							+ '</td><td>' + jsonObj[i]["PCOUNT"]
							+ '</td></tr>';
					tableHtml += '</table>';
					tableWindow.innerHTML = tableHtml;
				} else {
					var tableHtml = '<table><tr><th>姓名</th><th>电话号码</th><th>身份证号码</th><th>会员组</th><th>购书数量</th><th>余额</th><th>状态</th></tr>';
					for (var i = 0; i < jsonObj.length && i < 15; i++) {
						tableHtml += '<tr><td>' + jsonObj[i]["MNAME"]
							+ '</td><td>' + jsonObj[i]["PHONE_NUMBER"]
							+ '</td><td>' + jsonObj[i]["IDENTIFICATION_NUMBER"]
							+ '</td><td>' + jsonObj[i]["MGNAME"]
							+ '</td><td>' + jsonObj[i]["BOOK_PURCHASE"]
							+ '</td><td>' + jsonObj[i]["BALANCE"]
							+ '</td><td>';
						if (jsonObj[i]["STATUS"] == 1)
							tableHtml += '正常</td></tr>'
						else
							tableHtml += '已挂失</td></tr>'
					}
					tableHtml += '</table>';
					tableWindow.innerHTML = tableHtml;
				}
			}
		};
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
				<li class="current">打印报表</li>
			</div>
			<div>
				<li>系统设置</li>
				<li>备份与恢复</li>
			</div>
		</ul>
	</nav>
	<div id="layer">
		<div id="print-window">
			<div id="print-option">
				<button type="button">图书销售单</button>
				<button type="button">图书进退货单</button>
				<button type="button">会员列表</button>
			</div>
			<div class="table-window"></div>
		</div>
		<div class="success-message">
			<img src="images/completed.png"> <span>打印成功</span>
		</div>
		<div class="fail-message">
			<img src="images/error.png"> <span>打印失败</span>
		</div>
	</div>
</body>
</html>
