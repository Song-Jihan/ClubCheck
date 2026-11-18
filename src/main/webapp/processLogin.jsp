<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.Member"%>
<jsp:useBean id="memberDAO" class="dao.MemberDAO" scope="page" />
<%
	request.setCharacterEncoding("UTF-8");

	if (!"POST".equals(request.getMethod())) {
		response.sendRedirect("login.jsp");
		return;
	}

	String id = request.getParameter("id");
	String password = request.getParameter("password");
	if (id != null) {
		id = id.trim();
	}

	Member member = null;
	if (id != null && !id.isEmpty() && password != null && !password.isEmpty()) {
		member = memberDAO.login(id, password);
	}

	if (member == null) {
		// 아이디가 틀렸는지 비밀번호가 틀렸는지는 알려 주지 않는다 (아이디 존재 여부 노출 방지)
		request.setAttribute("errorMsg", "아이디 또는 비밀번호가 올바르지 않습니다.");
%>
<jsp:forward page="login.jsp" />
<%
	}

	// 로그인 성공: 기존 세션을 버리고 새 세션을 만든다 (로그인 전 세션 ID 를 그대로 쓰지 않도록)
	session.invalidate();
	HttpSession loginSession = request.getSession(true);
	loginSession.setAttribute("loginId", member.getId());
	loginSession.setAttribute("loginName", member.getName());
	loginSession.setAttribute("loginRole", member.getRole());

	// '아이디 저장'을 체크했으면 30일 동안 쿠키에 아이디를 저장하고, 아니면 쿠키를 지운다
	Cookie savedIdCookie = new Cookie("savedId", member.getId());
	savedIdCookie.setPath(request.getContextPath() + "/");
	savedIdCookie.setHttpOnly(true);
	if ("on".equals(request.getParameter("rememberId"))) {
		savedIdCookie.setMaxAge(60 * 60 * 24 * 30);
	} else {
		savedIdCookie.setMaxAge(0);
	}
	response.addCookie(savedIdCookie);

	response.sendRedirect("events.jsp?msg=loginOk");
%>
