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

public class PurchaseRecordDao {
	private final String URL = "jdbc:oracle:thin:@localhost:1521:xe"; // 连接字符串
	private final String USERNAME = "bookselling"; // 用户名
	private final String PASSWORD = "bookselling"; // 密码

	public String search_purchase_record(String[] attrs, String key, String value)
			throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key) && "ALL".equals(value))
			sql = "SELECT * FROM PURCHASE_RECORD ORDER BY SERIAL_NUMBER DESC";
		else {
			sql = "SELECT ";
			for (int i = 0; i < attrs.length - 1; i++)
				sql += attrs[i] + ", ";
			sql += attrs[attrs.length - 1] + " FROM PURCHASE_RECORD WHERE SERIAL_NUMBER=" + value;
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
				if ("DATE_OF_PURCHASE".equals(columnName))
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

	public int insert_into_purchase_record(String ISBN, int pcount, float unit_price, String publisher_id)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		java.util.Date current_util_date = new java.util.Date();
		Date current_sql_date = new Date(current_util_date.getTime());
		String purchase_of_date = current_sql_date.toString();

		String sql = "INSERT INTO PURCHASE_RECORD VALUES(NULL, '" + ISBN + "', " + pcount + ", " + unit_price
				+ ", TO_DATE('" + purchase_of_date + "','YYYY-MM-DD'), " + publisher_id + ")";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

}
