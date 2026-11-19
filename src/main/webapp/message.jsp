<%@ page pageEncoding="UTF-8"%>
<%-- 리다이렉트 뒤에 보여 줄 안내 문구. ?msg=코드 로 전달된 값 중 정해진 코드만 msg.코드 메시지로 출력한다.
     파라미터 값을 그대로 출력하지 않으므로 주소창에 스크립트를 넣어도 실행되지 않는다. --%>
<%
String flashCode = request.getParameter("msg");
String flashType = null;
if (flashCode != null) {
	switch (flashCode) {
	case "joinOk":
	case "loginOk":
	case "eventAdded":
	case "eventUpdated":
	case "applied":
	case "attendanceSaved":
	case "reportSaved":
		flashType = "success";
		break;
	case "logout":
	case "eventDeleted":
	case "applyAlready":
	case "cancelled":
	case "declined":
	case "responseCleared":
	case "declineAlready":
	case "seminarNoApply":
		flashType = "info";
		break;
	case "needLogin":
	case "notFound":
	case "applyFull":
	case "applyClosed":
	case "cancelFail":
	case "checkNotOpen":
	case "reportNotAllowed":
	case "reportNotFound":
		flashType = "warning";
		break;
	case "noAuth":
	case "uploadFail":
		flashType = "danger";
		break;
	default:
		flashType = null;
	}
}
if (flashType != null) {
	String flashKey = "msg." + flashCode;
%>
<div class="alert alert-<%=flashType%>" role="alert"><fmt:message key="<%=flashKey%>" /></div>
<%
}
%>
