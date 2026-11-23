<%@ page pageEncoding="UTF-8"%>
<%-- 모든 화면 위쪽에 들어가는 공통 메뉴. include 디렉티브로 포함한다 (locale.jsp 다음).
     include 된 화면과 변수 이름이 겹치지 않도록 menu 로 시작하는 이름을 쓴다.
     에러 페이지처럼 주소가 다른 위치에서 보일 때도 링크가 깨지지 않도록 컨텍스트 경로로 시작하는 주소를 쓴다. --%>
<%
String menuCtx = request.getContextPath();
String menuLoginId = (String) session.getAttribute("loginId");
String menuLoginName = (String) session.getAttribute("loginName");
boolean menuIsAdmin = "ADMIN".equals(session.getAttribute("loginRole"));

// 언어 전환 링크: 지금 주소에서 lang 만 바꾼다. 에러 페이지에서는 원래 요청한 주소를 기준으로 한다
String menuUri = (String) request.getAttribute("jakarta.servlet.error.request_uri");
String menuQuery = null;
if (menuUri == null) {
	menuUri = request.getRequestURI();
	menuQuery = request.getQueryString();
}
String menuKoUrl = util.HtmlUtil.escape(util.LangUtil.switchUrl(menuUri, menuQuery, "ko"));
String menuEnUrl = util.HtmlUtil.escape(util.LangUtil.switchUrl(menuUri, menuQuery, "en"));

// 지금 화면에 해당하는 메뉴에 active 를 붙인다 (forward 된 화면이면 forward 된 주소 기준)
String menuPath = request.getServletPath();
String menuEventsOn = ("/events.jsp".equals(menuPath) || "/event.jsp".equals(menuPath)) ? " active" : "";
String menuFormOn = "/eventForm.jsp".equals(menuPath) ? " active" : "";
String menuMembersOn = ("/members.jsp".equals(menuPath) || "/checkAttendance.jsp".equals(menuPath)) ? " active" : "";
String menuReportsOn = "/absenceReports.jsp".equals(menuPath) ? " active" : "";
String menuMyOn = ("/myPage.jsp".equals(menuPath) || "/absenceForm.jsp".equals(menuPath)) ? " active" : "";
String menuLoginOn = "/login.jsp".equals(menuPath) ? " active" : "";
String menuJoinOn = "/join.jsp".equals(menuPath) ? " active" : "";
%>
<header
	class="cc-header d-flex flex-wrap align-items-center justify-content-between pb-3 mb-4 border-bottom">
	<a href="<%=menuCtx%>/events.jsp"
		class="cc-brand d-flex align-items-center text-decoration-none">
		<span class="cc-brand-mark">&#10003;</span>
		<span class="cc-brand-text fs-4 fw-bold">ClubCheck</span>
	</a>
	<ul class="nav cc-nav align-items-center">
		<li class="nav-item"><a href="<%=menuCtx%>/events.jsp" class="nav-link<%=menuEventsOn%>"><fmt:message key="menu.events" /></a></li>
		<%
		if (menuLoginId == null) {
		%>
		<li class="nav-item"><a href="<%=menuCtx%>/login.jsp" class="nav-link<%=menuLoginOn%>"><fmt:message key="menu.login" /></a></li>
		<li class="nav-item"><a href="<%=menuCtx%>/join.jsp" class="nav-link<%=menuJoinOn%>"><fmt:message key="menu.join" /></a></li>
		<%
		} else {
			if (menuIsAdmin) {
		%>
		<li class="nav-item"><a href="<%=menuCtx%>/eventForm.jsp" class="nav-link<%=menuFormOn%>"><fmt:message key="menu.addEvent" /></a></li>
		<li class="nav-item"><a href="<%=menuCtx%>/members.jsp" class="nav-link<%=menuMembersOn%>"><fmt:message key="menu.members" /></a></li>
		<li class="nav-item"><a href="<%=menuCtx%>/absenceReports.jsp" class="nav-link<%=menuReportsOn%>"><fmt:message key="menu.reports" /></a></li>
		<%
			}
			String menuUserName = util.HtmlUtil.escape(menuLoginName);
		%>
		<li class="nav-item"><a href="<%=menuCtx%>/myPage.jsp" class="nav-link<%=menuMyOn%>">
			<fmt:message key="menu.user"><fmt:param value="<%=menuUserName%>" /></fmt:message>
			<%
			if (menuIsAdmin) {
			%>
			<span class="badge text-bg-dark"><fmt:message key="role.badge" /></span>
			<%
			}
			%>
		</a></li>
		<li class="nav-item"><a href="<%=menuCtx%>/logout.jsp" class="nav-link cc-logout"><fmt:message key="menu.logout" /></a></li>
		<%
		}
		%>
		<%-- 언어 전환: 고른 언어는 locale.jsp 가 쿠키에 저장한다 --%>
		<li class="nav-item cc-lang">
			<a href="<%=menuKoUrl%>" class="<%="ko".equals(lang) ? "on" : ""%>">한국어</a>
			<a href="<%=menuEnUrl%>" class="<%="en".equals(lang) ? "on" : ""%>">English</a>
		</li>
	</ul>
</header>
