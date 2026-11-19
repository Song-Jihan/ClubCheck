<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error500.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.sql.SQLIntegrityConstraintViolationException"%>
<%@ page import="dto.Member"%>
<%@ page import="util.MemberValidator"%>
<jsp:useBean id="memberDAO" class="dao.MemberDAO" scope="page" />
<%
	request.setCharacterEncoding("UTF-8");

	// 주소창으로 직접 들어온 경우(GET)는 처리하지 않는다
	if (!"POST".equals(request.getMethod())) {
		response.sendRedirect("join.jsp");
		return;
	}

	String id = request.getParameter("id");
	String password = request.getParameter("password");
	String passwordConfirm = request.getParameter("passwordConfirm");
	String name = request.getParameter("name");
	String studentNo = request.getParameter("studentNo");
	if (name != null) {
		name = name.trim();
	}
	if (studentNo != null) {
		studentNo = studentNo.trim();
	}

	// 1) 형식 검사
	ArrayList<String> errors = MemberValidator.validateJoin(id, password, passwordConfirm, name, studentNo);

	// 2) 중복 검사 (형식이 맞을 때만 DB 를 조회한다)
	if (errors.isEmpty()) {
		if (memberDAO.existsById(id)) {
			errors.add("err.join.idTaken");
		}
		if (memberDAO.existsByStudentNo(studentNo)) {
			errors.add("err.join.studentNoTaken");
		}
	}

	// 3) 저장. 두 사람이 동시에 같은 아이디로 가입하면 DB 의 PRIMARY KEY / UNIQUE 제약이 막아 준다
	if (errors.isEmpty()) {
		Member member = new Member();
		member.setId(id);
		member.setPassword(password);
		member.setName(name);
		member.setStudentNo(studentNo);
		try {
			memberDAO.insert(member);
		} catch (SQLIntegrityConstraintViolationException e) {
			errors.add("err.join.duplicate");
		}
	}

	if (!errors.isEmpty()) {
		// 오류 목록(메시지 키)을 request 에 담아 가입 화면으로 forward 한다 (입력했던 값도 그대로 전달된다)
		request.setAttribute("errors", errors);
%>
<jsp:forward page="join.jsp" />
<%
	}

	// 가입 성공: 로그인 화면으로 보내면서 아이디를 미리 채워 준다 (아이디는 형식 검사를 통과한 값)
	response.sendRedirect("login.jsp?msg=joinOk&id=" + id);
%>
