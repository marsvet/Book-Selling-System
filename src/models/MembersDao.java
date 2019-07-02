package models;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import org.json.JSONArray;
import org.json.JSONObject;

public class MembersDao {
	private final String URL = "jdbc:oracle:thin:@localhost:1521:orcl"; // 连接字符串
	private final String USERNAME = "\"C##bookselling\""; // 用户名
	private final String PASSWORD = "bookselling"; // 密码

	public String search_members(String[] attrs, String key, String value, int page) throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;
		String getCountSql = null;

		if ("ALL".equals(key)) {
			if ("ALL".equals(value)) {
				sql = "SELECT MEMBERS.MNAME MNAME, PHONE_NUMBER, IDENTIFICATION_NUMBER, MEMBERS_GROUP.MNAME MGNAME, BOOK_PURCHASE, BALANCE, STATUS FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID AND ROWNUM<=10*" + page + " MINUS SELECT MEMBERS.MNAME MNAME, PHONE_NUMBER, IDENTIFICATION_NUMBER, MEMBERS_GROUP.MNAME MGNAME, BOOK_PURCHASE, BALANCE, STATUS FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID AND ROWNUM<=10*(" + page + "-1)";
				getCountSql = "SELECT COUNT(*) ITEM_NUMBER FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID";
			}
			else {
				sql = "SELECT MEMBERS.MNAME MNAME, PHONE_NUMBER, IDENTIFICATION_NUMBER, MEMBERS_GROUP.MNAME MGNAME, BOOK_PURCHASE, BALANCE, STATUS FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID AND (MEMBERS.MNAME LIKE '%"
						+ value + "%' OR PHONE_NUMBER='" + value + "' OR IDENTIFICATION_NUMBER='" + value + "') AND ROWNUM<=10*" + page + " MINUS SELECT MEMBERS.MNAME MNAME, PHONE_NUMBER, IDENTIFICATION_NUMBER, MEMBERS_GROUP.MNAME MGNAME, BOOK_PURCHASE, BALANCE, STATUS FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID AND (MEMBERS.MNAME LIKE '%"
						+ value + "%' OR PHONE_NUMBER='" + value + "' OR IDENTIFICATION_NUMBER='" + value + "') AND ROWNUM<=10*(" + page + "-1)";
				// MERBERS.MNAME 列使用 LIKE 进行模糊查询
				getCountSql = "SELECT COUNT(*) ITEM_NUMBER FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID AND (MEMBERS.MNAME LIKE '%"
						+ value + "%' OR PHONE_NUMBER='" + value + "' OR IDENTIFICATION_NUMBER='" + value + "')";
			}
		} else {
			sql = "SELECT ";
			for (int i = 0; i < attrs.length - 1; i++)
				sql += attrs[i] + ", ";
			sql += attrs[attrs.length - 1]
					+ " FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID AND " + key + "='"
					+ value + "'";
		}

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		ResultSet rs = stmt.executeQuery(sql);
		ResultSetMetaData metaData = rs.getMetaData();

		JSONArray jsonArray = new JSONArray();

		while (rs.next()) {
			JSONObject jsonObject = new JSONObject();
			for (int i = 1; i <= metaData.getColumnCount(); i++) {
				String columnName = metaData.getColumnLabel(i);
				String columnValue = rs.getString(columnName);
				jsonObject.put(columnName, columnValue);
			}
			jsonArray.put(jsonObject);
		}

		if (getCountSql != null) {
			rs = stmt.executeQuery(getCountSql);
			rs.next();			// 将指针定位到结果集的第一行，如果不执行这句，指针指向第一行的上面
			JSONObject jsonObject = new JSONObject();
			int page_sum = (int) (Float.valueOf(rs.getString("ITEM_NUMBER")) / 10 + 0.999999);
			jsonObject.put("PAGE_SUM", page_sum);
			jsonArray.put(jsonObject);
		}

		rs.close();
		stmt.close();
		connection.close();

		return jsonArray.toString();
	}

	/* 调用存储过程插入会员 */
	public boolean insert_into_members(String mname, String identification_number, String phone_number,
			String members_group, String passwd) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		CallableStatement cstmt = connection.prepareCall("{CALL INSERT_INTO_MEMBERS(?, ?, ?, ?, ?)}");
		cstmt.setString(1, mname);
		cstmt.setString(2, identification_number);
		cstmt.setString(3, phone_number);
		cstmt.setString(4, members_group);
		cstmt.setString(5, passwd);

		boolean result = cstmt.execute();

		cstmt.close();
		connection.close();

		return result;
	}

	public int delete_from_members(String phone_number) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "DELETE FROM MEMBERS WHERE PHONE_NUMBER='" + phone_number + "'";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int update_members(String[] set_keys, String[] set_values, String key, String value)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "UPDATE MEMBERS SET ";
		int i = 0;
		for (; i < set_keys.length - 1; i++) {
			if (set_keys[i] == "MNAME" || set_keys[i] == "IDENTIFICATION_NUMBER" || set_keys[i] == "PHONE_NUMBER")
				sql += set_keys[i] + "='" + set_values[i] + "', ";
			else
				sql += set_keys[i] + "=" + set_values[i] + ", ";
		}
		if (set_keys[i] == "MNAME" || set_keys[i] == "IDENTIFICATION_NUMBER" || set_keys[i] == "PHONE_NUMBER")
			sql += set_keys[i] + "='" + set_values[i] + "' WHERE " + key + "='" + value + "'";
		else
			sql += set_keys[i] + "=" + set_values[i] + " WHERE " + key + "='" + value + "'";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

}
