package models;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import org.json.JSONArray;
import org.json.JSONObject;

public class MemberPurchaseRecordDao {
	private final String URL = "jdbc:oracle:thin:@localhost:1521:xe"; // 连接字符串
	private final String USERNAME = "bookselling"; // 用户名
	private final String PASSWORD = "bookselling"; // 密码

	public String search_member_purchase_record(String value) throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = "SELECT DATE_OF_SALE, TITLE, AUTHOR, QUANTITY, PRICE FROM MEMBER_PURCHASE_RECORD WHERE PHONE_NUMBER='"
				+ value + "' ORDER BY DATE_OF_SALE DESC";

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
				if ("DATE_OF_SALE".equals(columnName))		// 本系统的日期只精确到“日”，所以这里去掉“时分秒”
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

}
