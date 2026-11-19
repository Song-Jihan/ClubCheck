<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.Member"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="dto.Attendance"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%@ include file="loginCheck.jsp"%>
<jsp:useBean id="memberDAO" class="dao.MemberDAO" scope="page" />
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<%
	Member member = memberDAO.findById((String) session.getAttribute("loginId"));

	// 로그인한 뒤 DB 에서 회원이 지워진 경우: 세션을 정리하고 다시 로그인하게 한다
	if (member == null) {
		session.invalidate();
		response.sendRedirect("login.jsp?msg=needLogin");
		return;
	}

	// 내 참석 기록과 출석률. 출석률은 출석 처리가 끝난(출석 또는 결석) 행사만으로 계산한다
	ArrayList<Attendance> records = attendanceDAO.getByMember(member.getId());
	int presentCount = 0, absentCount = 0, upcomingCount = 0;
	for (Attendance r : records) {
		if (Attendance.PRESENT.equals(r.getStatus())) {
			presentCount++;
		} else if (Attendance.ABSENT.equals(r.getStatus())) {
			absentCount++;
		} else if (!r.isEventPast()) {
			upcomingCount++;
		}
	}
	int checkedCount = presentCount + absentCount;
	int attendanceRate = (checkedCount == 0) ? 0 : Math.round(presentCount * 100f / checkedCount);
	String entranceYear = member.getEntranceYear();
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<title><fmt:message key="my.pageTitle" /> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><fmt:message key="my.pageTitle" /></h1>
				<p class="col-md-8 fs-5 mb-0"><fmt:message key="my.lead" /></p>
			</div>
		</div>

		<div class="row">
			<div class="col-md-6">
				<table class="table">
					<tbody>
						<tr>
							<th scope="row" class="w-25"><fmt:message key="my.id" /></th>
							<td><%=HtmlUtil.escape(member.getId())%></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="my.name" /></th>
							<td><%=HtmlUtil.escape(member.getName())%></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="my.studentNo" /></th>
							<td><%=HtmlUtil.escape(member.getStudentNo())%>
								<span class="text-secondary"><fmt:message key="my.entranceYear"><fmt:param value="<%=entranceYear%>" /></fmt:message></span></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="my.role" /></th>
							<td><%=msg(pageContext, member.isAdmin() ? "role.admin" : "role.member")%></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="my.joinedAt" /></th>
							<td><%=DateUtil.format(member.getJoinedAt(), lang)%></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-md-6">
				<div class="card">
					<div class="card-body">
						<h5 class="card-title"><fmt:message key="my.rateTitle" /></h5>
						<%
						if (checkedCount == 0) {
						%>
						<p class="text-secondary mb-0"><fmt:message key="my.rateNone" /></p>
						<%
						} else {
						%>
						<p class="display-6 fw-bold mb-2"><%=attendanceRate%>%</p>
						<%-- 외부 라이브러리 없이 div 너비로 막대를 그린다 --%>
						<div class="progress mb-2" role="progressbar" aria-valuenow="<%=attendanceRate%>"
							aria-valuemin="0" aria-valuemax="100">
							<div class="progress-bar bg-success" style="width: <%=attendanceRate%>%"></div>
						</div>
						<p class="text-secondary mb-0"><fmt:message key="my.rateDetail"><fmt:param value="<%=presentCount%>" /><fmt:param value="<%=absentCount%>" /></fmt:message></p>
						<%
						}
						%>
						<p class="text-secondary mb-0"><fmt:message key="my.upcoming"><fmt:param value="<%=upcomingCount%>" /></fmt:message></p>
					</div>
				</div>
			</div>
		</div>

		<h4 class="mt-5 mb-3"><fmt:message key="my.records" /></h4>
		<%
		if (records.isEmpty()) {
		%>
		<p class="text-secondary"><fmt:message key="my.recordsEmpty" /> <a href="./events.jsp"><fmt:message key="my.recordsEmptyLink" /></a></p>
		<%
		} else {
		%>
		<table class="table align-middle">
			<thead>
				<tr>
					<th scope="col"><fmt:message key="my.colEvent" /></th>
					<th scope="col"><fmt:message key="my.colDate" /></th>
					<th scope="col"><fmt:message key="my.colStatus" /></th>
				</tr>
			</thead>
			<tbody>
				<%
				for (Attendance r : records) {
					String badge;
					if (Attendance.PRESENT.equals(r.getStatus())) {
						badge = "<span class=\"badge text-bg-success\">" + msg(pageContext, "badge.present") + "</span>";
					} else if (Attendance.ABSENT.equals(r.getStatus())) {
						badge = "<span class=\"badge text-bg-danger\">" + msg(pageContext, "badge.absent") + "</span>";
					} else if (r.isEventPast()) {
						badge = "<span class=\"badge text-bg-secondary\">" + msg(pageContext, "badge.pending") + "</span>";
					} else {
						badge = "<span class=\"badge text-bg-primary\">" + msg(pageContext, "badge.upcoming") + "</span>";
					}
				%>
				<tr>
					<td><a href="./event.jsp?id=<%=r.getEventId()%>"><%=HtmlUtil.escape(r.getEventTitle())%></a></td>
					<td><%=DateUtil.format(r.getEventDate(), lang)%></td>
					<td><%=badge%></td>
				</tr>
				<%
				}
				%>
			</tbody>
		</table>
		<%
		}
		%>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
