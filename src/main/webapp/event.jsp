<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.Event"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
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
				<p>
					<a href="./events.jsp" class="btn btn-secondary">행사 목록 &raquo;</a>
				</p>
			</div>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
