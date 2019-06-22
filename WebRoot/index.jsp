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
<title>图书销售系统 | 管理员登录</title>
<style>
* {
	margin: 0;
	padding: 0;
}

body {
	background: url(images/login-bg.jpg) center top no-repeat scroll;
	background-size: cover;
}

div {
	margin: 100px auto;
	width: 400px;
	text-align: center;
}

header {
	font-size: 2em;
	font-weight: bold;
}

header img {
	width: 40px;
	vertical-align: bottom;
}

main {
	background-color: rgb(250, 250, 250);
	margin-top: 30px;
	border-radius: 5px;
	box-shadow: 0 0 8px #a7a6a9;
	padding: 30px 0 50px 0;
}

main h1 {
	font-weight: normal;
	font-size: 1.2em;
	margin-bottom: 20px;
}

#mname, #passwd, #submit {
	padding: 10px;
	width: 230px;
	border: 1px gray solid;
	outline-width: 0;
	border-radius: 3px;
}

#mname:focus, #passwd:focus, #submit:hover {
	box-shadow: 0 0 5px #36c3ca;
}

#mname, #passwd {
	background-color: white;
	margin-top: 5px;
}

label {
	position: relative;
	left: -80px;
	margin-top: 10px;
	display: block;
	font-size: 0.8em;
}

#submit {
	margin-top: 50px;
	background-color: #4a65b1;
	width: 250px;
	color: white;
	font-size: 1em;
	cursor: pointer;
}

p#error {
	color: red;
	font-size: 0.8em;
	margin-top: 10px;
	display: none;
}
</style>
<script>
	window.onload = function() {
		var oButton = document.getElementById("submit");
		oButton.onclick = login;

		document.onkeypress = function(eOb) {
			if (eOb.keyCode == 13) login();
		};
	};

	function login() {
		var mname = document.getElementById("mname").value;
		var passwd = document.getElementById("passwd").value;

		var xmlHttpRequest = new XMLHttpRequest();
		xmlHttpRequest.open("POST", "Check_admin", true);
		xmlHttpRequest.setRequestHeader(
			"Content-type",
			"application/x-www-form-urlencoded"
		);
		xmlHttpRequest.send("mname=" + mname + "&" + "passwd=" + passwd);

		xmlHttpRequest.onreadystatechange = function() {
			if (xmlHttpRequest.readyState == 4 && xmlHttpRequest.status == 200) {
				if (xmlHttpRequest.responseText == "1") {
					document.cookie = "mname=" + mname;
					document.cookie = "passwd=" + passwd;
					window.location.href = "books_sale.jsp";
				} else {
					var oError = document.getElementById("error");
					oError.style.display = "block";
				}
			}
		};
	}
</script>
</head>
<body>
	<div>
		<header>
			<img src="images/logo-fill.png"> 图书销售系统
		</header>
		<main>
			<h1>管理员登录</h1>
			<form>
				<input type="text" name="mname" placeholder="姓名" id="mname" /><br />
				<input type="password" name="passwd" placeholder="密码" id="passwd" /><br />
				<p id="error">姓名或密码错误！</p>
				<label><input type="checkbox" name="remember-me" />下次记住我</label>
				<button type="button" id="submit">登录</button>
			</form>
		</main>
	</div>
</body>
</html>
