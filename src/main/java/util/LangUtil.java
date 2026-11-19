package util;

/**
 * 언어(한/영) 관련 도우미.
 * 서블릿 API 를 쓰지 않는 순수 자바 코드라서 어느 환경에서도 컴파일된다.
 */
public class LangUtil {

	public static final String KO = "ko";
	public static final String EN = "en";

	/** 지원하는 언어 코드(ko, en)이면 true. 쿠키·파라미터 값 검사에 쓴다. */
	public static boolean isSupported(String lang) {
		return KO.equals(lang) || EN.equals(lang);
	}

	/**
	 * 지금 보고 있는 주소에서 언어만 바꾼 주소를 만든다.
	 * 기존 lang 과 msg(한 번 보여 주는 안내 문구) 파라미터는 빼고 lang=새언어 를 붙인다.
	 * 예: /ClubCheck/event.jsp, "id=3&msg=applied", "en" → /ClubCheck/event.jsp?id=3&lang=en
	 * 반환값은 HTML 속성에 넣기 전에 HtmlUtil.escape 해야 한다 (주소에 사용자가 넣은 값이 들어 있을 수 있다).
	 */
	public static String switchUrl(String requestUri, String queryString, String lang) {
		StringBuilder url = new StringBuilder(requestUri == null ? "" : requestUri).append('?');
		if (queryString != null && !queryString.isEmpty()) {
			for (String pair : queryString.split("&")) {
				String name = pair.contains("=") ? pair.substring(0, pair.indexOf('=')) : pair;
				if (!name.isEmpty() && !"lang".equals(name) && !"msg".equals(name)) {
					url.append(pair).append('&');
				}
			}
		}
		return url.append("lang=").append(isSupported(lang) ? lang : KO).toString();
	}
}
