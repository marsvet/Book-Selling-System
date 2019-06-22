package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.MemberGroupDao;

/**
 * Servlet implementation class Members_group_delete
 */
@WebServlet("/Members_group_delete")
public class Members_group_delete extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Members_group_delete() {
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

		String mgname = request.getParameter("mgname");

		PrintWriter writer = response.getWriter();
		MemberGroupDao memberGroupDao = new MemberGroupDao();

		try {
			memberGroupDao.delete_from_members_group(mgname);
		} catch (ClassNotFoundException | SQLException e) {
			writer.write("0");
			writer.close();
			return;
		}

		writer.write("1");
		writer.close();
	}

}
