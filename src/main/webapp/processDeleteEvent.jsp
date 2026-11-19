<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error500.jsp"%>
<%@ page import="dto.Event"%>
<%@ page import="util.PosterUtil"%>
<%@ include file="adminCheck.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<%
	// 삭제는 주소만 눌러서 실행되지 않도록 POST 로만 받는다
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

	// 행사를 지우면 그 행사의 참석 신청도 함께 지워진다 (ON DELETE CASCADE)
	if (eventDAO.delete(event.getEventId())) {
		PosterUtil.deleteUploaded(application.getRealPath("/resources/images"), event.getPosterFilename());
	}
	response.sendRedirect("events.jsp?msg=eventDeleted");
%>
