<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="dto.Event"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<%!
	// 선언문 태그: 행사 상태(종료 / 정원 마감 / 모집 중)에 맞는 배지를 만든다
	private String statusBadge(PageContext pc, Event event) {
		if (event.isPast()) {
			return "<span class=\"badge text-bg-secondary\">" + msg(pc, "status.closed") + "</span>";
		}
		if (event.isFull()) {
			return "<span class=\"badge text-bg-danger\">" + msg(pc, "status.full") + "</span>";
		}
		return "<span class=\"badge text-bg-success\">" + msg(pc, "status.open") + "</span>";
	}
%>
<%
	ArrayList<Event> upcomingEvents = eventDAO.getUpcomingEvents();
	ArrayList<Event> pastEvents = eventDAO.getPastEvents();
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<title><fmt:message key="events.pageTitle" /> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>
		<%@ include file="message.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><fmt:message key="events.pageTitle" /></h1>
				<p class="col-md-8 fs-5 mb-0"><fmt:message key="events.lead" /></p>
				<%
				if ("ADMIN".equals(session.getAttribute("loginRole"))) {
				%>
				<a href="./eventForm.jsp" class="btn btn-primary mt-3"><fmt:message key="events.add" /></a>
				<%
				}
				%>
			</div>
		</div>

		<%
		// 0번째는 예정된 행사, 1번째는 지난 행사를 같은 모양으로 출력한다
		for (int section = 0; section < 2; section++) {
			ArrayList<Event> events = (section == 0) ? upcomingEvents : pastEvents;
			String headingKey = (section == 0) ? "events.upcoming" : "events.past";
			int eventCount = events.size();
		%>
		<h4 class="mb-3">
			<fmt:message key="<%=headingKey%>" />
			<span class="text-secondary fs-6"><fmt:message key="events.count"><fmt:param value="<%=eventCount%>" /></fmt:message></span>
		</h4>
		<%
			if (events.isEmpty()) {
		%>
		<p class="text-secondary mb-5"><fmt:message key="events.empty" /></p>
		<%
			}
		%>
		<div class="row row-cols-1 row-cols-md-3 g-4 mb-5">
			<%
			for (int i = 0; i < events.size(); i++) {
				Event event = events.get(i);
				String poster = event.getPosterFilename();
				if (poster == null || poster.isEmpty()) {
					poster = "poster_default.png";
				}
				int applied = event.getAppliedCount();
				int capacity = event.getCapacity();
			%>
			<div class="col">
				<div class="card h-100">
					<img src="./resources/images/<%=HtmlUtil.escape(poster)%>"
						class="card-img-top" alt="<fmt:message key="poster.alt" />"
						style="height: 280px; object-fit: cover;">
					<div class="card-body">
						<p class="mb-2"><%=statusBadge(pageContext, event)%></p>
						<h5 class="card-title"><%=HtmlUtil.escape(event.getTitle())%></h5>
						<p class="card-text mb-1"><%=DateUtil.format(event.getEventDate(), lang)%></p>
						<p class="card-text mb-1"><%=HtmlUtil.escape(event.getLocation())%></p>
						<p class="card-text text-secondary">
							<fmt:message key="events.applied"><fmt:param value="<%=applied%>" /><fmt:param value="<%=capacity%>" /></fmt:message>
						</p>
					</div>
					<div class="card-footer bg-transparent border-0 pb-3">
						<a href="./event.jsp?id=<%=event.getEventId()%>"
							class="btn btn-outline-primary btn-sm"><fmt:message key="events.detail" /> &raquo;</a>
					</div>
				</div>
			</div>
			<%
			}
			%>
		</div>
		<%
		}
		%>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
