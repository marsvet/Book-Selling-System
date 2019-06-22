package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.CheckAdminDao;

/**
 * Servlet implementation class Check_admin
 */
@WebServlet("/Check_admin")
public class Check_admin extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Check_admin() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		request.setCharacterEncoding("utf-8"); // 设置 POST 请求的编码
		response.setCharacterEncoding("utf-8"); // 设置响应的编码
		response.setContentType("text/html"); // 设置响应的 Content-Type

		PrintWriter writer = response.getWriter();	// 实例化输出流对象，通过输出流对象将内容传到前端

		String mname = request.getParameter("mname");
		String passwd = request.getParameter("passwd");
		CheckAdminDao checkAdminDao = new CheckAdminDao();
		
		int count = 0;
		try {
			count = checkAdminDao.check_admin(mname, passwd);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		
		if (count > 0) {
			writer.write("true");
		}
		else {
			writer.write("false");
		}

		writer.close();
	}

}
