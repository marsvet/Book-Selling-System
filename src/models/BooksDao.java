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

public class BooksDao {
	private final String URL = "jdbc:oracle:thin:@localhost:1521:xe"; // 连接字符串
	private final String USERNAME = "bookselling"; // 用户名
	private final String PASSWORD = "bookselling"; // 密码

	public String search_books(String[] attrs, String key, String value) throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");	// 导入数据库驱动

		String sql = null;

		// key 有两种可能的值："ALL", "ISBN"
		if ("ALL".equals(key)) // 如果 key 的值为 "ALL"，将 sql 定义为两种特殊情况
		{
			if ("ALL".equals(value)) // 特殊情况一：value 为 "ALL" 时，sql 为查询所有书籍
				sql = "SELECT ISBN, TITLE, AUTHOR, INVENTORY, RETAIL_PRICE, LOWEST_DISCOUNT_PRICE, PNAME FROM BOOKS, PUBLISHER WHERE BOOKS.PUBLISHER_ID=PUBLISHER.PID";
			else // 特殊情况二：value 不为 "ALL" 时，sql 为一个多条件查询
				sql = "SELECT ISBN, TITLE, AUTHOR, INVENTORY, RETAIL_PRICE, LOWEST_DISCOUNT_PRICE, PNAME FROM BOOKS, PUBLISHER WHERE BOOKS.PUBLISHER_ID=PUBLISHER.PID AND (ISBN='"
						+ value + "' OR TITLE LIKE '%" + value + "%' OR AUTHOR LIKE '%" + value + "%' OR PNAME LIKE '%"
						+ value + "%')"; // TITLE, AUTHOR, PNAME 列使用 LIKE 进行模糊查询
		} else { // 如果 key 的值为 "ISBN"，则以 ISBN 为查询条件查询指定的属性列
			sql = "SELECT ";
			for (int i = 0; i < attrs.length - 1; i++)
				sql += attrs[i] + ", ";
			sql += attrs[attrs.length - 1] + " FROM BOOKS, PUBLISHER WHERE BOOKS.PUBLISHER_ID=PUBLISHER.PID AND ISBN='"
					+ value + "'";
		}

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD); // 连接数据库
		Statement stmt = connection.createStatement();

		ResultSet rs = stmt.executeQuery(sql); // 执行SQL查询语句，获取结果集
		ResultSetMetaData metaData = rs.getMetaData(); // 获取结果集元数据

		JSONArray jsonArray = new JSONArray(); // json 数组对象

		while (rs.next()) { // 提取结果集中的数据
			JSONObject jsonObject = new JSONObject(); // json 对象
			for (int i = 1; i <= metaData.getColumnCount(); i++) { // 提取数据并放入
																	// json 对象
				String columnName = metaData.getColumnLabel(i);
				String columnValue = rs.getString(columnName);
				jsonObject.put(columnName, columnValue);
			}
			jsonArray.put(jsonObject); // 将 json 对象放入 json 数组对象
		}

		/* 关闭 */
		rs.close();
		stmt.close();
		connection.close();

		return jsonArray.toString(); // 将 json 数组转换成字符串并返回
	}

	public boolean insert_into_books(String ISBN, String title, String author, int inventory, float retail_price,
			String publisher) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);

		/* 创建 CallableStatement 对象，该对象能调用存储过程和函数 */
		CallableStatement cstmt = connection.prepareCall("{CALL INSERT_INTO_BOOKS(?, ?, ?, ?, ?, ?)}"); // 先用问号代替参数

		/* 设置要向存储过程传入的参数 */
		cstmt.setString(1, ISBN);
		cstmt.setString(2, title);
		cstmt.setString(3, author);
		cstmt.setInt(4, inventory);
		cstmt.setFloat(5, retail_price);
		cstmt.setString(6, publisher);

		boolean result = cstmt.execute(); // 调用存储过程，返回值为 boolean，表示是否执行成功

		/* 关闭 */
		cstmt.close();
		connection.close();

		return result;
	}

	public int update_books(String[] set_keys, String[] set_values, String key, String value)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "UPDATE BOOKS SET ";
		int i = 0;
		for (; i < set_keys.length - 1; i++) {
			/* ISBN、TITLE、AUTHOR 的值的类型是字符串，要在 sql 语句中加单引号；其他值的类型是数字，不用加单引号 */
			if (set_keys[i] == "ISBN" || set_keys[i] == "TITLE" || set_keys[i] == "AUTHOR")
				sql += set_keys[i] + "='" + set_values[i] + "', ";
			else
				sql += set_keys[i] + "=" + set_values[i] + ", ";
		}
		if (set_keys[i] == "ISBN" || set_keys[i] == "TITLE" || set_keys[i] == "AUTHOR")
			sql += set_keys[i] + "='" + set_values[i] + "' WHERE " + key + "='" + value + "'";
		else
			sql += set_keys[i] + "=" + set_values[i] + " WHERE " + key + "='" + value + "'";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

}
