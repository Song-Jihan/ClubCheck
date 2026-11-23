<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.Event"%>
<%@ page import="dto.Attendance"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<jsp:useBean id="absenceReportDAO" class="dao.AbsenceReportDAO" scope="page" />
<%
	// id 파라미터가 없거나 숫자가 아니거나, 없는 행사 번호면 목록으로 돌려보낸다
	Event event = null;
	try {
		int eventId = Integer.parseInt(request.getParameter("id"));
		event = eventDAO.getEventById(eventId);
	} catch (NumberFormatException e) {
		event = null;
	}
	if (event == null) {
		response.sendRedirect("events.jsp?msg=notFound");
		return;
	}

	String poster = event.getPosterFilename();
	if (poster == null || poster.isEmpty()) {
		poster = "poster_default.png";
	}
	int applied = event.getAppliedCount();
	int capacity = event.getCapacity();

	// 로그인한 회원이면 이 행사에 대한 내 신청 상태를 확인한다 (신청 안 했으면 null)
	String loginId = (String) session.getAttribute("loginId");
	String myStatus = (loginId != null) ? attendanceDAO.getStatus(event.getEventId(), loginId) : null;
	// 정기세미나에 결석했으면 결석사유서를 냈는지 확인한다
	dto.AbsenceReport myReport = (event.isSeminar() && Attendance.ABSENT.equals(myStatus))
			? absenceReportDAO.findByEventAndMember(event.getEventId(), loginId) : null;
	String typeKey = "type." + event.getEventType();
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<link rel="stylesheet" href="./resources/css/clubcheck.css">
<title><%=HtmlUtil.escape(event.getTitle())%> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>
		<%@ include file="message.jsp"%>

		<div class="cc-hero mb-4">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><fmt:message key="event.pageTitle" /></h1>
				<p class="col-md-8 fs-5 mb-0"><fmt:message key="event.lead" /></p>
			</div>
		</div>

		<div class="row align-items-md-stretch">
			<div class="col-md-5 mb-4">
				<img src="./resources/images/<%=HtmlUtil.escape(poster)%>"
					alt="<fmt:message key="poster.alt" />" class="rounded" style="width: 80%;">
			</div>
			<div class="col-md-6">
				<h3>
					<b><%=HtmlUtil.escape(event.getTitle())%></b>
				</h3>
				<p>
					<span class="badge <%=event.isSeminar() ? "text-bg-primary" : "text-bg-info"%>"><fmt:message key="<%=typeKey%>" /></span>
					<%
					if (event.isPast()) {
					%>
					<span class="badge text-bg-secondary"><fmt:message key="status.closed" /></span>
					<%
					} else if (event.isSeminar()) {
						// 정기세미나는 모집(신청)이 없으므로 상태 배지를 붙이지 않는다
					} else if (event.isFull()) {
					%>
					<span class="badge text-bg-danger"><fmt:message key="status.full" /></span>
					<%
					} else {
					%>
					<span class="badge text-bg-success"><fmt:message key="status.open" /></span>
					<%
					}
					%>
				</p>
				<p><%=HtmlUtil.escapeWithBreaks(event.getDescription())%></p>
				<p>
					<b><fmt:message key="event.date" /></b> :
					<%=DateUtil.format(event.getEventDate(), lang)%>
				</p>
				<p>
					<b><fmt:message key="event.location" /></b> :
					<%=HtmlUtil.escape(event.getLocation())%>
				</p>
				<%
				if (event.isSeminar()) {
				%>
				<p>
					<b><fmt:message key="event.applied" /></b> : <fmt:message key="event.seminarTarget" />
				</p>
				<p class="text-secondary small"><fmt:message key="event.seminarNote" /></p>
				<%
				} else {
				%>
				<p>
					<b><fmt:message key="event.applied" /></b> :
					<fmt:message key="event.people"><fmt:param value="<%=applied%>" /><fmt:param value="<%=capacity%>" /></fmt:message>
				</p>
				<%
				}
				%>

				<%-- 참여 영역
				     정기세미나: 신청 버튼 없음. 결석했으면 결석사유서 작성·보기 버튼
				     대외활동: 참여 신청 / 미참여 응답 / 응답 바꾸기·취소 (행사 시작 전까지) --%>
				<div class="mb-3">
					<%
					if (event.isSeminar()) {
						if (loginId != null) {
							String seminarKey = Attendance.PRESENT.equals(myStatus) ? "event.my.present"
									: Attendance.ABSENT.equals(myStatus) ? "event.my.absent"
									: event.isCheckOpen() ? "event.my.notChecked" : null;
							if (seminarKey != null) {
					%>
					<p class="mb-2"><b><fmt:message key="event.myStatus" /></b> : <fmt:message key="<%=seminarKey%>" /></p>
					<%
							}
							if (Attendance.ABSENT.equals(myStatus)) {
								String reportLink = (myReport != null)
										? "./absenceReport.jsp?id=" + myReport.getReportId()
										: "./absenceForm.jsp?eventId=" + event.getEventId();
								String reportKey = (myReport != null) ? "my.reportView" : "my.reportWrite";
					%>
					<a href="<%=reportLink%>" class="btn btn-outline-primary"><fmt:message key="<%=reportKey%>" /></a>
					<%
							}
						}
					} else if (myStatus != null && !Attendance.DECLINED.equals(myStatus)) {
						String myStatusKey = Attendance.PRESENT.equals(myStatus) ? "event.my.present"
								: Attendance.ABSENT.equals(myStatus) ? "event.my.absent"
								: event.isPast() ? "event.my.appliedPast" : "event.my.applied";
					%>
					<p class="mb-2"><b><fmt:message key="event.myStatus" /></b> : <fmt:message key="<%=myStatusKey%>" /></p>
					<%
						if (Attendance.APPLIED.equals(myStatus) && !event.isPast()) {
					%>
					<div class="d-flex gap-2">
						<form action="./processDecline.jsp" method="post">
							<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
							<button type="submit" class="btn btn-outline-secondary"><fmt:message key="event.toDecline" /></button>
						</form>
						<form action="./processCancel.jsp" method="post"
							onsubmit="return confirm('<fmt:message key="event.cancel.confirm" />')">
							<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
							<button type="submit" class="btn btn-outline-danger"><fmt:message key="event.cancel" /></button>
						</form>
					</div>
					<%
						}
					} else if (Attendance.DECLINED.equals(myStatus)) {
					%>
					<p class="mb-2"><b><fmt:message key="event.myStatus" /></b> : <fmt:message key="event.my.declined" /></p>
					<%
						if (!event.isPast()) {
					%>
					<div class="d-flex gap-2">
						<form action="./processApply.jsp" method="post">
							<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
							<button type="submit" class="btn btn-primary" <%=event.isFull() ? "disabled" : ""%>><fmt:message key="event.toApply" /></button>
						</form>
						<form action="./processCancel.jsp" method="post">
							<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
							<button type="submit" class="btn btn-outline-secondary"><fmt:message key="event.clearResponse" /></button>
						</form>
					</div>
					<%
						}
					} else if (event.isPast()) {
					%>
					<button type="button" class="btn btn-secondary" disabled><fmt:message key="event.closed" /></button>
					<%
					} else if (loginId == null) {
					%>
					<a href="./login.jsp?msg=needLogin" class="btn btn-primary"><fmt:message key="event.loginToApply" /></a>
					<%
					} else {
					%>
					<p class="text-secondary small mb-2"><fmt:message key="event.respondHint" /></p>
					<div class="d-flex gap-2">
						<%
						if (event.isFull()) {
						%>
						<button type="button" class="btn btn-secondary" disabled><fmt:message key="event.full" /></button>
						<%
						} else {
						%>
						<form action="./processApply.jsp" method="post">
							<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
							<button type="submit" class="btn btn-primary"><fmt:message key="event.apply" /></button>
						</form>
						<%
						}
						%>
						<form action="./processDecline.jsp" method="post">
							<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
							<button type="submit" class="btn btn-outline-secondary"><fmt:message key="event.decline" /></button>
						</form>
					</div>
					<%
					}
					%>
				</div>
				<p>
					<a href="./events.jsp" class="btn btn-secondary"><fmt:message key="event.backToList" /> &raquo;</a>
				</p>
				<%
				// 관리자에게만 출석 체크·수정·삭제 버튼을 보여 준다 (처리 화면에서도 adminCheck.jsp 로 다시 확인한다)
				if ("ADMIN".equals(session.getAttribute("loginRole"))) {
				%>
				<div class="d-flex gap-2 border-top pt-3">
					<a href="./checkAttendance.jsp?id=<%=event.getEventId()%>" class="btn btn-outline-success"><fmt:message key="event.check" /></a>
					<a href="./eventForm.jsp?id=<%=event.getEventId()%>" class="btn btn-outline-primary"><fmt:message key="event.edit" /></a>
					<form action="./processDeleteEvent.jsp" method="post"
						onsubmit="return confirm('<fmt:message key="event.delete.confirm"><fmt:param value="<%=applied%>" /></fmt:message>')">
						<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
						<button type="submit" class="btn btn-outline-danger"><fmt:message key="event.delete" /></button>
					</form>
				</div>
				<%
				}
				%>
			</div>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
