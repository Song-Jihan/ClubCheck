package util;

/**
 * 사용자가 입력한 문자열을 화면에 출력하기 전에 처리하는 도우미.
 * 입력값에 들어 있는 HTML 태그가 그대로 실행되지 않게 막는다 (XSS 방지).
 */
public class HtmlUtil {

	/** HTML 특수문자를 문자 참조로 바꾼다. null 은 빈 문자열로 바꾼다. */
	public static String escape(String text) {
		if (text == null) {
			return "";
		}
		return text.replace("&", "&amp;")
				.replace("<", "&lt;")
				.replace(">", "&gt;")
				.replace("\"", "&quot;")
				.replace("'", "&#39;");
	}

	/** escape 한 뒤 줄바꿈을 br 태그로 바꾼다. 여러 줄 설명 출력에 쓴다. */
	public static String escapeWithBreaks(String text) {
		return escape(text).replace("\r\n", "<br>").replace("\n", "<br>");
	}
}
