<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="util.HtmlUtil"%>
<%
	// 이미 로그인했으면 가입 화면이 필요 없다
	if (session.getAttribute("loginId") != null) {
		response.sendRedirect("events.jsp");
		return;
	}

	// processJoin.jsp 에서 검사에 실패해 forward 로 돌아온 경우: 오류 목록과 입력했던 값을 다시 보여 준다
	@SuppressWarnings("unchecked")
	ArrayList<String> errors = (ArrayList<String>) request.getAttribute("errors");
	String inputId = HtmlUtil.escape(request.getParameter("id"));
	String inputName = HtmlUtil.escape(request.getParameter("name"));
	String inputStudentNo = HtmlUtil.escape(request.getParameter("studentNo"));
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<script type="text/javascript" src="./resources/js/validation.js"></script>
<title>회원가입 - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold">회원가입</h1>
				<p class="col-md-8 fs-5 mb-0">가입하면 행사 참석을 신청할 수 있습니다.</p>
			</div>
		</div>

		<div class="row justify-content-center">
			<div class="col-md-6">
				<%
				if (errors != null && !errors.isEmpty()) {
				%>
				<div class="alert alert-danger" role="alert">
					<ul class="mb-0">
						<%
						for (String error : errors) {
						%>
						<li><%=HtmlUtil.escape(error)%></li>
						<%
						}
						%>
					</ul>
				</div>
				<%
				}
				%>

				<form name="joinForm" action="./processJoin.jsp" method="post"
					onsubmit="return checkJoin()">
					<div class="mb-3">
						<label for="id" class="form-label">아이디</label>
						<input type="text" id="id" name="id" class="form-control"
							maxlength="20" value="<%=inputId%>" autocomplete="username">
						<div class="form-text">영문 소문자로 시작, 영문 소문자와 숫자 4~20자</div>
					</div>
					<div class="mb-3">
						<label for="password" class="form-label">비밀번호</label>
						<input type="password" id="password" name="password" class="form-control"
							maxlength="20" autocomplete="new-password">
						<div class="form-text">8~20자, 영문과 숫자를 모두 포함</div>
					</div>
					<div class="mb-3">
						<label for="passwordConfirm" class="form-label">비밀번호 확인</label>
						<input type="password" id="passwordConfirm" name="passwordConfirm"
							class="form-control" maxlength="20" autocomplete="new-password">
					</div>
					<div class="mb-3">
						<label for="name" class="form-label">이름</label>
						<input type="text" id="name" name="name" class="form-control"
							maxlength="20" value="<%=inputName%>">
					</div>
					<div class="mb-4">
						<label for="studentNo" class="form-label">학번</label>
						<input type="text" id="studentNo" name="studentNo" class="form-control"
							maxlength="9" inputmode="numeric" placeholder="202211469"
							value="<%=inputStudentNo%>">
						<div class="form-text">입학 연도 4자리 + 일련번호 5자리</div>
					</div>
					<button type="submit" class="btn btn-primary w-100">가입하기</button>
				</form>
				<p class="text-center mt-3">
					이미 회원이신가요? <a href="./login.jsp">로그인</a>
				</p>
			</div>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
