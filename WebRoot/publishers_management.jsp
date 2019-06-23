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
	var page = 1;
	var pageNumber = 0;
	var returnFirstPage = true;

	window.onload = function() {
		search();

		var searchInput = document.getElementById("search_input");
		var selectButton = document.getElementById("select");
		var oLi = document.querySelectorAll("nav>ul li");
		var addButton = document.querySelector(".add");
		var prevPage = document.getElementById("prev-page");
		var nextPage = document.getElementById("next-page");

		for (var i = 0; i < oLi.length; i++) {
			oLi[i].onclick = redirect;
		}

		selectButton.onclick = search;
		searchInput.onkeypress = function(eOb) {
			if (eOb.keyCode == 13)
				// 判断是否为回车键
				search();
		};

		addButton.onclick = addPublisher;

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

		var xmlHttpRequest = new XMLHttpRequest();
		xmlHttpRequest.open("POST", "Publisher_search", true);
		xmlHttpRequest.setRequestHeader(
			"Content-Type",
			"application/x-www-form-urlencoded"
		);

		if (returnFirstPage)
			page = 1;
		if (value)
			xmlHttpRequest.send("value=" + value + "&page=" + page);
		else
			xmlHttpRequest.send("value=ALL&page=" + page);

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
					liHTML += jsonObj[i]["PLOCATION"] + "：" + jsonObj[i]["PNAME"] +
						'</h1></div><div class="column2"><p>从此出版社购书：</p></div><div class="column3"><p>' +
						jsonObj[i]["BOOKS_NUM"] + '</p></div><div class="column4"><button type="button" class="modify-info-button">资料修改</button><button type="button" class="delete-button">删除</button></div></li>';
					oUl.innerHTML += liHTML;
				}
				var modifyInfoButton = document.getElementsByClassName("modify-info-button");
				for (var j = 0; j < modifyInfoButton.length; j++)
					modifyInfoButton[j].onclick = modifyInfo;
				var deleteButton = document.getElementsByClassName("delete-button");
				for (var j = 0; j < deleteButton.length; j++)
					deleteButton[j].onclick = deletePublisher;
			}
		};
	}

	function addPublisher() {
		var layer = document.getElementById("layer");
		var addWindow = layer.querySelector("#add-publisher");
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
			if (!oInput[0].value || !oInput[1].value)
				return;

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Publisher_insert", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"pname=" + oInput[0].value + "&plocation=" + oInput[1].value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					if (xmlHttpRequest.responseText == "1") {
						var oSpan = successMessage.querySelector("span");
						oSpan.innerHTML = "添加成功";
						addWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							successMessage.style.display = "none";
							layer.style.display = "none";
						}, 1000);
					} else {
						var oSpan = failMessage.querySelector("span");
						oSpan.innerHTML = "添加失败";
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

	function modifyInfo() {
		var currentItem = this.parentElement.parentElement;
		var info = currentItem.querySelector(".column1>h1").innerHTML;
		var plocation = info.split("：")[0];
		var pname = info.split("：")[1];

		var layer = document.getElementById("layer");
		var modifyWindow = layer.querySelector("#modify-information");
		var oInput = modifyWindow.querySelectorAll("input");
		var confirmButton = modifyWindow.querySelector(".confirm");
		var cancelButton = modifyWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		oInput[0].value = pname;
		oInput[1].value = plocation;
		layer.style.display = "block";
		modifyWindow.style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			modifyWindow.style.display = "none";
		}

		confirmButton.onclick = function() {
			if (!oInput[0].value || !oInput[1].value)
				return;

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Publisher_modify", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"pname=" + pname + "&new_pname=" + oInput[0].value + "&plocation=" + oInput[1].value
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
						currentItem.querySelector(".column1>h1").innerHTML = oInput[1].value + "：" + oInput[0].value;
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

	function deletePublisher() {
		var currentItem = this.parentElement.parentElement;
		var pname = currentItem.querySelector(".column1>h1").innerHTML.split("：")[1];

		var layer = document.getElementById("layer");
		var deleteWindow = layer.querySelector("#delete");
		var confirmButton = deleteWindow.querySelector(".confirm");
		var cancelButton = deleteWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		layer.style.display = "block";
		deleteWindow.style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			deleteWindow.style.display = "none";
		}

		confirmButton.onclick = function() {
			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Publisher_delete", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"pname=" + pname
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					if (xmlHttpRequest.responseText == "1") {
						var oSpan = successMessage.querySelector("span");
						oSpan.innerHTML = "删除成功";
						deleteWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							successMessage.style.display = "none";
							layer.style.display = "none";
						}, 1000);

						/* 前端同步更新 */
						currentItem.style.display = "none";
					} else {
						var oSpan = failMessage.querySelector("span");
						oSpan.innerHTML = "删除失败";
						deleteWindow.style.display = "none";
						failMessage.style.display = "block";
						setTimeout(function() {
							failMessage.style.display = "none";
							deleteWindow.style.display = "block";
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
			<img src="images/logo-line.png"> 图书销售系统
		</h1>
		<input type="text" name="search_input" id="search_input"
			placeholder="输入 出版社名 或 所在地" />
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
				<li>图书管理</li>
				<li class="current">出版社管理</li>
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
		<button type="button" class="add">＋ 添加出版社</button>
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
		<div class="form-window" id="add-publisher">
			<h1>添加出版社</h1>
			<span>出版社名</span> <input type="text" /> <span>出版社所在地</span> <input
				type="text" />
			<button type="button" class="confirm">添加</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="modify-information">
			<h1>出版社资料修改</h1>
			<span>出版社名</span> <input type="text" /> <span>出版社所在地</span> <input
				type="text" />
			<button type="button" class="confirm">修改</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="alert-window" id="delete">
			<p>
				<img src="images/alert.png"> 确定删除该出版社吗
			</p>
			<button type="button" class="confirm">确定</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="success-message">
			<img src="images/completed.png"> <span></span>
		</div>
		<div class="fail-message">
			<img src="images/error.png"> <span></span>
		</div>
	</div>
</body>
</html>
