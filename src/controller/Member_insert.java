package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.MembersDao;

/**
 * Servlet implementation class Member_insert
 */
@WebServlet("/Member_insert")
public class Member_insert extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Member_insert() {
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

		String mname = request.getParameter("mname");
		String phone_number = request.getParameter("phone_number");
		String identification_number = request.getParameter("identification");
		String members_group = request.getParameter("members_group");

		PrintWriter writer = response.getWriter();
		MembersDao membersDao = new MembersDao();

		try {
			membersDao.insert_into_members(mname, identification_number, phone_number, members_group);
		} catch (ClassNotFoundException | SQLException e) {
			writer.write("0");
			writer.close();
			return;
		}

		writer.write("1");
		writer.close();
	}

}
