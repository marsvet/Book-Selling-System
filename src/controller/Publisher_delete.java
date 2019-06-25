package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.PublisherDao;

/**
 * Servlet implementation class Publisher_delete
 */
@WebServlet("/Publisher_delete")
public class Publisher_delete extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Publisher_delete() {
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

		String pname = request.getParameter("pname");

		PrintWriter writer = response.getWriter();
		PublisherDao publisherDao = new PublisherDao();

		try {
			publisherDao.delete_from_publisher(pname);
		} catch (ClassNotFoundException | SQLException e) {
			writer.write("{\"message\":\"请先删除从此出版社进货的图书\"}");
			writer.close();
			return;
		}

		writer.write("{\"message\":\"success\"}");
		writer.close();
	}

}
