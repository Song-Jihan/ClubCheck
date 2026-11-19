<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%-- 검사 오류 목록을 현재 언어로 보여 준다. 포함하는 화면에 ArrayList<String> errors 변수가 있어야 한다.
     오류는 메시지 키이고, 값이 필요한 오류는 "키|값" 형식이다 (예: err.event.capacity.belowApplied|3). --%>
<%
if (errors != null && !errors.isEmpty()) {
%>
<div class="alert alert-danger" role="alert">
	<ul class="mb-0">
		<%
		for (String error : errors) {
			String[] errorParts = error.split("\\|");
			String errorKey = errorParts[0];
		%>
		<li><fmt:message key="<%=errorKey%>">
				<%
				for (int p = 1; p < errorParts.length; p++) {
					String errorArg = errorParts[p];
				%><fmt:param value="<%=errorArg%>" /><%
				}
				%>
			</fmt:message></li>
		<%
		}
		%>
	</ul>
</div>
<%
}
%>
