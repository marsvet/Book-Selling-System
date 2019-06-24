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
<title>图书销售系统 | 图书出售</title>
<link rel="stylesheet" href="css/style.css" />
<style>
#result .column4 {
	position: relative;
	top: 42px;
}

.information-window {
	text-align: center;
}

.information-window>h1 {
	margin-bottom: 20px;
}

.information-window button {
	margin-top: 10px;
}
</style>
<script src="js/main.js"></script>
<script>
	var page = 1; // 当前请求的页数
	var pageNumber = 0; // 总页数
	var returnFirstPage = true; // 是否将页数置为 1

	window.onload = function() {
		var searchInput = document.getElementById("search_input");
		var selectButton = document.getElementById("select");
		var oLi = document.querySelectorAll("nav>ul li");
		var prevPage = document.getElementById("prev-page"); // “上一页”按钮
		var nextPage = document.getElementById("next-page"); // “下一页”按钮

		for (var i = 0; i < oLi.length; i++) {
			oLi[i].onclick = redirect;
		}

		selectButton.onclick = search;
		searchInput.onkeypress = function(eOb) {
			if (eOb.keyCode == 13)
				// 判断是否为回车键
				search();
		};

		prevPage.onclick = function() {
			if (page > 1) {
				page--;
				returnFirstPage = false;
				search();
				returnFirstPage = true;
			}
		}
		nextPage.onclick = function() {
			if (page < pageNumber) {
				page++;
				returnFirstPage = false;
				search();
				returnFirstPage = true;
			}
		}
	};

	function search() {
		var searchInput = document.getElementById("search_input");
		var value = searchInput.value;

		if (value) {
			if (returnFirstPage)
				page = 1;

			var xmlHttpRequest = new XMLHttpRequest();

			xmlHttpRequest.open("POST", "Book_search", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send("value=" + value + "&page=" + page);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					var oUl = document.querySelector("div#result>ul");
					var oPager = document.querySelector("#pager");
					var jsonObj = JSON.parse(xmlHttpRequest.responseText);

					pageNumber = jsonObj[jsonObj.length - 1]["PAGE_SUM"];
					oPager.querySelector("span").innerHTML = page + " / " + pageNumber;
					jsonObj = jsonObj.slice(0, -1);

					if (Number(pageNumber) > 1) // 如果总页数大于 1，
						oPager.style.display = "block";
					else
						oPager.style.display = "none";

					oUl.innerHTML = "";
					for (var i = 0; i < jsonObj.length; i++) {
						var liHTML = '<li><div class="column1"><h1>';

						liHTML += jsonObj[i]["TITLE"] + "</h1>";
						liHTML += "<p>作者：" + jsonObj[i]["AUTHOR"] + "</p>";
						liHTML += "<p>出版社：" + jsonObj[i]["PNAME"] + "</p>";
						liHTML += "<p>ISBN：" + jsonObj[i]["ISBN"] + "</p>";
						liHTML += '</div><div class="column2">';
						liHTML += "<p>库存：" + "</p>";
						liHTML += "<p>零售价：" + "</p>";
						liHTML += "<p>最低折扣价：" + "</p>";
						liHTML += '</div><div class="column3">';
						liHTML += "<p>" + jsonObj[i]["INVENTORY"] + "</p>";
						liHTML += "<p>" + jsonObj[i]["RETAIL_PRICE"] + "</p>";
						liHTML += "<p>" + jsonObj[i]["LOWEST_DISCOUNT_PRICE"] + "</p>";
						liHTML += '</div><div class="column4"><button type="button" class="sale-button">出售</button></div></li>';

						oUl.innerHTML += liHTML;
					}
					var oButton = oUl.getElementsByClassName("sale-button");
					for (var j = 0; j < oButton.length; j++)
						oButton[j].onclick = bookSale;
				}
			};
		}
	}

	function bookSale() {
		var currentItem = this.parentElement.parentElement;
		var ISBN = currentItem.querySelector(".column1>p:nth-child(4)");
		var inventory = currentItem.querySelector(".column3>p:first-child");
		var layer = document.getElementById("layer");
		var oInput = layer.getElementsByTagName("input");
		var confirmButton = layer.querySelector(".confirm");
		var cancelButton = layer.querySelector(".cancel");

		layer.style.display = "block";
		layer.querySelector(".form-window").style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			layer.querySelector(".form-window").style.display = "none";
		}

		confirmButton.onclick = function() {
			if (!oInput[0].value || !oInput[1].value)
				return;

			var xmlHttpRequest = new XMLHttpRequest();

			xmlHttpRequest.open("POST", "Book_sale", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"ISBN=" +
				ISBN.innerHTML.slice(5) +
				"&phone_number=" +
				oInput[0].value +
				"&quantity=" +
				oInput[1].value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					var oDiv = document.querySelectorAll(".table-row>div:last-child");
					var jsonObj = JSON.parse(xmlHttpRequest.responseText);

					oDiv[0].innerHTML = jsonObj["SERIAL_NUMBER"];
					oDiv[1].innerHTML = jsonObj["ISBN"];
					oDiv[2].innerHTML = jsonObj["TITLE"];
					oDiv[3].innerHTML = jsonObj["AUTHOR"];
					oDiv[4].innerHTML = jsonObj["MNAME"];
					oDiv[5].innerHTML = jsonObj["UNIT_PRICE"];
					oDiv[6].innerHTML = jsonObj["QUANTITY"];
					oDiv[7].innerHTML = jsonObj["DATE_OF_SALE"];

					layer.querySelector(".form-window").style.display = "none";
					layer.querySelector(".information-window").style.display = "block";
					inventory.innerHTML = Number(inventory.innerHTML) - Number(oInput[1].value);

					var printButton = layer.querySelector(".information-window>button");
					printButton.onclick = function() {
						layer.style.display = "none";
						layer.querySelector(".information-window").style.display = "none";
					};
				}
			};
		};
	}
