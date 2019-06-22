package models;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import org.json.JSONArray;
import org.json.JSONObject;

public class ManagerDao {
	private final String URL = "jdbc:oracle:thin:@localhost:1521:xe"; // 连接字符串
	private final String USERNAME = "bookselling"; // 用户名
	private final String PASSWORD = "bookselling"; // 密码

	public String search_manager(String[] attrs, String key, String value) throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key)) // key 有两种可能的值："ALL", "MNAME"
		{
			if ("ALL".equals(value))	// 如果 key 和 value 都是 ALL，选择所有数据
				sql = "SELECT MID, MNAME, PERMISSION, IDENTIFICATION_NUMBER, PHONE_NUMBER FROM MANAGER";	// 不选择 PASSWORD 列
			else	// 如果 key 为 ALL，value 不是 ALL，多条件查询。MNAME 列使用 like 模糊查询
				sql = "SELECT MID, MNAME, PERMISSION, IDENTIFICATION_NUMBER, PHONE_NUMBER FROM MANAGER WHERE MNAME LIKE '%"
						+ value + "%' OR PHONE_NUMBER='" + value + "' OR IDENTIFICATION_NUMBER='" + value + "'";
		} else {	// 生成 sql 语句，查询指定的属性列
			sql = "SELECT ";
			for (int i = 0; i < attrs.length - 1; i++)
				sql += attrs[i] + ", ";
			sql += attrs[attrs.length - 1] + " FROM MANAGER WHERE MNAME='" + value + "'";
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

		rs.close();
		stmt.close();
		connection.close();

		return jsonArray.toString();
	}

	public int insert_into_manager(String mname, String passwd, int permission, String identification_number,
			String phone_number) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "INSERT INTO MANAGER VALUES(NULL, '" + mname + "', '" + passwd + "', " + permission + ", '"
				+ identification_number + "', '" + phone_number + "')";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int delete_from_manager(String phone_number) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "DELETE FROM MANAGER WHERE PHONE_NUMBER=" + phone_number;

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int update_manager(String[] set_keys, String[] set_values, String key, String value)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "UPDATE MANAGER SET ";
		int i = 0;
		for (; i < set_keys.length - 1; i++) {
			if (set_keys[i] == "MID" || set_keys[i] == "PERMISSION")
				sql += set_keys[i] + "=" + set_values[i] + ", ";
			else
				sql += set_keys[i] + "='" + set_values[i] + "', ";
		}
		if (set_keys[i] == "MID" || set_keys[i] == "PERMISSION")
			sql += set_keys[i] + "=" + set_values[i] + " WHERE " + key + "='" + value + "'";
		else
			sql += set_keys[i] + "='" + set_values[i] + "' WHERE " + key + "='" + value + "'";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

}
