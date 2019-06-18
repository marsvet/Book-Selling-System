<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>

<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8
" />
<title>图书销售系统 | 系统设置</title>
<link rel="stylesheet" href="css/style.css" />
<style>
#result li .column4 {
	position: relative;
	top: 30px;
	width: 25%;
	min-width: 160px;
}

#result li .column1 {
	width: 50%;
}
</style>
<script src="js/main.js"></script>
<script>
	window.onload = function() {
		search();

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

		addButton.onclick = addManager;
	};

	function search() {
		var searchInput = document.getElementById("search_input");
		var value = searchInput.value;

		var xmlHttpRequest = new XMLHttpRequest();
		xmlHttpRequest.open("POST", "Manager_search", true);
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

					liHTML += jsonObj[i]["MNAME"] + "</h1>";
					liHTML += "<p>电话号码：" + jsonObj[i]["PHONE_NUMBER"] + "</p>";
					liHTML += "<p>身份证号码：" +
						jsonObj[i]["IDENTIFICATION_NUMBER"] +
						"</p>";
					liHTML += '</div><div class="column2">';
					liHTML += "<p>管理员ID：" + "</p>";
					liHTML += "<p>权限：" + "</p>";
					liHTML += '</div><div class="column3">';
					liHTML += "<p>" + jsonObj[i]["MID"] + "</p>";
					liHTML += "<p>" + jsonObj[i]["PERMISSION"] + "</p>";
					liHTML += '</div><div class="column4"><button type="button" class="modify-info-button">修改资料</button><button type="button" class="delete-button">删除</button><br><button type="button" class="modify-password-button">修改密码</button><button type="button" class="modify-permission-button">修改权限</button></div></li>';

					oUl.innerHTML += liHTML;
				}
				var modifyInfoButton = document.getElementsByClassName("modify-info-button");
				for (var j = 0; j < modifyInfoButton.length; j++)
					modifyInfoButton[j].onclick = modifyInfo;
				var modifyPasswordButton = document.getElementsByClassName("modify-password-button");
				for (var j = 0; j < modifyPasswordButton.length; j++)
					modifyPasswordButton[j].onclick = modifyPassword;
				var modifyPermissionButton = document.getElementsByClassName("modify-permission-button");
				for (var j = 0; j < modifyPermissionButton.length; j++)
					modifyPermissionButton[j].onclick = modifyPermission;
				var deleteButton = document.getElementsByClassName("delete-button");
				for (var j = 0; j < deleteButton.length; j++)
					deleteButton[j].onclick = deleteManager;
			}
		};
	}

	function addManager() {
		var layer = document.getElementById("layer");
		var addWindow = layer.querySelector("#add-manager");
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

			var oSpan = failMessage.querySelector("span");
			if (oInput[4].value != oInput[5].value) {
				oSpan.innerHTML = "两次输入的密码不一致";
				addWindow.style.display = "none";
				failMessage.style.display = "block";
				setTimeout(function() {
					failMessage.style.display = "none";
					addWindow.style.display = "block";
				}, 2000);
				return;
			}

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Manager_insert", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"mname=" + oInput[0].value + "&phone_number=" + oInput[1].value + "&identification=" + oInput[2].value + "&permission=" + oInput[3].value + "&password=" + oInput[4].value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					if (xmlHttpRequest.responseText == "1") {
						oSpan = successMessage.querySelector("span");
						oSpan.innerHTML = "添加成功";
						addWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							successMessage.style.display = "none";
							layer.style.display = "none";
						}, 1000);
					} else {
						oSpan = failMessage.querySelector("span");
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
		var mname = currentItem.querySelector(".column1>h1").innerHTML;
		var phoneNumber = currentItem.querySelector(".column1>p:nth-child(2)").innerHTML;
		phoneNumber = phoneNumber.slice(5, phoneNumber.length);
		var identification = currentItem.querySelector(".column1>p:nth-child(3)").innerHTML;
		identification = identification.slice(6, identification.length);

		var layer = document.getElementById("layer");
		var modifyWindow = layer.querySelector("#modify-information");
		var oInput = modifyWindow.querySelectorAll("input");
		var confirmButton = modifyWindow.querySelector(".confirm");
		var cancelButton = modifyWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		oInput[0].value = mname;
		oInput[1].value = phoneNumber;
		oInput[2].value = identification;
		layer.style.display = "block";
		modifyWindow.style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			modifyWindow.style.display = "none";
		}

		confirmButton.onclick = function() {
			if (!oInput[0].value || !oInput[1].value || !oInput[2].value)
				return;

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Manager_modify", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"option=1&phone_number=" + phoneNumber + "&mname=" + oInput[0].value +
				"&new_phone_number=" + oInput[1].value + "&identification=" + oInput[2].value
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

	function modifyPassword() {
		var currentItem = this.parentElement.parentElement;
		var phoneNumber = currentItem.querySelector(".column1>p:nth-child(2)").innerHTML;
		phoneNumber = phoneNumber.slice(5, phoneNumber.length);

		var layer = document.getElementById("layer");
		var modifyWindow = layer.querySelector("#modify-password");
		var oInput = modifyWindow.querySelectorAll("input");
		var confirmButton = modifyWindow.querySelector(".confirm");
		var cancelButton = modifyWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		layer.style.display = "block";
		modifyWindow.style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			modifyWindow.style.display = "none";
		}

		confirmButton.onclick = function() {
			if (!oInput[0].value || !oInput[1].value)
				return;

			var oSpan = failMessage.querySelector("span");
			if (oInput[0].value != oInput[1].value) {
				oSpan.innerHTML = "两次输入的密码不一致";
				modifyWindow.style.display = "none";
				failMessage.style.display = "block";
				setTimeout(function() {
					failMessage.style.display = "none";
					modifyWindow.style.display = "block";
				}, 2000);
				return;
			}

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Manager_modify", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"option=2&phone_number=" + phoneNumber + "&password=" + oInput[0].value
			);
			xmlHttpRequest.onreadystatechange = function() {
				if (
					xmlHttpRequest.readyState == 4 &&
					xmlHttpRequest.status == 200
				) {
					if (xmlHttpRequest.responseText == "1") {
						oSpan = successMessage.querySelector("span");
						oSpan.innerHTML = "修改成功";
						modifyWindow.style.display = "none";
						successMessage.style.display = "block";
						setTimeout(function() {
							successMessage.style.display = "none";
							layer.style.display = "none";
						}, 1000);
					} else {
						oSpan = failMessage.querySelector("span");
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

	function modifyPermission() {
		var currentItem = this.parentElement.parentElement;
		var phoneNumber = currentItem.querySelector(".column1>p:nth-child(2)").innerHTML;
		phoneNumber = phoneNumber.slice(5, phoneNumber.length);

		var layer = document.getElementById("layer");
		var modifyWindow = layer.querySelector("#modify-permission");
		var confirmButton = modifyWindow.querySelector(".confirm");
		var cancelButton = modifyWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");

		layer.style.display = "block";
		modifyWindow.style.display = "block";

		cancelButton.onclick = function() {
			layer.style.display = "none";
			modifyWindow.style.display = "none";
		}

		confirmButton.onclick = function() {
			var oInput = document.querySelector("#modify-permission>input");

			if (!oInput.value)
				return;

			var xmlHttpRequest = new XMLHttpRequest();
			xmlHttpRequest.open("POST", "Manager_modify", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"option=3&phone_number=" + phoneNumber + "&permission=" + oInput.value
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

	function deleteManager() {
		var currentItem = this.parentElement.parentElement;
		var phoneNumber = currentItem.querySelector(".column1>p:nth-child(2)").innerHTML;
		phoneNumber = phoneNumber.slice(5, phoneNumber.length);

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
			xmlHttpRequest.open("POST", "Manager_delete", true);
			xmlHttpRequest.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded"
			);
			xmlHttpRequest.send(
				"phone_number=" + phoneNumber
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
				<li>图书出售</li>
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
				<li class="current">系统设置</li>
				<li>备份与恢复</li>
			</div>
		</ul>
	</nav>
	<main>
		<button type="button" class="add">＋ 添加管理员</button>
		<div id="result">
			<ul></ul>
		</div>
	</main>
	<div id="layer">
		<div class="form-window" id="add-manager">
			<h1>添加管理员</h1>
			<span>姓名</span> <input type="text" /> <span>电话号码</span> <input
				type="text" /> <span>身份证号码</span> <input type="text" /> <span>权限</span>
			<input type="number" min="0" max="2" /> <span>密码</span> <input
				type="password" /> <span>确认密码</span> <input type="password" />
			<button type="button" class="confirm">添加</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="modify-information">
			<h1>管理员资料修改</h1>
			<span>姓名</span> <input type="text" /> <span>电话号码</span> <input
				type="text" /> <span>身份证号码</span> <input type="text" />
			<button type="button" class="confirm">修改</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="modify-password">
			<span>新密码</span> <input type="password" /> <span>确认密码</span> <input
				type="password" />
			<button type="button" class="confirm">修改</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="modify-permission">
			<span>权限</span> <input type="number" min="0" max="2" />
			<button type="button" class="confirm">修改</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="alert-window" id="delete">
			<p>
				<embed src="images/alert.svg" type="image/svg+xml" />
				确定删除该管理员吗
			</p>
			<button type="button" class="confirm">确定</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="success-message">
			<embed src="images/completed.svg" type="image/svg+xml" />
			<span></span>
		</div>
		<div class="fail-message">
			<embed src="images/failed.svg" type="image/svg+xml" />
			<span></span>
		</div>
	</div>
</body>
</html>
