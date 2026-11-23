<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="dto.Event"%>
<%@ page import="dto.Attendance"%>
<%@ page import="dto.AbsenceReport"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ page import="util.AbsenceValidator"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%@ include file="loginCheck.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<jsp:useBean id="absenceReportDAO" class="dao.AbsenceReportDAO" scope="page" />
<%
	// 결석사유서 작성과 수정을 함께 처리하는 화면
	//  - absenceForm.jsp?eventId=2 : 2번 행사의 내 사유서. 이미 냈으면 수정, 아직이면 작성
	//  - processAbsence.jsp 에서 검사에 실패해 forward 로 돌아온 경우: request 속성에 입력값과 오류가 들어 있다
	String loginId = (String) session.getAttribute("loginId");
	AbsenceReport formReport = (AbsenceReport) request.getAttribute("formReport");
	@SuppressWarnings("unchecked")
	ArrayList<String> errors = (ArrayList<String>) request.getAttribute("errors");

	int eventId;
	try {
		eventId = (formReport != null) ? formReport.getEventId() : Integer.parseInt(request.getParameter("eventId"));
	} catch (NumberFormatException e) {
		response.sendRedirect("myPage.jsp?msg=notFound");
		return;
	}
	Event event = eventDAO.getEventById(eventId);
	if (event == null) {
		response.sendRedirect("myPage.jsp?msg=notFound");
		return;
	}

	// 이미 낸 사유서는 언제든 고칠 수 있다. 새로 쓰는 것은 정기세미나에 결석으로 처리된 경우만 가능하다
	AbsenceReport saved = absenceReportDAO.findByEventAndMember(eventId, loginId);
	if (saved == null && !(event.isSeminar() && Attendance.ABSENT.equals(attendanceDAO.getStatus(eventId, loginId)))) {
		response.sendRedirect("myPage.jsp?msg=reportNotAllowed");
		return;
	}
	if (formReport == null) {
		formReport = (saved != null) ? saved : new AbsenceReport();
	}

	boolean isEdit = saved != null;
	String pageTitle = msg(pageContext, isEdit ? "absence.editTitle" : "absence.writeTitle");
	String currentEvidence = (saved != null) ? saved.getEvidenceFilename() : null;
	String cancelUrl = isEdit ? "./absenceReport.jsp?id=" + saved.getReportId() : "./myPage.jsp";
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<link rel="stylesheet" href="./resources/css/clubcheck.css">
<%@ include file="jsMessages.jsp"%>
<script type="text/javascript" src="./resources/js/validation.js"></script>
<title><%=pageTitle%> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="cc-hero mb-4">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><%=pageTitle%></h1>
				<p class="col-md-8 fs-5 mb-0"><fmt:message key="absence.lead" /></p>
			</div>
		</div>

		<div class="row justify-content-center">
			<div class="col-md-8">
				<%@ include file="errorList.jsp"%>

				<%-- 해당 행사와 행사 날짜는 고를 수 없고 보여 주기만 한다 (행사 번호는 hidden 칸으로 보낸다) --%>
				<table class="table">
					<tbody>
						<tr>
							<th scope="row" class="w-25"><fmt:message key="absence.event" /></th>
							<td><%=HtmlUtil.escape(event.getTitle())%></td>
						</tr>
						<tr>
							<th scope="row"><fmt:message key="absence.eventDate" /></th>
							<td><%=DateUtil.format(event.getEventDate(), lang)%></td>
						</tr>
					</tbody>
				</table>

				<form name="absenceForm" action="./processAbsence.jsp" method="post"
					enctype="multipart/form-data" onsubmit="return checkAbsence()">
					<input type="hidden" name="eventId" value="<%=event.getEventId()%>">

					<div class="mb-3">
						<label for="title" class="form-label"><fmt:message key="absence.title" /></label>
						<input type="text" id="title" name="title" class="form-control"
							maxlength="<%=AbsenceValidator.TITLE_MAX%>"
							value="<%=HtmlUtil.escape(formReport.getTitle())%>">
					</div>
					<div class="mb-3">
						<label for="reason" class="form-label"><fmt:message key="absence.reason" /></label>
						<textarea id="reason" name="reason" class="form-control" rows="5"
							maxlength="<%=AbsenceValidator.REASON_MAX%>"><%=HtmlUtil.escape(formReport.getReason())%></textarea>
						<div class="form-text"><fmt:message key="absence.reasonHelp" /></div>
					</div>
					<div class="mb-4">
						<label for="evidence" class="form-label"><fmt:message key="absence.evidence" /></label>
						<%
						if (currentEvidence != null && !currentEvidence.isEmpty()) {
						%>
						<div class="d-flex align-items-center gap-3 mb-2">
							<img src="./evidence.jsp?id=<%=saved.getReportId()%>"
								alt="<fmt:message key="absence.currentEvidence" />" class="rounded border" style="height: 120px;">
							<div class="form-check">
								<input type="checkbox" id="removeEvidence" name="removeEvidence" value="on"
									class="form-check-input">
								<label for="removeEvidence" class="form-check-label"><fmt:message key="absence.removeEvidence" /></label>
							</div>
						</div>
						<%
						}
						%>
						<input type="file" id="evidence" name="evidence" class="form-control"
							accept=".jpg,.jpeg,.png,.gif,.webp,image/jpeg,image/png,image/gif,image/webp">
						<div class="form-text"><fmt:message key="absence.evidenceHelp" /></div>
					</div>

					<div class="d-flex gap-2">
						<button type="submit" class="btn btn-primary"><%=msg(pageContext, isEdit ? "absence.save" : "absence.submit")%></button>
						<a href="<%=cancelUrl%>" class="btn btn-outline-secondary"><fmt:message key="absence.cancel" /></a>
					</div>
				</form>
			</div>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
