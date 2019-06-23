package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.BooksDao;

/**
 * Servlet implementation class Book_search
 */
@WebServlet("/Book_search")
public class Book_search extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Book_search() {
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

		String value = request.getParameter("value");
		int page = Integer.valueOf(request.getParameter("page"));

		String jsonString = null;
		BooksDao booksDao = new BooksDao();

		try {
			jsonString = booksDao.search_books(null, "ALL", value, page);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}

		PrintWriter writer = response.getWriter();
		writer.write(jsonString);
		writer.close();
	}

}
