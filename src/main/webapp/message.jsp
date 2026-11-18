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
	case "eventAdded":
		flashText = "행사가 등록되었습니다.";
		flashType = "success";
		break;
	case "eventUpdated":
		flashText = "행사 정보가 수정되었습니다.";
		flashType = "success";
		break;
	case "eventDeleted":
		flashText = "행사가 삭제되었습니다.";
		break;
	case "notFound":
		flashText = "해당 행사를 찾을 수 없습니다.";
		flashType = "warning";
		break;
	case "applied":
		flashText = "참석 신청이 완료되었습니다.";
		flashType = "success";
		break;
	case "applyFull":
		flashText = "정원이 마감되어 신청할 수 없습니다.";
		flashType = "warning";
		break;
	case "applyClosed":
		flashText = "이미 시작했거나 끝난 행사는 신청할 수 없습니다.";
		flashType = "warning";
		break;
	case "applyAlready":
		flashText = "이미 신청한 행사입니다.";
		break;
	case "cancelled":
		flashText = "참석 신청을 취소했습니다.";
		break;
	case "cancelFail":
		flashText = "취소할 수 없습니다. 행사가 이미 시작했거나 출석 처리가 끝났습니다.";
		flashType = "warning";
		break;
	case "attendanceSaved":
		flashText = "출석 상태를 저장했습니다.";
		flashType = "success";
		break;
	case "checkNotOpen":
		flashText = "출석 체크는 행사 당일부터 할 수 있습니다.";
		flashType = "warning";
		break;
	case "uploadFail":
		flashText = "업로드한 파일이 너무 커서 처리하지 못했습니다. 포스터는 5MB 이하로 올려 주세요.";
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
