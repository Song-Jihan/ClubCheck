<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error500.jsp"%>
<%@ include file="loginCheck.jsp"%>
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<%
	// 참석 신청 취소 (본인 것만, 행사 시작 전, 출석 처리 전)
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

	// 회원 아이디는 폼이 아니라 세션에서 꺼낸다 (다른 사람의 신청을 취소할 수 없게)
	boolean cancelled = attendanceDAO.cancel(eventId, (String) session.getAttribute("loginId"));
	response.sendRedirect("event.jsp?id=" + eventId + "&msg=" + (cancelled ? "cancelled" : "cancelFail"));
%>
