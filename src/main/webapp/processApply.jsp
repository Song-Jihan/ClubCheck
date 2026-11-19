<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error500.jsp"%>
<%@ page import="dao.AttendanceDAO"%>
<%@ include file="loginCheck.jsp"%>
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<%
	// 참석 신청 (로그인한 회원, POST 전용)
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

	AttendanceDAO.ApplyResult result = attendanceDAO.apply(eventId, (String) session.getAttribute("loginId"));

	// 결과별 안내 문구 코드 (message.jsp)
	String msg;
	switch (result) {
	case OK:
		msg = "applied";
		break;
	case FULL:
		msg = "applyFull";
		break;
	case CLOSED:
		msg = "applyClosed";
		break;
	case ALREADY:
		msg = "applyAlready";
		break;
	default:
		response.sendRedirect("events.jsp?msg=notFound");
		return;
	}
	response.sendRedirect("event.jsp?id=" + eventId + "&msg=" + msg);
%>
