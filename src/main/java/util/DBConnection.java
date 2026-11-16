package util;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * MySQL 연결을 만들어 주는 클래스.
 * 접속 정보(주소, 계정, 비밀번호)는 코드에 적지 않고 db.properties 파일에서 읽는다.
 * db.properties 는 git 에 올리지 않는다. 만드는 방법은 db.properties.example 을 참고한다.
 */
public class DBConnection {

	// src/main/java 바로 아래에 두면 톰캣의 WEB-INF/classes 로 복사되어 클래스패스에서 찾을 수 있다
	private static final String CONFIG_FILE = "db.properties";

	// 한 번 읽은 설정은 다시 읽지 않는다
	private static Properties config;

	public static Connection getConnection() throws SQLException {
		Properties props = loadConfig();
		String url = require(props, "DB_URL");
		String user = require(props, "DB_USER");
		// 비밀번호가 빈 계정도 있으므로 값은 비워도 되지만, 항목 자체는 있어야 한다
		if (!props.containsKey("DB_PASSWORD")) {
			throw new SQLException(CONFIG_FILE + " 에 DB_PASSWORD 항목이 없습니다.");
		}
		String password = props.getProperty("DB_PASSWORD");

		try {
			// 톰캣에서는 드라이버를 직접 로딩해 주는 것이 안전하다
			Class.forName("com.mysql.cj.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			throw new SQLException(
					"MySQL 드라이버를 찾을 수 없습니다. WEB-INF/lib 에 mysql-connector-j jar 를 넣었는지 확인하세요.", e);
		}
		return DriverManager.getConnection(url, user, password);
	}

	/** 클래스패스의 db.properties 를 UTF-8 로 읽는다. */
	private static synchronized Properties loadConfig() throws SQLException {
		if (config != null) {
			return config;
		}
		try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream(CONFIG_FILE)) {
			if (in == null) {
				throw new SQLException(CONFIG_FILE + " 파일을 찾을 수 없습니다. "
						+ "src/main/java/db.properties.example 을 같은 폴더에 db.properties 로 복사해서 "
						+ "접속 정보를 입력한 뒤 서버를 다시 시작하세요.");
			}
			Properties props = new Properties();
			props.load(new InputStreamReader(in, StandardCharsets.UTF_8));
			config = props;
			return config;
		} catch (IOException e) {
			throw new SQLException(CONFIG_FILE + " 를 읽는 중 오류가 발생했습니다.", e);
		}
	}

	private static String require(Properties props, String key) throws SQLException {
		String value = props.getProperty(key);
		if (value == null || value.trim().isEmpty()) {
			throw new SQLException(CONFIG_FILE + " 에 " + key + " 값이 없습니다.");
		}
		return value.trim();
	}
}
