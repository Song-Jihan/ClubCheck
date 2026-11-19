<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error500.jsp"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.IOException"%>
<%@ page import="java.sql.SQLException"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.oreilly.servlet.MultipartRequest"%>
<%@ page import="com.oreilly.servlet.multipart.FileRenamePolicy"%>
<%@ page import="dto.Event"%>
<%@ page import="util.EventValidator"%>
<%@ page import="util.PosterUtil"%>
<%@ include file="adminCheck.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<jsp:useBean id="event" class="dto.Event" scope="page" />
<%
	// 행사 등록과 수정을 함께 처리한다 (eventId 가 0 이면 등록, 0 보다 크면 수정)
	if (!"POST".equals(request.getMethod())) {
		response.sendRedirect("events.jsp");
		return;
	}

	// 포스터를 최종적으로 둘 폴더 (웹에서 ./resources/images/파일명 으로 보인다)
	String posterDir = application.getRealPath("/resources/images");
	if (posterDir == null) {
		throw new IllegalStateException("포스터 폴더의 실제 경로를 알 수 없습니다. 압축하지 않은 폴더 형태로 배포해야 합니다.");
	}

	// 1) cos 로 multipart 요청을 읽는다. 파일은 웹 폴더 밖의 임시 폴더에 먼저 저장된다.
	//    파일 이름 정책: 사용자가 보낸 파일 이름(예: hack.jsp, ../../a.png)을 쓰지 않고 임시 이름으로 저장한다
	FileRenamePolicy tempNamePolicy = new FileRenamePolicy() {
		public File rename(File file) {
			return new File(file.getParentFile(), PosterUtil.newTempName());
		}
	};
	MultipartRequest multi = null;
	try {
		multi = new MultipartRequest(request, PosterUtil.getTempDir(), PosterUtil.MAX_REQUEST_SIZE, "UTF-8",
				tempNamePolicy);
	} catch (IOException e) {
		// 요청 전체가 너무 크면(20MB 초과) 입력값을 읽을 수 없으므로 목록으로 돌려보낸다
		response.sendRedirect("events.jsp?msg=uploadFail");
		return;
	}
	File uploaded = multi.getFile("poster");

	int eventId = 0;
	try {
		eventId = Integer.parseInt(multi.getParameter("eventId"));
	} catch (NumberFormatException e) {
		eventId = 0;
	}

	// 수정이면 원래 행사를 불러온다 (그사이 삭제됐을 수도 있다)
	Event original = null;
	if (eventId > 0) {
		original = eventDAO.getEventById(eventId);
		if (original == null) {
			PosterUtil.deleteQuietly(uploaded);
			response.sendRedirect("events.jsp?msg=notFound");
			return;
		}
	}

	String title = multi.getParameter("title");
	String description = multi.getParameter("description");
	String location = multi.getParameter("location");
	String eventDate = multi.getParameter("eventDate");
	String capacity = multi.getParameter("capacity");
	title = (title == null) ? "" : title.trim();
	description = (description == null) ? "" : description.trim();
	location = (location == null) ? "" : location.trim();
	capacity = (capacity == null) ? "" : capacity.trim();

	// 행사 종류: 등록할 때만 고를 수 있고, 수정할 때는 원래 종류를 그대로 쓴다
	String eventType = (original != null) ? original.getEventType() : multi.getParameter("eventType");
	boolean typeValid = Event.SEMINAR.equals(eventType) || Event.ACTIVITY.equals(eventType);
	if (!typeValid) {
		eventType = Event.ACTIVITY;
	}
	// 정기세미나는 신청과 정원이 없다. 정원 칸은 화면에서 숨기고, DB 에는 최대값을 넣어 둔다
	if (Event.SEMINAR.equals(eventType)) {
		capacity = String.valueOf(EventValidator.CAPACITY_MAX);
	}
%>
<%-- 액션 태그로 자바빈(Event)에 문자열 값을 채운다 --%>
<jsp:setProperty name="event" property="title" value="<%=title%>" />
<jsp:setProperty name="event" property="description" value="<%=description%>" />
<jsp:setProperty name="event" property="location" value="<%=location%>" />
<%
	event.setEventId(eventId);
	event.setEventType(eventType);

	// 2) 입력값 검사
	ArrayList<String> errors = EventValidator.validate(title, description, eventDate, location, capacity, original);
	if (!typeValid) {
		errors.add(0, "err.event.type");
	}

	// 3) 포스터 검사: 크기와 파일 내용(확장자가 아니라 실제 이미지인지)
	String imageType = null;
	if (uploaded != null) {
		if (uploaded.length() > PosterUtil.MAX_FILE_SIZE) {
			errors.add("err.poster.size");
		} else {
			imageType = PosterUtil.detectImageType(uploaded);
			if (imageType == null) {
				errors.add("err.poster.type");
			}
		}
	}

	if (!errors.isEmpty()) {
		// 실패: 임시 파일을 지우고, 입력값과 오류를 담아 입력 화면으로 forward 한다
		PosterUtil.deleteQuietly(uploaded);
		event.setPosterFilename(original != null ? original.getPosterFilename() : null);
		event.setAppliedCount(original != null ? original.getAppliedCount() : 0);
		request.setAttribute("formEvent", event);
		request.setAttribute("formDate", eventDate);
		request.setAttribute("formCapacity", capacity);
		request.setAttribute("errors", errors);
%>
<jsp:forward page="eventForm.jsp" />
<%
	}

	// 4) 포스터 정하기: 새 파일 > '현재 포스터 삭제' 체크 > 기존 포스터 유지
	String oldPoster = (original != null) ? original.getPosterFilename() : null;
	String newPoster = oldPoster;
	if (imageType != null) {
		newPoster = PosterUtil.store(uploaded, imageType, posterDir);
	} else if ("on".equals(multi.getParameter("removePoster"))) {
		newPoster = null;
	}

	event.setEventDate(EventValidator.parseDate(eventDate));
	event.setCapacity(Integer.parseInt(capacity));
	event.setPosterFilename(newPoster);

	// 5) DB 저장. 실패하면 방금 옮긴 새 포스터를 지운다
	try {
		if (original == null) {
			eventId = eventDAO.insert(event);
		} else {
			eventDAO.update(event);
		}
	} catch (SQLException e) {
		if (imageType != null) {
			PosterUtil.deleteUploaded(posterDir, newPoster);
		}
		throw e;
	}

	// 6) 포스터가 바뀌었으면 예전 업로드 파일을 지운다 (시드 이미지는 지우지 않는다)
	if (oldPoster != null && !oldPoster.equals(newPoster)) {
		PosterUtil.deleteUploaded(posterDir, oldPoster);
	}

	response.sendRedirect("event.jsp?id=" + eventId + "&msg=" + (original == null ? "eventAdded" : "eventUpdated"));
%>
