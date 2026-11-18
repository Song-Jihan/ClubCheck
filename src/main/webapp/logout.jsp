<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 세션을 없애 로그인 정보를 지운다. '아이디 저장' 쿠키는 남겨 둔다
	session.invalidate();
	response.sendRedirect("events.jsp?msg=logout");
%>
