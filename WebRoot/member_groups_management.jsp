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
<title>图书销售系统 | 会员组管理</title>
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
		search(); // 直接加载所有会员组

		var oLi = document.querySelectorAll("nav>ul li");
		var addButton = document.querySelector(".add");

		for (var i = 0; i < oLi.length; i++) {
			oLi[i].onclick = redirect;
		}

		addButton.onclick = addMembersGroup;
	};

	function search() {
		var xmlHttpRequest = new XMLHttpRequest();

		xmlHttpRequest.open("POST", "Members_group_search", true);
		xmlHttpRequest.setRequestHeader(
			"Content-Type",
			"application/x-www-form-urlencoded"
		);
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
					liHTML += jsonObj[i]["MNAME"] + '</h1></div><div class="column2"><p>折扣：</p></div><div class="column3"><p>' +
						jsonObj[i]["DISCOUNT"] + '</p></div><div class="column4"><button type="button" class="modify-info-button">资料修改</button><button type="button" class="delete-button">删除</button></div></li>';
					oUl.innerHTML += liHTML;
				}
				var modifyInfoButton = document.getElementsByClassName("modify-info-button");
				for (var j = 0; j < modifyInfoButton.length; j++)
					modifyInfoButton[j].onclick = modifyInfo;
				var deleteButton = document.getElementsByClassName("delete-button");
				for (var j = 0; j < deleteButton.length; j++)
					deleteButton[j].onclick = deleteMembersGroup;
			}
		};
	}

	function addMembersGroup() {
		var layer = document.getElementById("layer");
		var addWindow = layer.querySelector("#add-members-group");
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
			xmlHttpRequest.open("POST", "Members_group_insert", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"mgname=" + oInput[0].value + "&discount=" + oInput[1].value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					var returnMessage = JSON.parse(xmlHttpRequest.responseText)["message"];
					if (returnMessage === "success") {
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
						oSpan.innerHTML = returnMessage;
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
		var mpname = currentItem.querySelector(".column1>h1").innerHTML;
		var discount = currentItem.querySelector(".column3>p").innerHTML;

		var layer = document.getElementById("layer");
		var modifyWindow = layer.querySelector("#modify-information");
		var oInput = modifyWindow.querySelectorAll("input");
		var confirmButton = modifyWindow.querySelector(".confirm");
		var cancelButton = modifyWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		oInput[0].value = mpname;
		oInput[1].value = discount;
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
			xmlHttpRequest.open("POST", "Members_group_modify", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"mpname=" + mpname + "&new_mpname=" + oInput[0].value + "&discount=" + oInput[1].value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					var returnMessage = JSON.parse(xmlHttpRequest.responseText)["message"];
					if (returnMessage === "success") {
						var oSpan = successMessage.querySelector("span");
						oSpan.innerHTML = "修改成功";
						modifyWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							successMessage.style.display = "none";
							layer.style.display = "none";
						}, 1000);

						/* 前端同步更新 */
						currentItem.querySelector(".column1>h1").innerHTML = oInput[0].value;
						currentItem.querySelector(".column3>p").innerHTML = oInput[1].value;
					} else {
						var oSpan = failMessage.querySelector("span");
						oSpan.innerHTML = returnMessage;
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

	function deleteMembersGroup() {
		var currentItem = this.parentElement.parentElement;
		var mgname = currentItem.querySelector(".column1>h1").innerHTML;

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
			xmlHttpRequest.open("POST", "Members_group_delete", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"mgname=" + mgname

			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					var returnMessage = JSON.parse(xmlHttpRequest.responseText)["message"];
					if (returnMessage === "success") {
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
						oSpan.innerHTML = returnMessage;
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
				<li class="current">会员组管理</li>
				<li>打印报表</li>
			</div>
			<div>
				<li>系统设置</li>
			</div>
		</ul>
	</nav>
	<main>
		<button type="button" class="add">＋ 新建会员组</button>
		<div id="result">
			<ul></ul>
		</div>
	</main>
	<div id="layer">
		<div class="form-window" id="add-members-group">
			<h1>新建会员组</h1>
			<span>会员组名</span> <input type="text" /> <span>享有折扣</span> <input
				type="number" min="1" max="10" step="0.1" />
			<button type="button" class="confirm">添加</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="modify-information">
			<h1>修改会员组</h1>
			<span>会员组名</span> <input type="text" /> <span>享有折扣</span> <input
				type="number" min="1" max="10" step="0.1" />
			<button type="button" class="confirm">修改</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="alert-window" id="delete">
			<p>
				<img src="images/alert.png"> 确定删除该会员组吗
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
