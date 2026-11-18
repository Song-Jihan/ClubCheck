<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.Event"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ page import="dto.Attendance"%>
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
		response.sendRedirect("events.jsp");
		return;
	}

	String poster = event.getPosterFilename();
	if (poster == null || poster.isEmpty()) {
		poster = "poster_default.png";
	}

	// 로그인한 회원이면 이 행사에 대한 내 신청 상태를 확인한다 (신청 안 했으면 null)
	String loginId = (String) session.getAttribute("loginId");
	String myStatus = (loginId != null) ? attendanceDAO.getStatus(event.getEventId(), loginId) : null;
%>
<!DOCTYPE html>
<html>
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
				<h1 class="display-6 fw-bold">행사 정보</h1>
				<p class="col-md-8 fs-5 mb-0">Event Info</p>
			</div>
		</div>

		<div class="row align-items-md-stretch">
			<div class="col-md-5 mb-4">
				<img src="./resources/images/<%=HtmlUtil.escape(poster)%>"
					alt="행사 포스터" class="rounded" style="width: 80%;">
			</div>
			<div class="col-md-6">
				<h3>
					<b><%=HtmlUtil.escape(event.getTitle())%></b>
				</h3>
				<p>
					<%
					if (event.isPast()) {
					%>
					<span class="badge text-bg-secondary">종료</span>
					<%
					} else if (event.isFull()) {
					%>
					<span class="badge text-bg-danger">정원 마감</span>
					<%
					} else {
					%>
					<span class="badge text-bg-success">모집 중</span>
					<%
					}
					%>
				</p>
				<p><%=HtmlUtil.escapeWithBreaks(event.getDescription())%></p>
				<p>
					<b>일시</b> :
					<%=DateUtil.format(event.getEventDate())%>
				</p>
				<p>
					<b>장소</b> :
					<%=HtmlUtil.escape(event.getLocation())%>
				</p>
				<p>
					<b>신청 인원</b> :
					<%=event.getAppliedCount()%>
					/
					<%=event.getCapacity()%>명
				</p>

				<%-- 참석 신청 영역: 로그인 여부, 내 신청 상태, 행사 시작 여부, 정원에 따라 다르게 보여 준다 --%>
				<div class="mb-3">
					<%
					if (myStatus != null) {
						String myLabel = Attendance.PRESENT.equals(myStatus) ? "출석"
								: Attendance.ABSENT.equals(myStatus) ? "결석"
								: event.isPast() ? "신청함 (출석 미처리)" : "신청 완료";
					%>
					<p class="mb-2"><b>내 신청 상태</b> : <%=myLabel%></p>
					<%
						if (Attendance.APPLIED.equals(myStatus) && !event.isPast()) {
					%>
					<form action="./processCancel.jsp" method="post"
						onsubmit="return confirm('참석 신청을 취소할까요?')">
						<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
						<button type="submit" class="btn btn-outline-danger">신청 취소</button>
					</form>
					<%
						}
					} else if (event.isPast()) {
					%>
					<button type="button" class="btn btn-secondary" disabled>신청 마감</button>
					<%
					} else if (event.isFull()) {
					%>
					<button type="button" class="btn btn-secondary" disabled>정원 마감</button>
					<%
					} else if (loginId == null) {
					%>
					<a href="./login.jsp?msg=needLogin" class="btn btn-primary">로그인하고 신청하기</a>
					<%
					} else {
					%>
					<form action="./processApply.jsp" method="post">
						<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
						<button type="submit" class="btn btn-primary">참석 신청</button>
					</form>
					<%
					}
					%>
				</div>
				<p>
					<a href="./events.jsp" class="btn btn-secondary">행사 목록 &raquo;</a>
				</p>
				<%
				// 관리자에게만 수정·삭제 버튼을 보여 준다 (처리 화면에서도 adminCheck.jsp 로 다시 확인한다)
				if ("ADMIN".equals(session.getAttribute("loginRole"))) {
				%>
				<div class="d-flex gap-2 border-top pt-3">
					<a href="./checkAttendance.jsp?id=<%=event.getEventId()%>" class="btn btn-outline-success">출석 체크</a>
					<a href="./eventForm.jsp?id=<%=event.getEventId()%>" class="btn btn-outline-primary">수정</a>
					<form action="./processDeleteEvent.jsp" method="post"
						onsubmit="return confirm('이 행사를 삭제할까요?\n참석 신청 <%=event.getAppliedCount()%>건도 함께 삭제되며 되돌릴 수 없습니다.')">
						<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
						<button type="submit" class="btn btn-outline-danger">삭제</button>
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
