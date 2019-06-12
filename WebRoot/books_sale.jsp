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

			xmlHttpRequest.open("POST", "Book_search", true);
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

						var oButton = oUl.getElementsByClassName("sale-button");
						for (var j = 0; j < oButton.length; j++)
							oButton[j].onclick = bookSale;
					}
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
					inventory.innerHTML = Number(inventory.innerHTML) - 1;

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
			<embed src="images/logo-line.svg" type="image/svg+xml" />
			图书销售系统
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
				<li>备份与恢复</li>
			</div>
		</ul>
	</nav>
	<main>
		<div id="result">
			<ul></ul>
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