</script>
</head>
<body>
	<header>
		<h1>
			<img src="images/logo-line.png"> 图书销售系统
		</h1>
		<input type="text" name="search_input" id="search_input"
			placeholder="输入书名、作者、ISBN 或 出版社" />
		<button type="button" id="select">查询</button>
	</header>
	<nav>
		<ul>
			<div>
				<li class="current">图书出售</li>
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
	<main>
		<div id="result">
			<ul></ul>
		</div>
		<div id="pager">
			<button type="button" id="prev-page">← 上一页</button>
			<span></span>
			<button type="button" id="next-page">下一页 →</button>
		</div>
	</main>
	<div id="layer">
		<div class="form-window">
			<h1>填写信息</h1>
			<span>会员电话</span> <input type="text" /> <span>购书数量</span> <input
				type="number" />
			<button type="button" class="confirm">出售</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="information-window">
			<h1>销售小票</h1>
			<div class="table">
				<div class="table-row">
					<div class="table-cell">流水号：</div>
					<div class="table-cell"></div>
				</div>
				<div class="table-row">
					<div class="table-cell">ISBN：</div>
					<div class="table-cell"></div>
				</div>
				<div class="table-row">
					<div class="table-cell">书名：</div>
					<div class="table-cell"></div>
				</div>
				<div class="table-row">
					<div class="table-cell">作者：</div>
					<div class="table-cell"></div>
				</div>
				<div class="table-row">
					<div class="table-cell">会员：</div>
					<div class="table-cell"></div>
				</div>
				<div class="table-row">
					<div class="table-cell">单价：</div>
					<div class="table-cell"></div>
				</div>
				<div class="table-row">
					<div class="table-cell">数量：</div>
					<div class="table-cell"></div>
				</div>
				<div class="table-row">
					<div class="table-cell">售出日期：</div>
					<div class="table-cell"></div>
				</div>
			</div>
			<button type="button">打印</button>
		</div>
	</div>
</body>
</html>
