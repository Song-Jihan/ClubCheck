<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error500.jsp"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="dto.Event"%>
<%@ page import="dto.Attendance"%>
<%@ include file="adminCheck.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<%
	// 출석 체크 저장 (관리자, POST 전용)
	if (!"POST".equals(request.getMethod())) {
		response.sendRedirect("events.jsp");
		return;
	}

	Event event = null;
	try {
		event = eventDAO.getEventById(Integer.parseInt(request.getParameter("eventId")));
	} catch (NumberFormatException e) {
		event = null;
	}
	if (event == null) {
		response.sendRedirect("events.jsp?msg=notFound");
		return;
	}
	// 화면에서 버튼을 막아도 요청은 직접 보낼 수 있으므로 서버에서 다시 확인한다
	if (!event.isCheckOpen()) {
		response.sendRedirect("checkAttendance.jsp?id=" + event.getEventId() + "&msg=checkNotOpen");
		return;
	}

	// 폼에서 회원별 상태를 모은다: memberId 여러 개 + status_아이디
	LinkedHashMap<String, String> statusByMember = new LinkedHashMap<String, String>();
	String[] memberIds = request.getParameterValues("memberId");
	if (memberIds != null) {
		for (String memberId : memberIds) {
			String status = request.getParameter("status_" + memberId);
			if (Attendance.isValidStatus(status)) {
				statusByMember.put(memberId, status);
			}
		}
	}

	attendanceDAO.updateStatuses(event.getEventId(), statusByMember);
	response.sendRedirect("checkAttendance.jsp?id=" + event.getEventId() + "&msg=attendanceSaved");
%>
