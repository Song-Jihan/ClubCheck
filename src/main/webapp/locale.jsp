<%@ page pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@ page import="util.LangUtil"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%-- 다국어 처리. 화면을 그리는 모든 JSP 맨 위에 include 디렉티브로 넣는다.
     1) ?lang=ko 또는 ?lang=en 으로 들어오면 그 언어를 쓰고 쿠키(lang, 1년)에 저장한다
     2) 파라미터가 없으면 쿠키에 저장된 언어를 쓴다
     3) 둘 다 없으면 한국어
     정한 언어와 메시지 묶음(bundle.message)은 request 범위에 두어서,
     jsp:include 로 붙는 footer.jsp 와 forward 된 화면도 같은 언어를 쓴다. --%>
<%!
	// 자바 코드 안에서 메시지가 필요할 때 쓰는 도우미 (태그를 쓸 수 없는 선언문·문자열 조립 등)
	private String msg(PageContext pc, String key) {
		return LocaleSupport.getLocalizedMessage(pc, key);
	}

	private String msg(PageContext pc, String key, Object... args) {
		return LocaleSupport.getLocalizedMessage(pc, key, args);
	}
%>
<%
	String lang = null;
	String langParam = request.getParameter("lang");
	if (LangUtil.isSupported(langParam)) {
		lang = langParam;
		Cookie langCookie = new Cookie("lang", lang);
		langCookie.setPath(request.getContextPath() + "/");
		langCookie.setMaxAge(60 * 60 * 24 * 365);
		response.addCookie(langCookie);
	} else if (request.getCookies() != null) {
		for (Cookie langCookie : request.getCookies()) {
			if ("lang".equals(langCookie.getName()) && LangUtil.isSupported(langCookie.getValue())) {
				lang = langCookie.getValue();
			}
		}
	}
	if (lang == null) {
		lang = LangUtil.KO;
	}
%>
<fmt:setLocale value="<%=lang%>" scope="request" />
<fmt:setBundle basename="bundle.message" scope="request" />
