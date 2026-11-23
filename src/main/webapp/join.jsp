<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="util.HtmlUtil"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%
	// 이미 로그인했으면 가입 화면이 필요 없다
	if (session.getAttribute("loginId") != null) {
		response.sendRedirect("events.jsp");
		return;
	}

	// processJoin.jsp 에서 검사에 실패해 forward 로 돌아온 경우: 오류 목록(메시지 키)과 입력했던 값을 다시 보여 준다
	@SuppressWarnings("unchecked")
	ArrayList<String> errors = (ArrayList<String>) request.getAttribute("errors");
	String inputId = HtmlUtil.escape(request.getParameter("id"));
	String inputName = HtmlUtil.escape(request.getParameter("name"));
	String inputStudentNo = HtmlUtil.escape(request.getParameter("studentNo"));
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<link rel="stylesheet" href="./resources/css/clubcheck.css">
<%@ include file="jsMessages.jsp"%>
<script type="text/javascript" src="./resources/js/validation.js"></script>
<title><fmt:message key="join.pageTitle" /> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="cc-hero mb-4">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><fmt:message key="join.pageTitle" /></h1>
				<p class="col-md-8 fs-5 mb-0"><fmt:message key="join.lead" /></p>
			</div>
		</div>

		<div class="row justify-content-center">
			<div class="col-md-6">
				<%@ include file="errorList.jsp"%>

				<form name="joinForm" action="./processJoin.jsp" method="post"
					onsubmit="return checkJoin()">
					<div class="mb-3">
						<label for="id" class="form-label"><fmt:message key="join.id" /></label>
						<input type="text" id="id" name="id" class="form-control"
							maxlength="20" value="<%=inputId%>" autocomplete="username">
						<div class="form-text"><fmt:message key="join.idHelp" /></div>
					</div>
					<div class="mb-3">
						<label for="password" class="form-label"><fmt:message key="join.password" /></label>
						<input type="password" id="password" name="password" class="form-control"
							maxlength="20" autocomplete="new-password">
						<div class="form-text"><fmt:message key="join.passwordHelp" /></div>
					</div>
					<div class="mb-3">
						<label for="passwordConfirm" class="form-label"><fmt:message key="join.passwordConfirm" /></label>
						<input type="password" id="passwordConfirm" name="passwordConfirm"
							class="form-control" maxlength="20" autocomplete="new-password">
					</div>
					<div class="mb-3">
						<label for="name" class="form-label"><fmt:message key="join.name" /></label>
						<input type="text" id="name" name="name" class="form-control"
							maxlength="20" value="<%=inputName%>">
					</div>
					<div class="mb-4">
						<label for="studentNo" class="form-label"><fmt:message key="join.studentNo" /></label>
						<input type="text" id="studentNo" name="studentNo" class="form-control"
							maxlength="9" inputmode="numeric" placeholder="202211469"
							value="<%=inputStudentNo%>">
						<div class="form-text"><fmt:message key="join.studentNoHelp" /></div>
					</div>
					<button type="submit" class="btn btn-primary w-100"><fmt:message key="join.submit" /></button>
				</form>
				<p class="text-center mt-3">
					<fmt:message key="join.haveAccount" /> <a href="./login.jsp"><fmt:message key="join.loginLink" /></a>
				</p>
			</div>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
