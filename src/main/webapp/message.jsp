<%@ page pageEncoding="UTF-8"%>
<%-- 리다이렉트 뒤에 보여 줄 안내 문구. ?msg=코드 로 전달된 값만 정해진 문구로 바꿔 출력한다.
     파라미터 값을 그대로 출력하지 않으므로 주소창에 스크립트를 넣어도 실행되지 않는다. --%>
<%
String flashCode = request.getParameter("msg");
String flashText = null;
String flashType = "info";
if (flashCode != null) {
	switch (flashCode) {
	case "joinOk":
		flashText = "회원가입이 완료되었습니다. 로그인해 주세요.";
		flashType = "success";
		break;
	case "loginOk":
		flashText = "로그인되었습니다.";
		flashType = "success";
		break;
	case "logout":
		flashText = "로그아웃되었습니다.";
		break;
	case "needLogin":
		flashText = "로그인이 필요한 서비스입니다.";
		flashType = "warning";
		break;
	case "noAuth":
		flashText = "관리자만 사용할 수 있는 기능입니다.";
		flashType = "danger";
		break;
	default:
		flashText = null;
	}
}
if (flashText != null) {
%>
<div class="alert alert-<%=flashType%>" role="alert"><%=flashText%></div>
<%
}
%>
