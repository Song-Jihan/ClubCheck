<%@ page pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.FileInputStream"%>
<%@ page import="java.io.InputStream"%>
<%@ page import="java.io.OutputStream"%>
<%@ page import="dto.AbsenceReport"%>
<jsp:useBean id="absenceReportDAO" class="dao.AbsenceReportDAO" scope="page" />
<%
	// 결석사유서의 증빙자료 이미지를 보내 준다.
	// 파일은 WEB-INF/evidence 에 있어 주소로 바로 열 수 없고, 이 화면이 본인 또는 관리자인지 확인한 뒤에만 내보낸다.
	String loginId = (String) session.getAttribute("loginId");
	boolean isAdmin = "ADMIN".equals(session.getAttribute("loginRole"));

	AbsenceReport report = null;
	if (loginId != null) {
		try {
			report = absenceReportDAO.findById(Integer.parseInt(request.getParameter("id")));
		} catch (NumberFormatException e) {
			report = null;
		}
	}
	String filename = (report != null) ? report.getEvidenceFilename() : null;
	boolean allowed = report != null && (isAdmin || report.getMemberId().equals(loginId));
	// 파일 이름은 저장할 때 만든 형식(upload_날짜_임의값.확장자)인지 다시 확인한다 (../ 같은 경로 차단)
	if (!allowed || filename == null || !filename.matches("^upload_[0-9]{14}_[0-9a-f]{8}\\.(jpg|png|gif|webp)$")) {
		response.sendError(HttpServletResponse.SC_NOT_FOUND);
		return;
	}
	File file = new File(application.getRealPath("/WEB-INF/evidence"), filename);
	if (!file.isFile()) {
		response.sendError(HttpServletResponse.SC_NOT_FOUND);
		return;
	}

	String ext = filename.substring(filename.lastIndexOf('.') + 1);
	response.setContentType("jpg".equals(ext) ? "image/jpeg" : "image/" + ext);
	response.setContentLengthLong(file.length());
	response.setHeader("Cache-Control", "private, no-store");

	// JSP 는 원래 글자(out)로 출력한다. 이미지는 바이트이므로 out 버퍼를 비우고 바이트 스트림으로 직접 보낸다
	out.clear();
	out = pageContext.pushBody();
	try (InputStream in = new FileInputStream(file); OutputStream os = response.getOutputStream()) {
		byte[] buffer = new byte[8192];
		int read;
		while ((read = in.read(buffer)) != -1) {
			os.write(buffer, 0, read);
		}
	}
%>
