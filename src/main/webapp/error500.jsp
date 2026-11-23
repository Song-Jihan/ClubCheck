<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<%@ page import="util.HtmlUtil"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%-- 처리 중 예외가 생겼을 때 보여 주는 화면.
     - process*.jsp 의 page 디렉티브 errorPage="error500.jsp" 로 연결되고,
     - 그 밖의 화면은 web.xml 의 <error-page> (500, java.lang.Throwable) 로 연결된다.
     isErrorPage="true" 라서 내장 객체 exception 으로 발생한 예외를 받을 수 있다. --%>
<%
	String ctx = request.getContextPath();

	// 원인이 감싸져 있으면(ServletException 등) 가장 안쪽 원인을 찾는다
	Throwable rootCause = exception;
	while (rootCause != null && rootCause.getCause() != null && rootCause.getCause() != rootCause) {
		rootCause = rootCause.getCause();
	}
	if (exception != null) {
		// 서버 로그에는 전체 내용을 남긴다
		application.log("ClubCheck 처리 중 오류", exception);
	}

	// 자세한 오류 정보는 관리자에게만 보여 준다 (일반 사용자에게 내부 구조를 드러내지 않기 위해)
	boolean showDetail = rootCause != null && "ADMIN".equals(session.getAttribute("loginRole"));
	String detail = showDetail
			? HtmlUtil.escape(rootCause.getClass().getName() + (rootCause.getMessage() != null ? ": " + rootCause.getMessage() : ""))
			: "";
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="<%=ctx%>/resources/css/bootstrap.min.css">
<link rel="stylesheet" href="<%=ctx%>/resources/css/clubcheck.css">
<title><fmt:message key="error.500.title" /> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="cc-hero mb-4 text-center">
			<p class="text-secondary mb-2"><fmt:message key="error.code"><fmt:param value="500" /></fmt:message></p>
			<h1 class="display-6 fw-bold"><fmt:message key="error.500.title" /></h1>
			<p class="fs-5"><fmt:message key="error.500.text" /></p>
			<a href="<%=ctx%>/events.jsp" class="btn btn-primary"><fmt:message key="error.home" /></a>
		</div>
		<%
		if (showDetail) {
		%>
		<div class="alert alert-secondary small">
			<b><fmt:message key="error.detail" /></b><br>
			<code><%=detail%></code>
		</div>
		<%
		}
		%>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
