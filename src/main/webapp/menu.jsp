<%@ page pageEncoding="UTF-8"%>
<%-- 모든 화면 위쪽에 들어가는 공통 메뉴. include 디렉티브로 포함한다.
     include 된 화면과 변수 이름이 겹치지 않도록 menu 로 시작하는 이름을 쓴다. --%>
<%
String menuLoginId = (String) session.getAttribute("loginId");
String menuLoginName = (String) session.getAttribute("loginName");
boolean menuIsAdmin = "ADMIN".equals(session.getAttribute("loginRole"));
%>
<header
	class="d-flex flex-wrap align-items-center justify-content-between pb-3 mb-4 border-bottom">
	<a href="./events.jsp"
		class="d-flex align-items-center text-dark text-decoration-none">
		<span class="fs-4 fw-bold">ClubCheck</span>
	</a>
	<ul class="nav nav-pills align-items-center">
		<li class="nav-item"><a href="./events.jsp" class="nav-link">행사 목록</a></li>
		<%
		if (menuLoginId == null) {
		%>
		<li class="nav-item"><a href="./login.jsp" class="nav-link">로그인</a></li>
		<li class="nav-item"><a href="./join.jsp" class="nav-link">회원가입</a></li>
		<%
		} else {
		%>
		<li class="nav-item"><a href="./myPage.jsp" class="nav-link">
			<%=util.HtmlUtil.escape(menuLoginName)%>님
			<%
			if (menuIsAdmin) {
			%>
			<span class="badge text-bg-dark">관리자</span>
			<%
			}
			%>
		</a></li>
		<li class="nav-item"><a href="./logout.jsp" class="nav-link">로그아웃</a></li>
		<%
		}
		%>
	</ul>
</header>
