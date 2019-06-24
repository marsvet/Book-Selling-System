package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.ManagerDao;

/**
 * Servlet implementation class Member_delete
 */
@WebServlet("/Manager_delete")
public class Manager_delete extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Manager_delete() {
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

		String phone_number = request.getParameter("phone_number");

		PrintWriter writer = response.getWriter();
		ManagerDao managerDao = new ManagerDao();

		try {
			managerDao.delete_from_manager(phone_number);
		} catch (ClassNotFoundException | SQLException e) {
			writer.write("{\"message\":\"系统内部错误\"}");
			writer.close();
			return;
		}

		writer.write("{\"message\":\"success\"}");
		writer.close();
	}

}
