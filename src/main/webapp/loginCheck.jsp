<%@ page pageEncoding="UTF-8"%>
<%-- 로그인이 필요한 화면 맨 위에 include 디렉티브로 넣는다. 로그인하지 않았으면 로그인 화면으로 보낸다. --%>
<%
if (session.getAttribute("loginId") == null) {
	response.sendRedirect("login.jsp?msg=needLogin");
	return;
}
%>
