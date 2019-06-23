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
import models.PurchaseRecordDao;
import models.SalesRecordDao;

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
		int page = Integer.valueOf(request.getParameter("page"));

		PrintWriter writer = response.getWriter();
		MembersDao membersDao = new MembersDao();
		SalesRecordDao salesRecordDao = new SalesRecordDao();
		PurchaseRecordDao purchaseRecordDao = new PurchaseRecordDao();

		String jsonString = null;
		try {
			switch (option) {
			case "1":
				jsonString = salesRecordDao.search_sales_record(null, "ALL", "ALL", page);
				break;
			case "2":
				jsonString = purchaseRecordDao.search_purchase_record(null, "ALL", "ALL", page);
				break;
			case "3":
				jsonString = membersDao.search_members(null, "ALL", "ALL", page);
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
