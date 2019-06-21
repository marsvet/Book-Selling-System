package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.JDBCDao;

/**
 * Servlet implementation class Get_record
 */
@WebServlet("/Get_reports")
public class Get_reports extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Get_reports() {
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

		PrintWriter writer = response.getWriter();
		JDBCDao jdbcDao = new JDBCDao();

		String jsonString = null;
		try {
			switch (option) {
			case "0":
				jsonString = jdbcDao.search_sales_record(null, "ALL", "ALL");
				break;
			case "1":
				jsonString = jdbcDao.search_purchase_record(null, "ALL", "ALL");
				break;
			case "2":
				jsonString = jdbcDao.search_members(null, "ALL", "ALL");
				break;
			}
		} catch (ClassNotFoundException | SQLException e) {
			writer.write("0");
			writer.close();
			return;
		}

		writer.write(jsonString);
		writer.close();
	}

}
