<%@ page pageEncoding="UTF-8"%>
<%-- 관리자 전용 화면 맨 위에 include 디렉티브로 넣는다.
     로그인하지 않았으면 로그인 화면으로, 일반 회원이면 행사 목록으로 보낸다. --%>
<%
if (session.getAttribute("loginId") == null) {
	response.sendRedirect("login.jsp?msg=needLogin");
	return;
}
if (!"ADMIN".equals(session.getAttribute("loginRole"))) {
	response.sendRedirect("events.jsp?msg=noAuth");
	return;
}
%>
