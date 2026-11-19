<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%-- 모든 화면 아래쪽에 들어가는 공통 푸터. jsp:include 액션 태그로 포함한다.
     따로 실행되는 페이지지만, 포함한 화면이 request 범위에 정해 둔 언어를 그대로 쓴다. --%>
<footer
	class="d-flex flex-wrap justify-content-between align-items-center py-3 my-4 border-top text-secondary">
	&copy; ClubCheck &middot; <fmt:message key="footer.text" /></footer>
