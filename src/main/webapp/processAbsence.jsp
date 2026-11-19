<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error500.jsp"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.IOException"%>
<%@ page import="java.sql.SQLException"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.oreilly.servlet.MultipartRequest"%>
<%@ page import="com.oreilly.servlet.multipart.FileRenamePolicy"%>
<%@ page import="dto.Event"%>
<%@ page import="dto.Attendance"%>
<%@ page import="dto.AbsenceReport"%>
<%@ page import="util.AbsenceValidator"%>
<%@ page import="util.PosterUtil"%>
<%@ include file="loginCheck.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<jsp:useBean id="absenceReportDAO" class="dao.AbsenceReportDAO" scope="page" />
<%
	// 결석사유서 저장 (본인, POST 전용). 처음이면 새로 넣고, 이미 냈으면 고친다
	if (!"POST".equals(request.getMethod())) {
		response.sendRedirect("myPage.jsp");
		return;
	}
	String loginId = (String) session.getAttribute("loginId");

	// 증빙자료는 웹에서 주소로 바로 열 수 없는 WEB-INF 아래에 둔다 (evidence.jsp 가 권한을 확인하고 보여 준다)
	String evidenceDir = application.getRealPath("/WEB-INF/evidence");
	if (evidenceDir == null) {
		throw new IllegalStateException("증빙자료 폴더의 실제 경로를 알 수 없습니다. 압축하지 않은 폴더 형태로 배포해야 합니다.");
	}
	PosterUtil.ensureDir(evidenceDir);

	// 1) cos 로 multipart 요청을 읽는다. 파일은 사용자가 보낸 이름 대신 임시 이름으로 임시 폴더에 저장한다
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
		response.sendRedirect("myPage.jsp?msg=uploadFail");
		return;
	}
	File uploaded = multi.getFile("evidence");

	// 2) 대상 확인: 이미 낸 사유서는 언제든 고칠 수 있고, 새로 내는 것은 정기세미나 결석만 가능하다
	Event event = null;
	try {
		event = eventDAO.getEventById(Integer.parseInt(multi.getParameter("eventId")));
	} catch (NumberFormatException e) {
		event = null;
	}
	if (event == null) {
		PosterUtil.deleteQuietly(uploaded);
		response.sendRedirect("myPage.jsp?msg=notFound");
		return;
	}
	AbsenceReport saved = absenceReportDAO.findByEventAndMember(event.getEventId(), loginId);
	if (saved == null && !(event.isSeminar()
			&& Attendance.ABSENT.equals(attendanceDAO.getStatus(event.getEventId(), loginId)))) {
		PosterUtil.deleteQuietly(uploaded);
		response.sendRedirect("myPage.jsp?msg=reportNotAllowed");
		return;
	}

	// 3) 입력값 검사
	String title = multi.getParameter("title");
	String reason = multi.getParameter("reason");
	title = (title == null) ? "" : title.trim();
	reason = (reason == null) ? "" : reason.trim();
	ArrayList<String> errors = AbsenceValidator.validate(title, reason);

	String imageType = null;
	if (uploaded != null) {
		if (uploaded.length() > PosterUtil.MAX_FILE_SIZE) {
			errors.add("err.evidence.size");
		} else {
			imageType = PosterUtil.detectImageType(uploaded);
			if (imageType == null) {
				errors.add("err.evidence.type");
			}
		}
	}

	AbsenceReport report = new AbsenceReport();
	report.setEventId(event.getEventId());
	report.setMemberId(loginId);
	report.setTitle(title);
	report.setReason(reason);

	if (!errors.isEmpty()) {
		// 실패: 임시 파일을 지우고, 입력값과 오류를 담아 입력 화면으로 forward 한다
		PosterUtil.deleteQuietly(uploaded);
		request.setAttribute("formReport", report);
		request.setAttribute("errors", errors);
%>
<jsp:forward page="absenceForm.jsp" />
<%
	}

	// 4) 증빙자료 정하기: 새 파일 > '현재 증빙자료 삭제' 체크 > 기존 파일 유지
	String oldEvidence = (saved != null) ? saved.getEvidenceFilename() : null;
	String newEvidence = oldEvidence;
	if (imageType != null) {
		newEvidence = PosterUtil.store(uploaded, imageType, evidenceDir);
	} else if ("on".equals(multi.getParameter("removeEvidence"))) {
		newEvidence = null;
	}
	report.setEvidenceFilename(newEvidence);

	// 5) DB 저장. 실패하면 방금 옮긴 새 파일을 지운다
	int reportId;
	try {
		if (saved == null) {
			reportId = absenceReportDAO.insert(report);
		} else {
			reportId = saved.getReportId();
			report.setReportId(reportId);
			absenceReportDAO.update(report);
		}
	} catch (SQLException e) {
		if (imageType != null) {
			PosterUtil.deleteUploaded(evidenceDir, newEvidence);
		}
		throw e;
	}

	// 6) 바뀐 경우에만 예전 파일을 지운다 (DB 저장이 성공한 뒤)
	if (oldEvidence != null && !oldEvidence.equals(newEvidence)) {
		PosterUtil.deleteUploaded(evidenceDir, oldEvidence);
	}
	response.sendRedirect("absenceReport.jsp?id=" + reportId + "&msg=reportSaved");
%>
