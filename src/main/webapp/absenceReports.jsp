<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="dto.Attendance"%>
<%@ page import="dto.AbsenceReport"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%@ include file="adminCheck.jsp"%>
<jsp:useBean id="absenceReportDAO" class="dao.AbsenceReportDAO" scope="page" />
<%
	// 관리자용 결석사유서 목록 (최근에 내거나 고친 것부터)
	ArrayList<AbsenceReport> reports = absenceReportDAO.findAll();
	int reportCount = reports.size();
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<title><fmt:message key="reports.pageTitle" /> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>
		<%@ include file="message.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><fmt:message key="reports.pageTitle" /></h1>
				<p class="fs-5 mb-0"><fmt:message key="reports.lead"><fmt:param value="<%=reportCount%>" /></fmt:message></p>
			</div>
		</div>

		<%
		if (reports.isEmpty()) {
		%>
		<p class="text-secondary"><fmt:message key="reports.empty" /></p>
		<%
		} else {
		%>
		<div class="table-responsive">
			<table class="table align-middle">
				<thead>
					<tr>
						<th scope="col"><fmt:message key="reports.colUpdated" /></th>
						<th scope="col"><fmt:message key="reports.colEvent" /></th>
						<th scope="col"><fmt:message key="reports.colEventDate" /></th>
						<th scope="col"><fmt:message key="reports.colMember" /></th>
						<th scope="col"><fmt:message key="reports.colStudentNo" /></th>
						<th scope="col"><fmt:message key="reports.colTitle" /></th>
						<th scope="col"><fmt:message key="reports.colEvidence" /></th>
						<th scope="col"><fmt:message key="reports.colStatus" /></th>
						<th scope="col"></th>
					</tr>
				</thead>
				<tbody>
					<%
					for (AbsenceReport r : reports) {
						String status = r.getAttendanceStatus();
						String statusKey = Attendance.PRESENT.equals(status) ? "badge.present"
								: Attendance.ABSENT.equals(status) ? "badge.absent" : "badge.pending";
						String statusColor = Attendance.PRESENT.equals(status) ? "text-bg-success"
								: Attendance.ABSENT.equals(status) ? "text-bg-danger" : "text-bg-secondary";
						boolean hasEvidence = r.getEvidenceFilename() != null && !r.getEvidenceFilename().isEmpty();
					%>
					<tr>
						<td class="small text-secondary"><%=DateUtil.format(r.getUpdatedAt(), lang)%></td>
						<td><%=HtmlUtil.escape(r.getEventTitle())%></td>
						<td class="small"><%=DateUtil.format(r.getEventDate(), lang)%></td>
						<td><%=HtmlUtil.escape(r.getMemberName())%></td>
						<td class="text-secondary"><%=HtmlUtil.escape(r.getStudentNo())%></td>
						<td><%=HtmlUtil.escape(r.getTitle())%></td>
						<td><%=msg(pageContext, hasEvidence ? "reports.yes" : "reports.no")%></td>
						<td><span class="badge <%=statusColor%>"><fmt:message key="<%=statusKey%>" /></span></td>
						<td><a href="./absenceReport.jsp?id=<%=r.getReportId()%>" class="btn btn-outline-primary btn-sm"><fmt:message key="reports.view" /></a></td>
					</tr>
					<%
					}
					%>
				</tbody>
			</table>
		</div>
		<%
		}
		%>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
