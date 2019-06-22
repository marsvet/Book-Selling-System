package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.MemberPurchaseRecordDao;

/**
 * Servlet implementation class Member_purchase_record_search
 */
@WebServlet("/Member_purchase_record_search")
public class Member_purchase_record_search extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Member_purchase_record_search() {
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

		String jsonString = null;
		MemberPurchaseRecordDao memberPurchaseRecordDao = new MemberPurchaseRecordDao();
		
		try {
			jsonString = memberPurchaseRecordDao.search_member_purchase_record(phone_number);
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}

		PrintWriter writer = response.getWriter();
		writer.write(jsonString);
		writer.close();
	}

}
