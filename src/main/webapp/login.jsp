<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.MemberValidator"%>
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
	String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<script type="text/javascript" src="./resources/js/validation.js"></script>
<title>로그인 - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold">로그인</h1>
				<p class="col-md-8 fs-5 mb-0">Login</p>
			</div>
		</div>

		<div class="row justify-content-center">
			<div class="col-md-5">
				<%@ include file="message.jsp"%>
				<%
				if (errorMsg != null) {
				%>
				<div class="alert alert-danger" role="alert"><%=HtmlUtil.escape(errorMsg)%></div>
				<%
				}
				%>

				<form name="loginForm" action="./processLogin.jsp" method="post"
					onsubmit="return checkLogin()">
					<div class="mb-3">
						<label for="id" class="form-label">아이디</label>
						<input type="text" id="id" name="id" class="form-control" maxlength="20"
							value="<%=HtmlUtil.escape(inputId)%>" autocomplete="username">
					</div>
					<div class="mb-3">
						<label for="password" class="form-label">비밀번호</label>
						<input type="password" id="password" name="password" class="form-control"
							maxlength="20" autocomplete="current-password">
					</div>
					<div class="form-check mb-4">
						<input type="checkbox" id="rememberId" name="rememberId" value="on"
							class="form-check-input" <%=(savedId != null) ? "checked" : ""%>>
						<label for="rememberId" class="form-check-label">아이디 저장</label>
					</div>
					<button type="submit" class="btn btn-primary w-100">로그인</button>
				</form>
				<p class="text-center mt-3">
					아직 회원이 아니신가요? <a href="./join.jsp">회원가입</a>
				</p>
			</div>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
