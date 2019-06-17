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
		request.setCharacterEncoding("utf-8");
		response.setCharacterEncoding("utf-8");
		response.setContentType("application/json");

		String ISBN = request.getParameter("ISBN");
		String title = request.getParameter("title");
		String author = request.getParameter("author");
		int quantity = Integer.valueOf(request.getParameter("quantity"));
		float retail_price = Float.valueOf(request.getParameter("retail_price"));
		String publisher = request.getParameter("publisher");

		PrintWriter writer = response.getWriter();
		JDBCDao jdbcDao = new JDBCDao();

		try {
			jdbcDao.insert_into_books(ISBN, title, author, quantity, retail_price, publisher);
		} catch (ClassNotFoundException | SQLException e) {
			writer.write("0");
			writer.close();
			return;
		}

		writer.write("1");
		writer.close();
	}

}
