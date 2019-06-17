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
#result li .column4 {
	position: relative;
	top: 20px;
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
		
		addButton.onclick = addMember;
	};

	function search() {
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
						liHTML += "<p>身份证号码：" +
							jsonObj[i]["IDENTIFICATION_NUMBER"] +
							"</p>";
						liHTML += "<p>会员组：" + jsonObj[i]["MGNAME"] + "</p>";
						liHTML += '</div><div class="column2">';
						liHTML += "<p>购书数量：" + "</p>";
						liHTML += "<p>余额：" + "</p>";
						liHTML += "<p>状态：" + "</p>";
						liHTML += '</div><div class="column3">';
						liHTML += "<p>" + jsonObj[i]["BOOK_PURCHASE"] + "</p>";
						liHTML += "<p>" + jsonObj[i]["BALANCE"] + "</p>";
						if (jsonObj[i]["STATUS"] == 1)
							liHTML += "<p>正常</p>";
						else
							liHTML += "<p>黑名单</p>";
						liHTML += '</div><div class="column4"><button type="button" class="modify-info-button">修改会员资料</button><br><button type="button" class="recharge-button">充值</button><button type="button" class="report-loss-button">挂失</button><button type="button" class="delete-button">删除</button><br><button type="button" class="purchase-record-button">查看购书记录</button></div></li>';

						oUl.innerHTML += liHTML;


						var modifyInfoButton = document.getElementsByClassName("modify-info-button");
						for (var j = 0; j < modifyInfoButton.length; j++)
							modifyInfoButton[j].onclick = modifyInfo;
						var rechargeButton = document.getElementsByClassName("recharge-button");
						for (var j = 0; j < rechargeButton.length; j++)
							rechargeButton[j].onclick = recharge;
						var reportLossButton = document.getElementsByClassName("report-loss-button");
						for (var j = 0; j < reportLossButton.length; j++)
							reportLossButton[j].onclick = reportLoss;
						var deleteButton = document.getElementsByClassName("delete-button");
						for (var j = 0; j < deleteButton.length; j++)
							deleteButton[j].onclick = deleteMember;
						var purchaseRecordButton = document.getElementsByClassName("purchaseRecordButton");
						for (var j = 0; j < purchaseRecordButton.length; j++)
							purchaseRecordButton[j].onclick = searchPurchaseRecord;
					}
				}
			};
		}
	}
	
	function addMember() {
		var layer = document.getElementById("layer");
		var addWindow = layer.querySelector("#add-member");
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
	}

	function recharge() {
		var layer = document.getElementById("layer");
		var rechargeWindow = layer.querySelector("#recharge");
		var confirmButton = rechargeWindow.querySelector(".confirm");
		var cancelButton = rechargeWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");
		
		layer.style.display = "block";
		rechargeWindow.style.display = "block";
		
		cancelButton.onclick = function() {
			layer.style.display = "none";
			rechargeWindow.style.display = "none";
		}
	}

	function reportLoss() {
		var layer = document.getElementById("layer");
		var reportLossWindow = layer.querySelector("#report-loss");
		var confirmButton = reportLossWindow.querySelector(".confirm");
		var cancelButton = reportLossWindow.querySelector(".cancel");
		var successMessage = layer.querySelector(".success-message");
		var failMessage = layer.querySelector(".fail-message");
		
		layer.style.display = "block";
		reportLossWindow.style.display = "block";
		
		cancelButton.onclick = function() {
			layer.style.display = "none";
			reportLossWindow.style.display = "none";
		}
	}

	function deleteMember() {
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
	}

	function searchPurchaseRecord() {
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
				<li class="current">会员管理</li>
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
		<button type="button" class="add">＋  添加会员</button>
		<div id="result">
			<ul></ul>
		</div>
	</main>
	<div id="layer">
		<div class="form-window" id="add-member">
			<h1>会员注册</h1>
			<span>姓名</span> <input type="text" /> <span>电话号码</span> <input
				type="text" /> <span>身份证号码</span> <input type="text" />
			<button type="button" class="confirm">注册</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="modify-information">
			<h1>会员资料修改</h1>
			<span>姓名</span> <input type="text" /> <span>电话号码</span> <input
				type="text" /> <span>身份证号码</span> <input type="text" />
			<button type="button" class="confirm">修改</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="form-window" id="recharge">
			<span>金额</span> <input type="number" min="1" />
			<button type="button" class="confirm">充值</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="alert-window" id="report-loss">
			<p><embed src="images/alert.svg" type="image/svg+xml" />确定要挂失吗</p>
			<button type="button" class="confirm">确定</button>
			<button type="button" class="cancel">取消</button>
		</div>
		<div class="alert-window" id="delete">
			<p><embed src="images/alert.svg" type="image/svg+xml" />确定删除该会员吗</p>
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
