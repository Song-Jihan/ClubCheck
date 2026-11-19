<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%-- 없는 주소로 들어왔을 때 보여 주는 화면. web.xml 의 <error-page> (404) 로 연결된다.
     /resources/a/b.png 처럼 깊은 주소에서도 보이므로 CSS·링크는 컨텍스트 경로로 시작하는 주소를 쓴다. --%>
<%
	String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="<%=ctx%>/resources/css/bootstrap.min.css">
<title><fmt:message key="error.404.title" /> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3 text-center">
			<p class="text-secondary mb-2"><fmt:message key="error.code"><fmt:param value="404" /></fmt:message></p>
			<h1 class="display-6 fw-bold"><fmt:message key="error.404.title" /></h1>
			<p class="fs-5"><fmt:message key="error.404.text" /></p>
			<a href="<%=ctx%>/events.jsp" class="btn btn-primary"><fmt:message key="error.home" /></a>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
