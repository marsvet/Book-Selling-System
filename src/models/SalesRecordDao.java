package models;

import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import org.json.JSONArray;
import org.json.JSONObject;

public class SalesRecordDao {
	private final String URL = "jdbc:oracle:thin:@localhost:1521:xe"; // 连接字符串
	private final String USERNAME = "bookselling"; // 用户名
	private final String PASSWORD = "bookselling"; // 密码

	public String search_sales_record(String[] attrs, String key, String value)
			throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key) && "ALL".equals(value))
			sql = "SELECT * FROM SALES_RECORD ORDER BY SERIAL_NUMBER DESC";
		else if ("MAX(SERIAL_NUMBER)".equals(key))
			sql = "SELECT MAX(SERIAL_NUMBER) SERIAL_NUMBER FROM SALES_RECORD";
		else {
			sql = "SELECT ";
			for (int i = 0; i < attrs.length - 1; i++)
				sql += attrs[i] + ", ";
			sql += attrs[attrs.length - 1] + " FROM SALES_RECORD WHERE SERIAL_NUMBER=" + value;
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
				if ("DATE_OF_SALE".equals(columnName))
					jsonObject.put(columnName, columnValue.substring(0, 10));
				else
					jsonObject.put(columnName, columnValue);
			}
			jsonArray.put(jsonObject);
		}

		rs.close();
		stmt.close();
		connection.close();

		return jsonArray.toString();
	}

	public int insert_into_sales_record(String ISBN, float unit_price, int member_id, int quantity)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		java.util.Date current_util_date = new java.util.Date(); // 获取当前时间
		Date current_sql_date = new Date(current_util_date.getTime()); // 转换为
																		// java.sql.Date
																		// 类型
		String sale_of_date = current_sql_date.toString(); // 转化为 YYYY-MM-DD
															// 格式的字符串

		String sql = "INSERT INTO SALES_RECORD VALUES(NULL, '" + ISBN + "', TO_DATE('" + sale_of_date
				+ "','YYYY-MM-DD'), " + unit_price + ", " + member_id + ", 1, " + quantity + ")";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int sales_record_transform_to_invalid(String serial_number) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "UPDATE SALES_RECORD SET IS_VALID=0 WHERE SERIAL_NUMBER=" + serial_number;

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

}
