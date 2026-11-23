<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.Attendance"%>
<%@ page import="dto.AbsenceReport"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%@ include file="loginCheck.jsp"%>
<jsp:useBean id="absenceReportDAO" class="dao.AbsenceReportDAO" scope="page" />
<%
	// 결석사유서 한 건 보기. 본인 또는 관리자만 볼 수 있다
	AbsenceReport report = null;
	try {
		report = absenceReportDAO.findById(Integer.parseInt(request.getParameter("id")));
	} catch (NumberFormatException e) {
		report = null;
	}
	String loginId = (String) session.getAttribute("loginId");
	boolean isAdmin = "ADMIN".equals(session.getAttribute("loginRole"));
	boolean isOwner = report != null && report.getMemberId().equals(loginId);
	if (report == null || !(isOwner || isAdmin)) {
		// 남의 사유서인지 없는 사유서인지 구별하지 않고 같은 안내를 보여 준다
		response.sendRedirect((isAdmin ? "absenceReports.jsp" : "myPage.jsp") + "?msg=reportNotFound");
		return;
	}

	String status = report.getAttendanceStatus();
	String statusKey = Attendance.PRESENT.equals(status) ? "badge.present"
			: Attendance.ABSENT.equals(status) ? "badge.absent" : "badge.pending";
	String statusColor = Attendance.PRESENT.equals(status) ? "text-bg-success"
			: Attendance.ABSENT.equals(status) ? "text-bg-danger" : "text-bg-secondary";
	String evidence = report.getEvidenceFilename();
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<link rel="stylesheet" href="./resources/css/clubcheck.css">
<title><fmt:message key="absence.detailTitle" /> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>
		<%@ include file="message.jsp"%>

		<div class="cc-hero mb-4">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><fmt:message key="absence.detailTitle" /></h1>
				<p class="fs-5 mb-0"><%=HtmlUtil.escape(report.getTitle())%></p>
			</div>
		</div>

		<div class="row">
			<div class="col-md-7">
				<%
				if (!Attendance.ABSENT.equals(status)) {
				%>
				<div class="alert alert-info"><fmt:message key="absence.statusChanged" /></div>
				<%
				}
				%>
				<table class="table">
					<tbody>
						<tr>
							<th scope="row" class="w-25"><fmt:message key="absence.event" /></th>
							<td><a href="./event.jsp?id=<%=report.getEventId()%>"><%=HtmlUtil.escape(report.getEventTitle())%></a></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="absence.eventDate" /></th>
							<td><%=DateUtil.format(report.getEventDate(), lang)%></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="absence.member" /></th>
							<td><%=HtmlUtil.escape(report.getMemberName())%>
								<span class="text-secondary">(<%=HtmlUtil.escape(report.getStudentNo())%>)</span></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="absence.attendance" /></th>
							<td><span class="badge <%=statusColor%>"><fmt:message key="<%=statusKey%>" /></span></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="absence.title" /></th>
							<td><%=HtmlUtil.escape(report.getTitle())%></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="absence.reason" /></th>
							<td><%=HtmlUtil.escapeWithBreaks(report.getReason())%></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="absence.submittedAt" /></th>
							<td><%=DateUtil.format(report.getCreatedAt(), lang)%></td>
						</tr>
						<%
						if (report.isEdited()) {
						%>
						<tr>
							<th scope="row"><fmt:message key="absence.updatedAt" /></th>
							<td><%=DateUtil.format(report.getUpdatedAt(), lang)%></td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>
			<div class="col-md-5">
				<h2 class="h6"><fmt:message key="absence.evidence" /></h2>
				<%
				if (evidence != null && !evidence.isEmpty()) {
				%>
				<a href="./evidence.jsp?id=<%=report.getReportId()%>" target="_blank">
					<img src="./evidence.jsp?id=<%=report.getReportId()%>" alt="<fmt:message key="absence.evidenceAlt" />"
						class="img-fluid rounded border"></a>
				<%
				} else {
				%>
				<p class="text-secondary"><fmt:message key="absence.noEvidence" /></p>
				<%
				}
				%>
			</div>
		</div>

		<div class="d-flex gap-2 mt-3">
			<%
			// 수정은 본인만 할 수 있다 (관리자는 확인만)
			if (isOwner) {
			%>
			<a href="./absenceForm.jsp?eventId=<%=report.getEventId()%>" class="btn btn-primary"><fmt:message key="absence.edit" /></a>
			<a href="./myPage.jsp" class="btn btn-outline-secondary"><fmt:message key="absence.backToMy" /></a>
			<%
			}
			if (isAdmin) {
			%>
			<a href="./absenceReports.jsp" class="btn btn-outline-secondary"><fmt:message key="absence.backToList" /></a>
			<%
			}
			%>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
