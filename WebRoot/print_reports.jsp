<%@ page language="java"
	import="java.util.*, models.ManagerDao, org.json.JSONArray, org.json.JSONObject"
	pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<%
	int requiredPermission = 1; // 该页面需要的权限等级

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

	// 如果 mname 和 passwd 都存在，验证用户名和密码，并查找该用户名对应的权限
	if (mname != null && passwd != null) {
		ManagerDao managerDao = new ManagerDao();

		String managerJsonString = managerDao.search_manager(new String[]{"PERMISSION", "PASSWD"}, "MNAME",
				mname, -1);
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

		int permission = Integer.valueOf(managerJsonObject.getString("PERMISSION"));
		if (permission < requiredPermission) // 如果该用户名对应的权限小于此页面需要的权限，将请求转发到 permission_denied.jsp 页面以显示错误信息
			request.getRequestDispatcher("permission_denied.jsp").forward(request, response);
	} else // 如果没有指定 cookie，重定向页面到 index.jsp
		response.sendRedirect("index.jsp");
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

#pager {
	margin: 25px 0 30px 45px;
}
</style>
<script src="js/main.js"></script>
<script>
	var page = 1;
	var pageNumber = 0;
	var returnFirstPage = true;
	var option = 1;

	window.onload = function() {
		showTable();

		var printOptionButton = document.querySelectorAll("#print-option>button");
		for (var i = 0; i < printOptionButton.length; i++) {
			printOptionButton[i].mark = i + 1; // 为每个按键做一个标记
			printOptionButton[i].onclick = function() {
				for (var j = 0; j < printOptionButton.length; j++) {
					printOptionButton[j].style.backgroundColor = "rgb(209, 228, 233)";
				}
				this.style.backgroundColor = "#7879bb";

				option = this.mark;
				showTable();
			}
		}

		var prevPage = document.getElementById("prev-page");
		var nextPage = document.getElementById("next-page");
		prevPage.onclick = function() {
			if (page > 1) {
				page--;
				returnFirstPage = false;
				showTable();
				returnFirstPage = true;
			}
		}
		nextPage.onclick = function() {
			if (page < pageNumber) {
				page++;
				returnFirstPage = false;
				showTable();
				returnFirstPage = true;
			}
		}
	};

	function showTable() {
		var xmlHttpRequest = new XMLHttpRequest();
		xmlHttpRequest.open("POST", "Get_reports", true);
		xmlHttpRequest.setRequestHeader(
			"Content-Type",
			"application/x-www-form-urlencoded"
		);
		if (returnFirstPage)
			page = 1;
		xmlHttpRequest.send("option=" + option + "&page=" + page);
		xmlHttpRequest.onreadystatechange = function() {
			if (
				xmlHttpRequest.readyState == 4 &&
				xmlHttpRequest.status == 200 &&
				xmlHttpRequest.responseText != "0" // "0" 代表获取数据时出错了
			) {
				var tableWindow = document.querySelector("#print-window>.table-window");
				var oPager = document.querySelector("#pager");
				var jsonObj = JSON.parse(xmlHttpRequest.responseText);

				pageNumber = jsonObj[jsonObj.length - 1]["PAGE_SUM"];
				oPager.querySelector("span").innerHTML = page + " / " + pageNumber;
				jsonObj = jsonObj.slice(0, -1);

				if (Number(pageNumber) > 1) // 如果总页数大于 1，
					oPager.style.display = "block";
				else
					oPager.style.display = "none";

				if (option == 1) {
					var tableHtml = '<table><tr><th>流水号</th><th>ISBN</th><th>会员 ID</th><th>售出日期</th><th>售价</th><th>数量</th><th>是否有效</th></tr>';
					for (var i = 0; i < jsonObj.length && i < 10; i++)
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
				} else if (option == 2) {
					var tableHtml = '<table><tr><th>流水号</th><th>ISBN</th><th>出版社 ID</th><th>进货日期</th><th>进价</th><th>数量</th></tr>';
					for (var i = 0; i < jsonObj.length && i < 10; i++)
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
					for (var i = 0; i < jsonObj.length && i < 10; i++) {
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
			<div id="pager">
				<button type="button" id="prev-page">← 上一页</button>
				<span></span>
				<button type="button" id="next-page">下一页 →</button>
			</div>
		</div>
	</div>
</body>
</html>
