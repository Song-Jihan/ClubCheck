package util;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Locale;

/** 날짜를 화면에 보여 줄 문자열로 바꾸는 도우미. */
public class DateUtil {

	/** 예: 2026.11.19 (목) 18:30 */
	public static String format(Timestamp date) {
		if (date == null) {
			return "";
		}
		SimpleDateFormat format = new SimpleDateFormat("yyyy.MM.dd (E) HH:mm", Locale.KOREAN);
		return format.format(date);
	}
}
