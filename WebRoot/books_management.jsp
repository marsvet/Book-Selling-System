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
				mname);
		JSONArray managerJsonArray = new JSONArray(managerJsonString);
		if (managerJsonArray.length() != 1) {		// 如果找不到该用户名，重定向到 index.jsp
			response.sendRedirect("index.jsp");
			return;
		}
		JSONObject managerJsonObject = managerJsonArray.getJSONObject(0);
		if (!passwd.equals(managerJsonObject.getString("PASSWD"))) {	// 如果 passwd 与数据库中的 passwd 不相同，重定向到 index.jsp
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
<title>图书销售系统 | 图书管理</title>
<link rel="stylesheet" href="css/style.css" />
<style>
#result li .column4 {
	position: relative;
	top: 20px;
}
</style>
<script src="js/main.js"></script>
<script>
	window.onload = function() {
		/* search(); // 直接显示所有书籍 */

		var searchInput = document.getElementById("search_input");
		var selectButton = document.getElementById("select");
		var oLi = document.querySelectorAll("nav>ul li");
		var addButton = document.querySelector(".add");

		for (var i = 0; i < oLi.length; i++) {
			oLi[i].onclick = redirect;
		}

		selectButton.onclick = search;
		searchInput.onkeypress = function(eOb) {
			if (eOb.keyCode == 13)
				// 判断是否为回车键
				search();
		};

		addButton.onclick = addBook;
	};

	function search() {
		var searchInput = document.getElementById("search_input");
		var value = searchInput.value;

		var xmlHttpRequest = new XMLHttpRequest();

		xmlHttpRequest.open("POST", "Book_search", true);
		xmlHttpRequest.setRequestHeader(
			"Content-Type",
			"application/x-www-form-urlencoded"
		);
		if (value)
			xmlHttpRequest.send("value=" + value);
		else
			xmlHttpRequest.send("value=ALL");
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
					liHTML += '</div><div class="column4"><button type="button" class="return-book-button">退货</button><br><button type="button" class="restock-button">再进货</button><br><button type="button" class="modify-info-button">资料修改</button></div></li>';

					oUl.innerHTML += liHTML;
				}
				var returnBookButton = document.getElementsByClassName("return-book-button");
				for (var j = 0; j < returnBookButton.length; j++)
					returnBookButton[j].onclick = returnBook;
				var restockButton = document.getElementsByClassName("restock-button");
				for (var j = 0; j < restockButton.length; j++)
					restockButton[j].onclick = restock;
				var modifyInfoButton = document.getElementsByClassName("modify-info-button");
				for (var j = 0; j < modifyInfoButton.length; j++)
					modifyInfoButton[j].onclick = modifyInfo;
			}
		};
	}

	function addBook() {
		var layer = document.getElementById("layer");
		var addWindow = layer.querySelector("#add-book");
		var oInput = addWindow.querySelectorAll("input");
		var confirmButton = addWindow.querySelector(".confirm");
		var cancelButton = addWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		layer.style.display = "block";
		addWindow.style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			addWindow.style.display = "none";
		}

		confirmButton.onclick = function() {
			for (var i = 0; i < oInput.length; i++)
				if (!oInput[i].value)
					return;

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Book_insert", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"ISBN=" + oInput[0].value + "&title=" + oInput[1].value + "&author=" + oInput[2].value
				+ "&quantity=" + oInput[3].value + "&retail_price=" + oInput[4].value + "&publisher=" + oInput[5].value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					if (xmlHttpRequest.responseText == "1") {
						var oSpan = successMessage.querySelector("span");
						oSpan.innerHTML = "进货成功";
						addWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							successMessage.style.display = "none";
							layer.style.display = "none";
						}, 1000);
					} else {
						var oSpan = failMessage.querySelector("span");
						oSpan.innerHTML = "进货失败";
						addWindow.style.display = "none";
						failMessage.style.display = "block";
						setTimeout(function() {
							failMessage.style.display = "none";
							addWindow.style.display = "block";
						}, 2000);
					}
				}
			};
		}
	}

	function returnBook() {
		var currentItem = this.parentElement.parentElement;
		var ISBN = currentItem.querySelector(".column1>p:nth-child(4)").innerHTML;
		ISBN = ISBN.slice(5, ISBN.length);
		var publisher = currentItem.querySelector(".column1>p:nth-child(3)").innerHTML;
		publisher = publisher.slice(4, publisher.length);

		var layer = document.getElementById("layer");
		var returnBookWindow = layer.querySelector("#return-book");
		var confirmButton = returnBookWindow.querySelector(".confirm");
		var cancelButton = returnBookWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		layer.style.display = "block";
		returnBookWindow.style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			returnBookWindow.style.display = "none";
		}

		confirmButton.onclick = function() {
			var oInput = document.querySelector("#return-book>input");

			if (!oInput.value)
				return;

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Book_modify", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"option=1&ISBN=" + ISBN + "&publisher=" + publisher + "&quantity=-" + oInput.value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					if (xmlHttpRequest.responseText == "1") {
						var oSpan = successMessage.querySelector("span");
						oSpan.innerHTML = "退货成功";
						returnBookWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							successMessage.style.display = "none";
							layer.style.display = "none";
						}, 1000);

						/* 前端同步更新 */
						var inventoryItem = currentItem.querySelector(".column3>p:first-child");
						inventoryItem.innerHTML = Number(inventoryItem.innerHTML) - Number(oInput.value);
					} else {
						var oSpan = failMessage.querySelector("span");
						oSpan.innerHTML = "退货失败";
						returnBookWindow.style.display = "none";
						failMessage.style.display = "block";
						setTimeout(function() {
							failMessage.style.display = "none";
							returnBookWindow.style.display = "block";
						}, 2000);
					}
				}
			};
		}
	}

	function restock() {
		var currentItem = this.parentElement.parentElement;
		var ISBN = currentItem.querySelector(".column1>p:nth-child(4)").innerHTML;
		ISBN = ISBN.slice(5, ISBN.length);
		var publisher = currentItem.querySelector(".column1>p:nth-child(3)").innerHTML;
		publisher = publisher.slice(4, publisher.length);

		var layer = document.getElementById("layer");
		var restockWindow = layer.querySelector("#restock");
		var confirmButton = restockWindow.querySelector(".confirm");
		var cancelButton = restockWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		layer.style.display = "block";
		restockWindow.style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			restockWindow.style.display = "none";
		}

		confirmButton.onclick = function() {
			var oInput = document.querySelector("#restock>input");

			if (!oInput.value)
				return;

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Book_modify", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"option=2&ISBN=" + ISBN + "&publisher=" + publisher + "&quantity=" + oInput.value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					if (xmlHttpRequest.responseText == "1") {
						var oSpan = successMessage.querySelector("span");
						oSpan.innerHTML = "进货成功";
						restockWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							successMessage.style.display = "none";
							layer.style.display = "none";
						}, 1000);

						/* 前端同步更新 */
						var inventoryItem = currentItem.querySelector(".column3>p:first-child");
						inventoryItem.innerHTML = Number(inventoryItem.innerHTML) + Number(oInput.value);
					} else {
						var oSpan = failMessage.querySelector("span");
						oSpan.innerHTML = "进货失败";
						restockWindow.style.display = "none";
						failMessage.style.display = "block";
						setTimeout(function() {
							failMessage.style.display = "none";
							restockWindow.style.display = "block";
						}, 2000);
					}
				}
			};
		}
	}

	function modifyInfo() {
		var currentItem = this.parentElement.parentElement;
		var title = currentItem.querySelector(".column1>h1").innerHTML;
		var author = currentItem.querySelector(".column1>p:nth-child(2)").innerHTML;
		author = author.slice(3, author.length);
		var publisher = currentItem.querySelector(".column1>p:nth-child(3)").innerHTML;
		publisher = publisher.slice(4, publisher.length);
		var ISBN = currentItem.querySelector(".column1>p:nth-child(4)").innerHTML;
		ISBN = ISBN.slice(5, ISBN.length);
		var retail_price = currentItem.querySelector(".column3>p:nth-child(2)").innerHTML;

		var layer = document.getElementById("layer");
		var modifyWindow = layer.querySelector("#modify-information");
		var oInput = modifyWindow.querySelectorAll("input");
		var confirmButton = modifyWindow.querySelector(".confirm");
		var cancelButton = modifyWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		oInput[0].value = ISBN;
		oInput[1].value = title;
		oInput[2].value = author;
		oInput[3].value = publisher;
		oInput[4].value = retail_price;
		layer.style.display = "block";
		modifyWindow.style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			modifyWindow.style.display = "none";
		}

		confirmButton.onclick = function() {
			for (var i = 0; i < oInput.length; i++)
				if (!oInput[i].value)
					return;

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Book_modify", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"option=3&ISBN=" + ISBN + "&new_ISBN=" + oInput[0].value +
				"&title=" + oInput[1].value + "&author=" + oInput[2].value + 
				"&publisher=" + oInput[3].value + "&retail_price=" + oInput[4].value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					if (xmlHttpRequest.responseText == "1") {
						var oSpan = successMessage.querySelector("span");
						oSpan.innerHTML = "修改成功";
						modifyWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							successMessage.style.display = "none";
							layer.style.display = "none";
						}, 1000);

						/* 前端同步更新 */
						currentItem.querySelector(".column1>h1").innerHTML = oInput[1].value;
						currentItem.querySelector(".column1>p:nth-child(2)").innerHTML = "作者：" + oInput[2].value;
						currentItem.querySelector(".column1>p:nth-child(3)").innerHTML = "出版社：" + oInput[3].value;
						currentItem.querySelector(".column1>p:nth-child(4)").innerHTML = "ISBN：" + oInput[0].value;
						currentItem.querySelector(".column3>p:nth-child(2)").innerHTML = oInput[4].value;
					} else {
						var oSpan = failMessage.querySelector("span");
						oSpan.innerHTML = "修改失败";
						modifyWindow.style.display = "none";
						failMessage.style.display = "block";
						setTimeout(function() {
							failMessage.style.display = "none";
							modifyWindow.style.display = "block";
						}, 2000);
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
			<img src="images/logo-line.png">
			图书销售系统
		</h1>
		<input type="text" name="search_input" id="search_input"
			placeholder="输入书名、作者、ISBN 或 出版社" />
		<button type="button" id="select">查询</button>
	</header>
	<nav>
		<ul>
			<div>
				<li>图书出售</li>
				<li>零售退货</li>
				<li>会员管理</li>
			</div>
			<div>
				<li class="current">图书管理</li>
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
		<button type="button" class="add">＋ 新书进货</button>
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
		<div class="form-window" id="add-book">
			<h1>新书进货</h1>
			<span>ISBN</span> <input type="text" /> <span>书名</span> <input
				type="text" /> <span>作者</span> <input type="text" /> <span>进货数量</span>
			<input type="number" /> <span>零售价</span> <input type="text" /> <span>出版社</span>
			<input type="text" />
			<button type="button" class="confirm">确定</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="return-book">
			<span>数量</span> <input type="number" min="1" />
			<button type="button" class="confirm">确定</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="restock">
			<span>数量</span> <input type="number" min="1" />
			<button type="button" class="confirm">确定</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="modify-information">
			<h1>图书资料修改</h1>
			<span>ISBN</span> <input type="text" /> <span>书名</span> <input
				type="text" /> <span>作者</span> <input type="text" /><span>出版社</span>
			<input type="text" /><span>零售价</span> <input type="text" />
			<button type="button" class="confirm">修改</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="success-message">
			<img src="images/completed.png">
			<span></span>
		</div>
		<div class="fail-message">
			<img src="images/error.png">
			<span></span>
		</div>
	</div>
</body>
</html>
