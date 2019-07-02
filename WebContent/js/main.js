function redirect() {
	// 映射关系
	var pageMap = {
		图书出售 : "books_sale.jsp",
		零售退货 : "retail_return.jsp",
		会员管理 : "members_management.jsp",
		图书管理 : "books_management.jsp",
		出版社管理 : "publishers_management.jsp",
		会员组管理 : "member_groups_management.jsp",
		打印报表 : "print_reports.jsp",
		系统设置 : "system_settings.jsp"
	};

	window.location.href = pageMap[this.innerHTML];
}