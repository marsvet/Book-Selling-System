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
@WebServlet("/Book_sale")
public class Book_sale extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Book_sale() {
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

		String ISBN = request.getParameter("ISBN");
		String phone_number = request.getParameter("phone_number");
		int quantity = Integer.valueOf(request.getParameter("quantity"));

		PrintWriter writer = response.getWriter();
		JDBCDao jdbcDao = new JDBCDao();

		String booksJsonString = null;
		try {
			booksJsonString = jdbcDao.search_books(new String[] { "TITLE", "AUTHOR", "INVENTORY", "RETAIL_PRICE" },
					"ISBN", ISBN);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		JSONArray booksJsonArray = new JSONArray(booksJsonString);
		JSONObject booksJsonObject = booksJsonArray.getJSONObject(0);

		String membersJsonString = null;
		try {
			membersJsonString = jdbcDao.search_members(new String[]{"MEMBERS.MID MID", "BOOK_PURCHASE", "STATUS", "MEMBERS_GROUP.MNAME MGNAME", "MEMBERS.MNAME MNAME", "BALANCE"}, "PHONE_NUMBER", phone_number);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		if ("[]".equals(membersJsonString)) {
			writer.write("{\"errorMessage\":\"此用户不存在\"}");
			writer.close();
			return;
		}
		JSONArray membersJsonArray = new JSONArray(membersJsonString);
		JSONObject membersJsonObject = membersJsonArray.getJSONObject(0);
		if ("0".equals(membersJsonObject.getString("STATUS"))) {
			writer.write("{\"errorMessage\":\"此用户已办理挂失\"}");
			writer.close();
			return;
		}

		String mgname = membersJsonObject.getString("MGNAME");
		String membersGroupJsonString = null;
		try {
			membersGroupJsonString = jdbcDao.search_members_group(new String[] { "DISCOUNT" }, "MNAME", mgname);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		JSONArray membersGroupJsonArray = new JSONArray(membersGroupJsonString);
		JSONObject membersGroupJsonObject = membersGroupJsonArray.getJSONObject(0);

		String title = booksJsonObject.getString("TITLE");
		String author = booksJsonObject.getString("AUTHOR");
		int inventory = Integer.valueOf(booksJsonObject.getString("INVENTORY"));
		float retail_price = Float.valueOf(booksJsonObject.getString("RETAIL_PRICE"));
		int memberId = Integer.valueOf(membersJsonObject.getString("MID"));
		String memberName = membersJsonObject.getString("MNAME");
		float balance = Float.valueOf(membersJsonObject.getString("BALANCE"));
		float discount = Float.valueOf(membersGroupJsonObject.getString("DISCOUNT"));
		int book_purchase = Integer.valueOf(membersJsonObject.getString("BOOK_PURCHASE"));

		if (balance < retail_price * discount * quantity / 10) {
			writer.write("{\"errorMessage\":\"余额不足\"}");
			writer.close();
			return;
		}

		if (inventory < quantity) {
			writer.write("{\"errorMessage\":\"库存不足\"}");
			writer.close();
			return;
		}

		try {
			jdbcDao.update_books(new String[] { "INVENTORY" }, new String[] { String.valueOf(inventory - quantity) },
					"ISBN", ISBN);
		} catch (ClassNotFoundException | SQLException e1) {
			e1.printStackTrace();
		}
		try {
			jdbcDao.update_members(new String[] { "BOOK_PURCHASE", "BALANCE" },
					new String[] { String.valueOf(book_purchase + quantity),
							String.valueOf(balance - retail_price * discount * quantity / 10) },
					"PHONE_NUMBER", phone_number);
		} catch (ClassNotFoundException | SQLException e1) {
			e1.printStackTrace();
		}
		try {
			jdbcDao.insert_into_sales_record(ISBN, retail_price * discount / 10, memberId, quantity);
		} catch (ClassNotFoundException | SQLException e1) {
			e1.printStackTrace();
		}
		
		String salesRecordJsonString = null;
		try {
			salesRecordJsonString = jdbcDao.search_sales_record(null, "MAX(SERIAL_NUMBER)", null);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		JSONArray salesRecordJsonArray = new JSONArray(salesRecordJsonString);
		JSONObject salesRecordJsonObject = salesRecordJsonArray.getJSONObject(0);
		String serial_number = salesRecordJsonObject.getString("SERIAL_NUMBER");
		try {
			salesRecordJsonString = jdbcDao.search_sales_record(new String[]{"DATE_OF_SALE"}, "SERIAL_NUMBER", serial_number);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		salesRecordJsonArray = new JSONArray(salesRecordJsonString);
		salesRecordJsonObject = salesRecordJsonArray.getJSONObject(0);
		String date_of_sale = salesRecordJsonObject.getString("DATE_OF_SALE").substring(0, 10);
		
		JSONObject resultJson = new JSONObject();
		resultJson.put("SERIAL_NUMBER", serial_number);
		resultJson.put("ISBN", ISBN);
		resultJson.put("TITLE", title);
		resultJson.put("AUTHOR", author);
		resultJson.put("MNAME", memberName);
		resultJson.put("UNIT_PRICE", retail_price * discount / 10);
		resultJson.put("QUANTITY", quantity);
		resultJson.put("DATE_OF_SALE", date_of_sale);
		
		writer.write(resultJson.toString());
		writer.close();
	}

}
