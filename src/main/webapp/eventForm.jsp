<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="dto.Event"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ page import="util.EventValidator"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%@ include file="adminCheck.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<%
	// 행사 등록과 수정을 함께 처리하는 화면
	//  - eventForm.jsp        : 새 행사 등록
	//  - eventForm.jsp?id=3   : 3번 행사 수정
	//  - processEvent.jsp 에서 검사에 실패해 forward 로 돌아온 경우: request 속성에 입력값과 오류가 들어 있다
	Event formEvent = (Event) request.getAttribute("formEvent");
	String dateValue = (String) request.getAttribute("formDate");
	String capacityValue = (String) request.getAttribute("formCapacity");
	@SuppressWarnings("unchecked")
	ArrayList<String> errors = (ArrayList<String>) request.getAttribute("errors");

	if (formEvent == null) {
		String idParam = request.getParameter("id");
		if (idParam == null) {
			formEvent = new Event();
			dateValue = "";
			capacityValue = "";
		} else {
			try {
				formEvent = eventDAO.getEventById(Integer.parseInt(idParam));
			} catch (NumberFormatException e) {
				formEvent = null;
			}
			if (formEvent == null) {
				response.sendRedirect("events.jsp?msg=notFound");
				return;
			}
			dateValue = DateUtil.toInputValue(formEvent.getEventDate());
			capacityValue = String.valueOf(formEvent.getCapacity());
		}
	}

	boolean isEdit = formEvent.getEventId() > 0;
	String pageTitle = msg(pageContext, isEdit ? "form.editTitle" : "form.addTitle");
	String leadKey = isEdit ? "form.editLead" : "form.addLead";
	int appliedCount = formEvent.getAppliedCount();
	// 새 행사는 지금 이후만 고를 수 있게 한다. 수정할 때는 지난 행사의 오타 수정도 허용해야 하므로 제한하지 않는다
	String minDate = isEdit ? "" : DateUtil.toInputValue(new java.sql.Timestamp(System.currentTimeMillis()));
	// 수정할 때 정원은 현재 신청 인원보다 작을 수 없다
	int minCapacity = Math.max(EventValidator.CAPACITY_MIN, formEvent.getAppliedCount());
%>

<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<%@ include file="jsMessages.jsp"%>
<script type="text/javascript" src="./resources/js/validation.js"></script>
<title><%=pageTitle%> - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><%=pageTitle%></h1>
				<p class="col-md-8 fs-5 mb-0"><fmt:message key="<%=leadKey%>" /></p>
			</div>
		</div>

		<div class="row justify-content-center">
			<div class="col-md-8">
				<%@ include file="errorList.jsp"%>

				<%-- 파일을 보내려면 method="post" 와 enctype="multipart/form-data" 가 필요하다.
				     action 에 ?id= 같은 쿼리 문자열을 붙이지 않고 행사 번호는 hidden 칸으로 보낸다. --%>
				<form name="eventForm" action="./processEvent.jsp" method="post"
					enctype="multipart/form-data" onsubmit="return checkEvent()">
					<input type="hidden" name="eventId" value="<%=formEvent.getEventId()%>">

					<div class="mb-3">
						<label for="title" class="form-label"><fmt:message key="form.title" /></label>
						<input type="text" id="title" name="title" class="form-control"
							maxlength="<%=EventValidator.TITLE_MAX%>"
							value="<%=HtmlUtil.escape(formEvent.getTitle())%>">
					</div>
					<div class="row">
						<div class="col-md-6 mb-3">
							<label for="eventDate" class="form-label"><fmt:message key="form.date" /></label>
							<input type="datetime-local" id="eventDate" name="eventDate"
								class="form-control" value="<%=HtmlUtil.escape(dateValue)%>"
								<%=minDate.isEmpty() ? "" : "min=\"" + minDate + "\""%>>
						</div>
						<div class="col-md-6 mb-3">
							<label for="capacity" class="form-label"><fmt:message key="form.capacity" /></label>
							<input type="number" id="capacity" name="capacity" class="form-control"
								min="<%=minCapacity%>" max="<%=EventValidator.CAPACITY_MAX%>"
								data-applied="<%=formEvent.getAppliedCount()%>"
								value="<%=HtmlUtil.escape(capacityValue)%>">
							<%
							if (isEdit) {
							%>
							<div class="form-text"><fmt:message key="form.capacityHelp"><fmt:param value="<%=appliedCount%>" /></fmt:message></div>
							<%
							}
							%>
						</div>
					</div>
					<div class="mb-3">
						<label for="location" class="form-label"><fmt:message key="form.location" /></label>
						<input type="text" id="location" name="location" class="form-control"
							maxlength="<%=EventValidator.LOCATION_MAX%>"
							value="<%=HtmlUtil.escape(formEvent.getLocation())%>">
					</div>
					<div class="mb-3">
						<label for="description" class="form-label"><fmt:message key="form.description" /></label>
						<textarea id="description" name="description" class="form-control" rows="4"
							maxlength="<%=EventValidator.DESCRIPTION_MAX%>"><%=HtmlUtil.escape(formEvent.getDescription())%></textarea>
					</div>
					<div class="mb-4">
						<label for="poster" class="form-label"><fmt:message key="form.poster" /></label>
						<%
						String currentPoster = formEvent.getPosterFilename();
						if (currentPoster != null && !currentPoster.isEmpty()) {
						%>
						<div class="d-flex align-items-center gap-3 mb-2">
							<img src="./resources/images/<%=HtmlUtil.escape(currentPoster)%>"
								alt="<fmt:message key="form.currentPoster" />" class="rounded border" style="height: 120px;">
							<div class="form-check">
								<input type="checkbox" id="removePoster" name="removePoster" value="on"
									class="form-check-input">
								<label for="removePoster" class="form-check-label"><fmt:message key="form.removePoster" /></label>
							</div>
						</div>
						<%
						}
						%>
						<input type="file" id="poster" name="poster" class="form-control"
							accept=".jpg,.jpeg,.png,.gif,.webp,image/jpeg,image/png,image/gif,image/webp">
						<div class="form-text"><fmt:message key="form.posterHelp" /><%=isEdit ? msg(pageContext, "form.posterReplace") : ""%></div>
					</div>

					<div class="d-flex gap-2">
						<button type="submit" class="btn btn-primary"><%=msg(pageContext, isEdit ? "form.submitEdit" : "form.submitAdd")%></button>
						<a href="<%=isEdit ? "./event.jsp?id=" + formEvent.getEventId() : "./events.jsp"%>"
							class="btn btn-outline-secondary"><fmt:message key="form.cancel" /></a>
					</div>
				</form>
			</div>
		</div>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
