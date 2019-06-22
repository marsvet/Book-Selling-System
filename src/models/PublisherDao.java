package models;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import org.json.JSONArray;
import org.json.JSONObject;

public class PublisherDao {
	private final String URL = "jdbc:oracle:thin:@localhost:1521:xe"; // 连接字符串
	private final String USERNAME = "bookselling"; // 用户名
	private final String PASSWORD = "bookselling"; // 密码

	public String search_publisher(String[] attrs, String key, String value)
			throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key)) // key 有两种可能的值："ALL", "PNAME"
		{
			if ("ALL".equals(value))
				sql = "SELECT PNAME, PLOCATION, BOOKS_NUM FROM PUBLISHER";
			else
				sql = "SELECT PNAME, PLOCATION, BOOKS_NUM FROM PUBLISHER WHERE PNAME LIKE '%" + value
						+ "%' OR PLOCATION='" + value + "'";
		} else {
			sql = "SELECT ";
			for (int i = 0; i < attrs.length - 1; i++)
				sql += attrs[i] + ", ";
			sql += attrs[attrs.length - 1] + " FROM PUBLISHER WHERE PNAME='" + value + "'";
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

	public int insert_into_publisher(String pname, String plocation) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "INSERT INTO PUBLISHER VALUES(NULL, '" + pname + "', '" + plocation + "', 0)";

		int count = stmt.executeUpdate(sql); // 执行 sql。返回值为 int，表示受影响的行数

		stmt.close();
		connection.close();

		return count;
	}

	public int delete_from_publisher(String pname) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "DELETE FROM PUBLISHER WHERE PNAME='" + pname + "'";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int update_publisher(String[] set_keys, String[] set_values, String key, String value)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "UPDATE PUBLISHER SET ";
		int i = 0;
		for (; i < set_keys.length - 1; i++) {
			if (set_keys[i] == "PNAME" || set_keys[i] == "PLOCATION")
				sql += set_keys[i] + "='" + set_values[i] + "', ";
			else
				sql += set_keys[i] + "=" + set_values[i] + ", ";
		}
		if (set_keys[i] == "PNAME" || set_keys[i] == "PLOCATION")
			sql += set_keys[i] + "='" + set_values[i] + "' WHERE " + key + "='" + value + "'";
		else
			sql += set_keys[i] + "=" + set_values[i] + " WHERE " + key + "='" + value + "'";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

}
