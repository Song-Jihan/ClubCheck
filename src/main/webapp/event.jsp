<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.Event"%>
<%@ page import="dto.Attendance"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
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
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<title><%=HtmlUtil.escape(event.getTitle())%> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>
		<%@ include file="message.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
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
					<%
					if (event.isPast()) {
					%>
					<span class="badge text-bg-secondary"><fmt:message key="status.closed" /></span>
					<%
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
				<p>
					<b><fmt:message key="event.applied" /></b> :
					<fmt:message key="event.people"><fmt:param value="<%=applied%>" /><fmt:param value="<%=capacity%>" /></fmt:message>
				</p>

				<%-- 참석 신청 영역: 로그인 여부, 내 신청 상태, 행사 시작 여부, 정원에 따라 다르게 보여 준다 --%>
				<div class="mb-3">
					<%
					if (myStatus != null) {
						String myStatusKey = Attendance.PRESENT.equals(myStatus) ? "event.my.present"
								: Attendance.ABSENT.equals(myStatus) ? "event.my.absent"
								: event.isPast() ? "event.my.appliedPast" : "event.my.applied";
					%>
					<p class="mb-2"><b><fmt:message key="event.myStatus" /></b> : <fmt:message key="<%=myStatusKey%>" /></p>
					<%
						if (Attendance.APPLIED.equals(myStatus) && !event.isPast()) {
					%>
					<form action="./processCancel.jsp" method="post"
						onsubmit="return confirm('<fmt:message key="event.cancel.confirm" />')">
						<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
						<button type="submit" class="btn btn-outline-danger"><fmt:message key="event.cancel" /></button>
					</form>
					<%
						}
					} else if (event.isPast()) {
					%>
					<button type="button" class="btn btn-secondary" disabled><fmt:message key="event.closed" /></button>
					<%
					} else if (event.isFull()) {
					%>
					<button type="button" class="btn btn-secondary" disabled><fmt:message key="event.full" /></button>
					<%
					} else if (loginId == null) {
					%>
					<a href="./login.jsp?msg=needLogin" class="btn btn-primary"><fmt:message key="event.loginToApply" /></a>
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
