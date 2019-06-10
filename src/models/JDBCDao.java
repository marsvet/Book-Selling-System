package models; // 该类属于 models 包

import java.sql.*;
import java.text.SimpleDateFormat;

import org.json.JSONArray;
import org.json.JSONObject;

public class JDBCDao { // 专门用来操作数据库的类约定用Dao结尾
	private final String URL = "jdbc:oracle:thin:@localhost:1521:xe"; // 连接字符串
	private final String USERNAME = "bookselling"; // 用户名
	private final String PASSWORD = "bookselling"; // 密码

	public int check_admin(String mname, String passwd) throws ClassNotFoundException, SQLException {
		String sql = "SELECT COUNT(*) FROM MANAGER WHERE MNAME='" + mname + "' AND PASSED='" + passwd + "'"; // 注意：SQL语句最后不能加分号
		ResultSet rs = null; // 结果集对象
		int count = 0;

		Class.forName("oracle.jdbc.OracleDriver"); // 导入数据库驱动

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD); // 连接数据库
		Statement stmt = connection.createStatement();

		rs = stmt.executeQuery(sql);

		while (rs.next()) {
			count = rs.getInt(1);
		}

		rs.close();
		stmt.close();
		connection.close();

		return count;
	}

	public String search_books(String[] attrs, String key, String value) throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		// key 有两种可能的值："ALL", "ISBN"
		if ("ALL".equals(key)) // 如果 key 的值为 "ALL"，将 sql 定义为两种特殊情况
		{
			if ("ALL".equals(value)) // 特殊情况一：value 为 "ALL" 时，sql 为查询所有书籍
				sql = "SELECT ISBN, TITLE, AUTHOR, INVENTORY, RETAIL_PRICE, LOWEST_DISCOUNT_PRICE, PNAME FROM BOOKS, PUBLISHER WHERE BOOKS.PUBLISHER_ID=PUBLISHER.PID";
			else // 特殊情况二：value 不为 "ALL" 时，sql 为一个多条件查询
				sql = "SELECT ISBN, TITLE, AUTHOR, INVENTORY, RETAIL_PRICE, LOWEST_DISCOUNT_PRICE, PNAME FROM BOOKS, PUBLISHER WHERE BOOKS.PUBLISHER_ID=PUBLISHER.PID AND (ISBN='"
						+ value + "' OR TITLE='" + value + "' OR AUTHOR='" + value + "' OR PNAME='" + value + "')";
		} else { // 如果 key 的值为 "ISBN"，则以 ISBN 为查询条件查询
			sql = "SELECT ";
			for (int i = 0; i < attrs.length - 1; i++)
				sql += attrs[i] + ", ";
			sql += attrs[attrs.length - 1] + " FROM BOOKS, PUBLISHER WHERE BOOKS.PUBLISHER_ID=PUBLISHER.PID AND ISBN='"
					+ value + "'";
		}

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		ResultSet rs = stmt.executeQuery(sql); // 执行SQL查询语句，获取结果集
		ResultSetMetaData metaData = rs.getMetaData(); // 获取结果集元数据

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

	public String search_members(String[] attrs, String key, String value) throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key)) // key 有两种可能的值："ALL", "PHONE_NUMBER"
		{
			if ("ALL".equals(value))
				sql = "SELECT MEMBERS.MNAME MNAME, PHONE_NUMBER, IDENTIFICATION_NUMBER, MEMBERS_GROUP.MNAME MGNAME, BOOK_PURCHASE, BALANCE, STATUS FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID";
			else
				sql = "SELECT MEMBERS.MNAME MNAME, PHONE_NUMBER, IDENTIFICATION_NUMBER, MEMBERS_GROUP.MNAME MGNAME, BOOK_PURCHASE, BALANCE, STATUS FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID AND (MEMBERS.MNAME='"
						+ value + "' OR PHONE_NUMBER=" + value + " OR IDENTIFICATION_NUMBER='" + value + "')";
		} else {
			sql = "SELECT ";
			for (int i = 0; i < attrs.length - 1; i++)
				sql += attrs[i] + ", ";
			sql += attrs[attrs.length - 1]
					+ " FROM MEMBERS, MEMBERS_GROUP WHERE MEMBERS.MEMBERS_GROUP_ID=MEMBERS_GROUP.MID AND PHONE_NUMBER='"
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

		rs.close();
		stmt.close();
		connection.close();

		return jsonArray.toString();
	}

	public String search_publisher(String[] attrs, String key, String value)
			throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key)) // key 有两种可能的值："ALL", "PNAME"
		{
			if ("ALL".equals(value))
				sql = "SELECT PNAME, PLOCATION, BOOKS_NUM FROM PUBLISHER";
			else
				sql = "SELECT PNAME, PLOCATION, BOOKS_NUM FROM PUBLISHER WHERE PNAME='" + value + "' OR PLOCATION='"
						+ value + "'";
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

	public String search_manager(String[] attrs, String key, String value) throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key)) // key 有两种可能的值："ALL", "MNAME"
		{
			if ("ALL".equals(value))
				sql = "SELECT * FROM MANAGER";
			else
				sql = "SELECT * FROM MANAGER WHERE MNAME='" + value + "' OR PHONE_NUMBER='" + value
						+ "' OR IDENTIFICATION_NUMBER='" + value + "'";
		} else {
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

	public String search_members_group(String[] attrs, String key, String value)
			throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key) && "ALL".equals(value))	// key 有两种情况："ALL", "MNAME"
			sql = "SELECT * FROM MEMBERS_GROUP";
		else {
			sql = "SELECT ";
			for (int i = 0; i < attrs.length - 1; i++)
				sql += attrs[i] + ", ";
			sql += attrs[attrs.length - 1] + " FROM MEMBERS_GROUP WHERE MNAME='" + value + "'";
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

	public String search_sales_record(String[] attrs, String key, String value)
			throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key) && "ALL".equals(value))
			sql = "SELECT * FROM SALES_RECORD";
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
				jsonObject.put(columnName, columnValue);
			}
			jsonArray.put(jsonObject);
		}

		rs.close();
		stmt.close();
		connection.close();

		return jsonArray.toString();
	}

	public String search_purchase_record(String[] attrs, String key, String value)
			throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");

		String sql = null;

		if ("ALL".equals(key) && "ALL".equals(value))
			sql = "SELECT * FROM PURCHASE_RECORD";
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
				jsonObject.put(columnName, columnValue);
			}
			jsonArray.put(jsonObject);
		}

		rs.close();
		stmt.close();
		connection.close();

		return jsonArray.toString();
	}

	public boolean insert_into_books(String ISBN, String title, String author, int inventory, float retail_price,
			String publisher) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);

		// 创建 CallableStatement 对象，该对象能调用存储过程和函数
		CallableStatement cstmt = connection.prepareCall("{CALL INSERT_INTO_BOOKS(?, ?, ?, ?, ?, ?)}");// 先用问号代替参数
		cstmt.setString(1, ISBN); // 设置要向存储过程传入的参数
		cstmt.setString(2, title);
		cstmt.setString(3, author);
		cstmt.setInt(4, inventory);
		cstmt.setFloat(5, retail_price);
		cstmt.setString(6, publisher);

		boolean result = cstmt.execute(); // 调用存储过程，返回值为 boolean，表示是否执行成功

		cstmt.close();
		connection.close();

		return result;
	}

	public boolean insert_into_members(String mname, String indentification_number, String phone_number,
			String members_group) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		CallableStatement cstmt = connection.prepareCall("{CALL INSERT_INTO_MEMBERS(?, ?, ?, ?)}");
		cstmt.setString(1, mname);
		cstmt.setString(2, indentification_number);
		cstmt.setString(3, phone_number);
		cstmt.setString(4, members_group);

		boolean result = cstmt.execute();

		cstmt.close();
		connection.close();

		return result;
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

	public int insert_into_members_group(String mname, int point_conversion, float discount)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "INSERT INTO MEMBERS_GROUP VALUES(NULL, '" + mname + "', " + point_conversion + ", " + discount
				+ ")";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int insert_into_manager(String mname, String passwd, int permission, String indentification_number,
			String phone_number) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "INSERT INTO MANAGER VALUES(NULL, '" + mname + "', '" + passwd + "', " + permission + ", '"
				+ indentification_number + "', '" + phone_number + "')";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int insert_into_sales_record(String ISBN, float unit_price, int member_id, int quantity)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		java.util.Date current_util_date = new java.util.Date();	// 获取当前时间
		Date current_sql_date = new Date(current_util_date.getTime());	// 转换为 java.sql.Date 类型
		String sale_of_date = current_sql_date.toString(); // 转化为 YYYY-MM-DD 格式的字符串

		String sql = "INSERT INTO SALES_RECORD VALUES(NULL, '" + ISBN + "', TO_DATE('" + sale_of_date
				+ "','YYYY-MM-DD'), " + unit_price + ", " + member_id + ", 1, " + quantity + ")";

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int insert_into_purchase_record(String ISBN, int pcount, float unit_price, int publisher_id)
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

	public int delete_from_members_group(String mid) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "DELETE FROM MEMBERS_GROUP WHERE MID=" + mid;

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int delete_from_manager(String mid) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "DELETE FROM MANAGER WHERE MID=" + mid;

		int count = stmt.executeUpdate(sql);

		stmt.close();
		connection.close();

		return count;
	}

	public int update_books(String[] set_keys, String[] set_values, String key, String value)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "UPDATE BOOKS SET ";
		int i = 0;
		for (; i < set_keys.length - 1; i++) {
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

	public int update_members_group(String[] set_keys, String[] set_values, String key, String value)
			throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.OracleDriver");

		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement stmt = connection.createStatement();

		String sql = "UPDATE MEMBERS_GROUP SET ";
		int i = 0;
		for (; i < set_keys.length - 1; i++) {
			if (set_keys[i] == "MNAME")
				sql += set_keys[i] + "='" + set_values[i] + "', ";
			else
				sql += set_keys[i] + "=" + set_values[i] + ", ";
		}
		if (set_keys[i] == "MNAME")
			sql += set_keys[i] + "='" + set_values[i] + "' WHERE " + key + "='" + value + "'";
		else
			sql += set_keys[i] + "=" + set_values[i] + " WHERE " + key + "='" + value + "'";

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

	public int sales_record_transform_to_invalid(String serial_number)
			throws SQLException, ClassNotFoundException {
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