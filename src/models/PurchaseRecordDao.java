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

	public String search_purchase_record(String[] attrs, String key, String value, int page)
			throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;
		String getCountSql = null;

		if ("ALL".equals(key) && "ALL".equals(value)) {
			sql = "SELECT * FROM (SELECT * FROM (SELECT * FROM PURCHASE_RECORD ORDER BY SERIAL_NUMBER DESC) WHERE ROWNUM<=10*" + page + " MINUS SELECT * FROM (SELECT * FROM PURCHASE_RECORD ORDER BY SERIAL_NUMBER DESC) WHERE ROWNUM<=10*(" + page + "-1)) ORDER BY SERIAL_NUMBER DESC";
			getCountSql = "SELECT COUNT(*) ITEM_NUMBER FROM PURCHASE_RECORD ORDER BY SERIAL_NUMBER DESC";
		}
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
				if ("DATE_OF_PURCHASE".equals(columnName))		// 本系统的日期只精确到“日”，所以这里去掉“时分秒”
					jsonObject.put(columnName, columnValue.substring(0, 10));
				else
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

	public int insert_into_purchase_record(String ISBN, int pcount, float unit_price, String publisher_id)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		java.util.Date current_util_date = new java.util.Date();	// 创建 java.util.Date 对象，获取当前时间
		Date current_sql_date = new Date(current_util_date.getTime());	// 将 java.util.Date 对象转换为 java.sql.Date 对象
		String purchase_of_date = current_sql_date.toString();	// 将 java.sql.date 对象转化为 YYYY-MM-DD 格式的字符串

		String sql = "INSERT INTO PURCHASE_RECORD VALUES(NULL, '" + ISBN + "', " + pcount + ", " + unit_price
				+ ", TO_DATE('" + purchase_of_date + "','YYYY-MM-DD'), " + publisher_id + ")";
					// TO_DATE 是 oracle 数据库中的一个函数

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

}
