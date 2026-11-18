<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.Member"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ include file="loginCheck.jsp"%>
<jsp:useBean id="memberDAO" class="dao.MemberDAO" scope="page" />
<%
	Member member = memberDAO.findById((String) session.getAttribute("loginId"));

	// 로그인한 뒤 DB 에서 회원이 지워진 경우: 세션을 정리하고 다시 로그인하게 한다
	if (member == null) {
		session.invalidate();
		response.sendRedirect("login.jsp?msg=needLogin");
		return;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<title>내 정보 - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold">내 정보</h1>
				<p class="col-md-8 fs-5 mb-0">My Page</p>
			</div>
		</div>

		<div class="row">
			<div class="col-md-6">
				<table class="table">
					<tbody>
						<tr>
							<th scope="row" class="w-25">아이디</th>
							<td><%=HtmlUtil.escape(member.getId())%></td>
						</tr>
						<tr>
							<th scope="row">이름</th>
							<td><%=HtmlUtil.escape(member.getName())%></td>
						</tr>
						<tr>
							<th scope="row">학번</th>
							<td><%=HtmlUtil.escape(member.getStudentNo())%>
								<span class="text-secondary">(<%=member.getEntranceYear()%>학번)</span></td>
						</tr>
						<tr>
							<th scope="row">권한</th>
							<td><%=member.isAdmin() ? "관리자" : "일반 회원"%></td>
						</tr>
						<tr>
							<th scope="row">가입일</th>
							<td><%=DateUtil.format(member.getJoinedAt())%></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
