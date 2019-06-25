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

import models.MembersDao;

/**
 * Servlet implementation class Member_modify
 */
@WebServlet("/Member_modify")
public class Member_modify extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Member_modify() {
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
		String phone_number = request.getParameter("phone_number");

		PrintWriter writer = response.getWriter();
		MembersDao membersDao = new MembersDao();

		String membersJsonString = null;
		switch (option) {
		case "1":
			String mname = request.getParameter("mname");
			String new_phone_number = request.getParameter("new_phone_number");
			String identification = request.getParameter("identification");
			try {
				membersDao.update_members(new String[] { "MNAME", "PHONE_NUMBER", "IDENTIFICATION_NUMBER" },
						new String[] { mname, new_phone_number, identification }, "PHONE_NUMBER", phone_number);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"输入信息不合法\"}");
				writer.close();
				return;
			}
			break;
		case "2":
			try {
				membersJsonString = membersDao.search_members(new String[] { "BALANCE", "STATUS" }, "PHONE_NUMBER",
						phone_number, -1);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"系统内部错误\"}");
				writer.close();
				return;
			}
			JSONArray membersJsonArray = new JSONArray(membersJsonString);
			JSONObject membersJsonObject = membersJsonArray.getJSONObject(0);
			String status = membersJsonObject.getString("STATUS");
			if ("0".equals(status)) {
				writer.write("{\"message\":\"该会员已办理挂失，无法充值\"}");
				writer.close();
				return;
			}
			float balance = Float.valueOf(membersJsonObject.getString("BALANCE"));
			float recharge_amount = Float.valueOf(request.getParameter("recharge_amount"));
			try {
				membersDao.update_members(new String[] { "BALANCE" },
						new String[] { String.valueOf(balance + recharge_amount) }, "PHONE_NUMBER", phone_number);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"系统内部错误\"}");
				writer.close();
				return;
			}
			break;
		case "3":
			try {
				membersDao.update_members(new String[] { "STATUS" }, new String[] { "0" }, "PHONE_NUMBER",
						phone_number);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"系统内部错误\"}");
				writer.close();
				return;
			}
			break;
		case "4":
			try {
				membersDao.update_members(new String[] { "STATUS" }, new String[] { "1" }, "PHONE_NUMBER",
						phone_number);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"系统内部错误\"}");
				writer.close();
				return;
			}
			break;
		case "5":
			String old_passwd = request.getParameter("old_passwd");
			String new_passwd = request.getParameter("new_passwd");
			try {
				membersJsonString = membersDao.search_members(new String[] {"PASSWD" }, "PHONE_NUMBER",
						phone_number, -1);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"系统内部错误\"}");
				writer.close();
				return;
			}
			JSONArray jsonArray = new JSONArray(membersJsonString);
			JSONObject jsonObject = jsonArray.getJSONObject(0);
			if (!old_passwd.equals(jsonObject.getString("PASSWD"))) {
				writer.write("{\"message\":\"旧密码输入错误\"}");
				writer.close();
				return;
			}
			try {
				membersDao.update_members(new String[] { "PASSWD" }, new String[] { new_passwd }, "PHONE_NUMBER",
						phone_number);
			} catch (ClassNotFoundException | SQLException e) {
				writer.write("{\"message\":\"系统内部错误\"}");
				writer.close();
				return;
			}
		}

		writer.write("{\"message\":\"success\"}");
		writer.close();
	}

}
