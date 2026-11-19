<%@ page pageEncoding="UTF-8"%>
<%-- validation.js 의 alert 문구를 현재 언어로 넘겨준다. locale.jsp 다음에 include 디렉티브로 넣는다. --%>
<script>
	var MSG = {
		"join.id": "<fmt:message key="js.join.id"/>",
		"join.password": "<fmt:message key="js.join.password"/>",
		"join.passwordConfirm": "<fmt:message key="js.join.passwordConfirm"/>",
		"join.name": "<fmt:message key="js.join.name"/>",
		"join.studentNo": "<fmt:message key="js.join.studentNo"/>",
		"join.studentYear": "<fmt:message key="js.join.studentYear"/>",
		"login.id": "<fmt:message key="js.login.id"/>",
		"login.password": "<fmt:message key="js.login.password"/>",
		"event.title": "<fmt:message key="js.event.title"/>",
		"event.dateEmpty": "<fmt:message key="js.event.dateEmpty"/>",
		"event.datePast": "<fmt:message key="js.event.datePast"/>",
		"event.location": "<fmt:message key="js.event.location"/>",
		"event.capacity": "<fmt:message key="js.event.capacity"/>",
		"event.capacityApplied": "<fmt:message key="js.event.capacityApplied"/>",
		"event.description": "<fmt:message key="js.event.description"/>",
		"event.posterType": "<fmt:message key="js.event.posterType"/>",
		"event.posterSize": "<fmt:message key="js.event.posterSize"/>",
		"absence.title": "<fmt:message key="js.absence.title"/>",
		"absence.reason": "<fmt:message key="js.absence.reason"/>",
		"absence.evidenceType": "<fmt:message key="js.absence.evidenceType"/>",
		"absence.evidenceSize": "<fmt:message key="js.absence.evidenceSize"/>"
	};
</script>
