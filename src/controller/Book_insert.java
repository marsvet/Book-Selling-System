package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

import models.BooksDao;
import models.PublisherDao;
import models.PurchaseRecordDao;

/**
 * Servlet implementation class Book_insert
 */
@WebServlet("/Book_insert")
public class Book_insert extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Book_insert() {
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
		response.setContentType("application/json"); // 设置响应的 Content-Type

		/* 从前端发来的请求中获取需要的值 */
		String ISBN = request.getParameter("ISBN");
		String title = request.getParameter("title");
		String author = request.getParameter("author");
		int quantity = Integer.valueOf(request.getParameter("quantity"));
		float retail_price = Float.valueOf(request.getParameter("retail_price"));
		String publisher = request.getParameter("publisher");

		PrintWriter writer = response.getWriter();	// 实例化输出流对象，通过输出流对象将内容传到前端
		BooksDao booksDao = new BooksDao();
		PublisherDao publisherDao = new PublisherDao();
		PurchaseRecordDao purchaseRecordDao = new PurchaseRecordDao();

		String publisherJsonString = null;
		try {
			publisherJsonString = publisherDao.search_publisher(new String[] { "PID", "BOOKS_NUM" }, "PNAME",
					publisher, -1);
		} catch (ClassNotFoundException | SQLException e) {
			writer.write("{\"message\":\"系统内部错误\"}");		// sql 语句执行失败，返回“系统内部错误”
			writer.close();
			return;
		}
		JSONArray publisherJsonArray = new JSONArray(publisherJsonString);
		if (publisherJsonArray.length() == 0) {
			writer.write("{\"message\":\"请先录入出版社信息\"}");
			writer.close();
			return;
		}
		JSONObject publisherJsonObject = publisherJsonArray.getJSONObject(0);
		int books_num = Integer.valueOf(publisherJsonObject.getString("BOOKS_NUM"));
		String publisher_id = publisherJsonObject.getString("PID");

		try {
			booksDao.insert_into_books(ISBN, title, author, quantity, retail_price, publisher);
			publisherDao.update_publisher(new String[] { "BOOKS_NUM" },
					new String[] { String.valueOf(books_num + quantity) }, "PNAME", publisher);
			purchaseRecordDao.insert_into_purchase_record(ISBN, quantity, retail_price, publisher_id);
		} catch (ClassNotFoundException | SQLException e) {
			writer.write("{\"message\":\"输入信息不合法\"}");
			writer.close();
			return;
		}

		writer.write("{\"message\":\"success\"}");	// sql 语句全部执行成功，向前端返回 "1"
		writer.close();
	}

}
