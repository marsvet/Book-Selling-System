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
 * Servlet implementation class Book_modify
 */
@WebServlet("/Book_modify")
public class Book_modify extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Book_modify() {
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
		String ISBN = request.getParameter("ISBN");
		String pname = request.getParameter("publisher");

		PrintWriter writer = response.getWriter();
		BooksDao booksDao = new BooksDao();
		PublisherDao publisherDao = new PublisherDao();
		PurchaseRecordDao purchaseRecordDao = new PurchaseRecordDao();

		if ("1".equals(option) || "2".equals(option)) {		// option 为 1 或 2 时，运行 进退货 功能
			int quantity = Integer.valueOf(request.getParameter("quantity"));

			String booksJsonString = null;
			try {
				booksJsonString = booksDao.search_books(new String[] { "INVENTORY", "RETAIL_PRICE" }, "ISBN", ISBN);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("0");
				writer.close();
				return;
			}
			JSONArray booksJsonArray = new JSONArray(booksJsonString);	// 将 json 字符串转化为 json 数组对象
			JSONObject booksJsonObject = booksJsonArray.getJSONObject(0);	// 提取 json 数组中的第一个 json 对象
			int inventory = Integer.valueOf(booksJsonObject.getString("INVENTORY"));
			float retail_price = Float.valueOf(booksJsonObject.getString("RETAIL_PRICE"));

			String publisherJsonString = null;
			try {
				publisherJsonString = publisherDao.search_publisher(new String[] { "PID", "BOOKS_NUM" }, "PNAME",
						pname);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("0");
				writer.close();
				return;
			}
			JSONArray publisherJsonArray = new JSONArray(publisherJsonString);
			JSONObject publisherJsonObject = publisherJsonArray.getJSONObject(0);
			int books_num = Integer.valueOf(publisherJsonObject.getString("BOOKS_NUM"));
			String publisher_id = publisherJsonObject.getString("PID");

			try {
				// 将数据库 books 表的 inventory 列更新为 inventory + quantity，quantity 为正数或负数，所以正数相当于进货，负数相当于退货
				booksDao.update_books(new String[] { "INVENTORY" },
						new String[] { String.valueOf(inventory + quantity) }, "ISBN", ISBN);
				publisherDao.update_publisher(new String[] { "BOOKS_NUM" },
						new String[] { String.valueOf(books_num + quantity) }, "PNAME", pname);
				purchaseRecordDao.insert_into_purchase_record(ISBN, quantity, retail_price, publisher_id);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("0");
				writer.close();
				return;
			}
		} else {
			String new_ISBN = request.getParameter("new_ISBN");
			String title = request.getParameter("title");
			String author = request.getParameter("author");
			String publisher = request.getParameter("publisher");
			String retail_price = request.getParameter("retail_price");

			String publisherJsonString = null;
			try {
				publisherJsonString = publisherDao.search_publisher(new String[] { "PID" }, "PNAME", publisher);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("0");
				writer.close();
				return;
			}
			JSONArray publisherJsonArray = new JSONArray(publisherJsonString);
			JSONObject publisherJsonObject = publisherJsonArray.getJSONObject(0);
			String publisher_id = publisherJsonObject.getString("PID");
			try {
				booksDao.update_books(new String[] { "ISBN", "TITLE", "AUTHOR", "PUBLISHER_ID", "retail_price" },
						new String[] { new_ISBN, title, author, publisher_id, retail_price }, "ISBN", ISBN);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("0");
				writer.close();
				return;
			}
		}

		writer.write("1");
		writer.close();
	}

}
