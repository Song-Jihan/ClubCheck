<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error500.jsp"%>
<%@ page import="dao.AttendanceDAO"%>
<%@ include file="loginCheck.jsp"%>
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<%
	// 대외활동 '미참여' 응답 (로그인한 회원, POST 전용). 참여 신청했던 회원은 미참여로 바뀐다
	if (!"POST".equals(request.getMethod())) {
		response.sendRedirect("events.jsp");
		return;
	}

	int eventId;
	try {
		eventId = Integer.parseInt(request.getParameter("eventId"));
	} catch (NumberFormatException e) {
		response.sendRedirect("events.jsp?msg=notFound");
		return;
	}

	// 회원 아이디는 폼이 아니라 세션에서 꺼낸다
	AttendanceDAO.DeclineResult result = attendanceDAO.decline(eventId, (String) session.getAttribute("loginId"));

	String msg;
	switch (result) {
	case OK:
		msg = "declined";
		break;
	case CLOSED:
		msg = "applyClosed";
		break;
	case ALREADY:
		msg = "declineAlready";
		break;
	case SEMINAR:
		msg = "seminarNoApply";
		break;
	default:
		response.sendRedirect("events.jsp?msg=notFound");
		return;
	}
	response.sendRedirect("event.jsp?id=" + eventId + "&msg=" + msg);
%>
