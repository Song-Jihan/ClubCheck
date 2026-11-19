<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.MemberValidator"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%
	if (session.getAttribute("loginId") != null) {
		response.sendRedirect("events.jsp");
		return;
	}

	// '아이디 저장' 쿠키를 찾는다. 쿠키는 사용자가 바꿀 수 있으므로 아이디 형식에 맞을 때만 쓴다
	String savedId = null;
	Cookie[] cookies = request.getCookies();
	if (cookies != null) {
		for (Cookie cookie : cookies) {
			if ("savedId".equals(cookie.getName()) && MemberValidator.isValidId(cookie.getValue())) {
				savedId = cookie.getValue();
			}
		}
	}

	// 아이디 칸에 채울 값: 방금 입력한 값(로그인 실패, 가입 직후) > 저장된 아이디
	String inputId = request.getParameter("id");
	if (inputId == null) {
		inputId = (savedId != null) ? savedId : "";
	}
	// processLogin.jsp 에서 로그인에 실패해 forward 로 돌아온 경우의 오류 메시지 키
	String errorKey = (String) request.getAttribute("errorKey");
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<%@ include file="jsMessages.jsp"%>
<script type="text/javascript" src="./resources/js/validation.js"></script>
<title><fmt:message key="login.pageTitle" /> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><fmt:message key="login.pageTitle" /></h1>
				<p class="col-md-8 fs-5 mb-0"><fmt:message key="login.lead" /></p>
			</div>
		</div>

		<div class="row justify-content-center">
			<div class="col-md-5">
				<%@ include file="message.jsp"%>
				<%
				if (errorKey != null) {
				%>
				<div class="alert alert-danger" role="alert"><fmt:message key="<%=errorKey%>" /></div>
				<%
				}
				%>

				<form name="loginForm" action="./processLogin.jsp" method="post"
					onsubmit="return checkLogin()">
					<div class="mb-3">
						<label for="id" class="form-label"><fmt:message key="login.id" /></label>
						<input type="text" id="id" name="id" class="form-control" maxlength="20"
							value="<%=HtmlUtil.escape(inputId)%>" autocomplete="username">
					</div>
					<div class="mb-3">
						<label for="password" class="form-label"><fmt:message key="login.password" /></label>
						<input type="password" id="password" name="password" class="form-control"
							maxlength="20" autocomplete="current-password">
					</div>
					<div class="form-check mb-4">
						<input type="checkbox" id="rememberId" name="rememberId" value="on"
							class="form-check-input" <%=(savedId != null) ? "checked" : ""%>>
						<label for="rememberId" class="form-check-label"><fmt:message key="login.remember" /></label>
					</div>
					<button type="submit" class="btn btn-primary w-100"><fmt:message key="login.submit" /></button>
				</form>
				<p class="text-center mt-3">
					<fmt:message key="login.noAccount" /> <a href="./join.jsp"><fmt:message key="login.joinLink" /></a>
				</p>
			</div>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
