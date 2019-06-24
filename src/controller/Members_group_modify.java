package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.MemberGroupDao;

/**
 * Servlet implementation class Members_group_modify
 */
@WebServlet("/Members_group_modify")
public class Members_group_modify extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Members_group_modify() {
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

		String mpname = request.getParameter("mpname");
		String new_mpname = request.getParameter("new_mpname");
		String discount = request.getParameter("discount");

		PrintWriter writer = response.getWriter();
		MemberGroupDao memberGroupDao = new MemberGroupDao();

		if (Float.valueOf(discount) < 1 || Float.valueOf(discount) > 10) {
			writer.write("{\"message\":\"折扣为 1-10 的小数或整数\"}");
			writer.close();
			return;
		}
		
		try {
			memberGroupDao.update_members_group(new String[] { "MNAME", "DISCOUNT" }, new String[] { new_mpname, discount },
					"MNAME", mpname);
		} catch (ClassNotFoundException | SQLException e) {
			writer.write("{\"message\":\"系统内部错误\"}");
			writer.close();
			return;
		}

		writer.write("{\"message\":\"success\"}");
		writer.close();
	}

}
