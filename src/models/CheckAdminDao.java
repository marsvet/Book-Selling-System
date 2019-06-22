package models;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class CheckAdminDao {
	private final String URL = "jdbc:oracle:thin:@localhost:1521:xe"; // 连接字符串
	private final String USERNAME = "bookselling"; // 用户名
	private final String PASSWORD = "bookselling"; // 密码

	public int check_admin(String mname, String passwd) throws ClassNotFoundException, SQLException {
		String sql = "SELECT COUNT(*) FROM MANAGER WHERE MNAME='" + mname + "' AND PASSWD='" + passwd + "'"; // 注意：SQL语句最后不能加分号
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

}
