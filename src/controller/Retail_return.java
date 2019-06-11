package controller;

import java.io.IOException;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.JDBCDao;

/**
 * Servlet implementation class Book_sale
 */
@WebServlet("/Retail_return")
public class Retail_return extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Retail_return() {
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

		String serial_number = request.getParameter("serial_number");
		String memberName = request.getParameter("mname");

		PrintWriter writer = response.getWriter();
		JDBCDao jdbcDao = new JDBCDao();

		String salesRecordJsonString = null;
		try {
			salesRecordJsonString = jdbcDao.search_sales_record(new String[] { "ISBN", "QUANTITY", "PRICE", "MEMBER_ID" },
					"SERIAL_NUMBER", serial_number);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		if ("[]".equals(salesRecordJsonString)) {
			writer.write("0");
			writer.close();
			return;
		}
		JSONArray salesRecordJsonArray = new JSONArray(salesRecordJsonString);
		JSONObject salesRecordJsonObject = salesRecordJsonArray.getJSONObject(0);

		String membersJsonString = null;
		try {
			membersJsonString = jdbcDao.search_members(new String[] { "MEMBERS.MID MID", "BOOK_PURCHASE", "BALANCE" }, "MEMBERS.MNAME",
					memberName);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		if ("[]".equals(membersJsonString)) {
			writer.write("0");
			writer.close();
			return;
		}
		JSONArray membersJsonArray = new JSONArray(membersJsonString);
		JSONObject membersJsonObject = membersJsonArray.getJSONObject(0);
		
		String member_id1 = salesRecordJsonObject.getString("MEMBER_ID");
		String member_id2 = membersJsonObject.getString("MID");
		if (!member_id1.equals(member_id2)){
			writer.write("0");
			writer.close();
			return;
		}

		String ISBN = salesRecordJsonObject.getString("ISBN");
		String booksJsonString = null;
		try {
			booksJsonString = jdbcDao.search_books(new String[] { "INVENTORY" }, "ISBN", ISBN);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		JSONArray booksJsonArray = new JSONArray(booksJsonString);
		JSONObject booksJsonObject = booksJsonArray.getJSONObject(0);

		int quantity = Integer.valueOf(salesRecordJsonObject.getString("QUANTITY"));
		float retail_price = Float.valueOf(salesRecordJsonObject.getString("PRICE"));
		int inventory = Integer.valueOf(booksJsonObject.getString("INVENTORY"));
		int book_purchase = Integer.valueOf(membersJsonObject.getString("BOOK_PURCHASE"));
		float balance = Float.valueOf(membersJsonObject.getString("BALANCE"));

		try {
			jdbcDao.update_books(new String[] { "INVENTORY" }, new String[] { String.valueOf(inventory + quantity) },
					"ISBN", ISBN);
		} catch (ClassNotFoundException | SQLException e1) {
			e1.printStackTrace();
		}

		try {
			jdbcDao.update_members(new String[] { "BOOK_PURCHASE", "BALANCE" }, new String[] {
					String.valueOf(book_purchase - quantity), String.valueOf(balance + retail_price * quantity) },
					"MNAME", memberName);
		} catch (ClassNotFoundException | SQLException e1) {
			e1.printStackTrace();
		}

		try {
			jdbcDao.sales_record_transform_to_invalid(serial_number);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}

		writer.write("1");
		writer.close();
	}

}
