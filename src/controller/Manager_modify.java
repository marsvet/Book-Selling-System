package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.ManagerDao;

/**
 * Servlet implementation class Manager_modify
 */
@WebServlet("/Manager_modify")
public class Manager_modify extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Manager_modify() {
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
		request.setCharacterEncoding("utf-8");
		response.setCharacterEncoding("utf-8");
		response.setContentType("application/json");

		String option = request.getParameter("option");
		String phone_number = request.getParameter("phone_number");

		PrintWriter writer = response.getWriter();
		ManagerDao managerDao = new ManagerDao();

		switch (option) {
		case "1":
			String mname = request.getParameter("mname");
			String new_phone_number = request.getParameter("new_phone_number");
			String identification = request.getParameter("identification");
			try {
				managerDao.update_manager(new String[] { "MNAME", "PHONE_NUMBER", "IDENTIFICATION_NUMBER" },
						new String[] { mname, new_phone_number, identification }, "PHONE_NUMBER", phone_number);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"输入信息不合法\"}");
				writer.close();
				return;
			}
			break;
		case "2":
			String password = request.getParameter("password");
			try {
				managerDao.update_manager(new String[] { "PASSWD" }, new String[] { password }, "PHONE_NUMBER",
						phone_number);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"系统内部错误\"}");
				writer.close();
				return;
			}
			break;
		case "3":
			String permission = request.getParameter("permission");
			if (Integer.valueOf(permission) < 0 || Integer.valueOf(permission) > 2) {
				writer.write("{\"message\":\"输入信息不合法\"}");
				writer.close();
				return;
			}
			try {
				managerDao.update_manager(new String[] { "PERMISSION" }, new String[] { permission }, "PHONE_NUMBER",
						phone_number);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"系统内部错误\"}");
				writer.close();
				return;
			}
			break;
		}

		writer.write("{\"message\":\"success\"}");
		writer.close();
	}

}
