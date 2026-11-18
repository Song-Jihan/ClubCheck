<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="dto.Event"%>
<%@ page import="dto.Attendance"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.DateUtil"%>
<%@ include file="adminCheck.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<%!
	// 선언문 태그: 출석 상태 라디오 버튼 하나를 만든다
	private String statusRadio(Attendance a, String value, String label, String color, boolean disabled) {
		// 회원 아이디는 가입할 때 영문 소문자·숫자로만 제한되지만, 출력할 때는 한 번 더 이스케이프한다
		String memberId = util.HtmlUtil.escape(a.getMemberId());
		String id = "s_" + memberId + "_" + value;
		return "<input type=\"radio\" class=\"btn-check\" name=\"status_" + memberId + "\" id=\"" + id
				+ "\" value=\"" + value + "\"" + (value.equals(a.getStatus()) ? " checked" : "")
				+ (disabled ? " disabled" : "") + ">"
				+ "<label class=\"btn btn-outline-" + color + " btn-sm\" for=\"" + id + "\">" + label + "</label>";
	}
%>
<%
	Event event = null;
	try {
		event = eventDAO.getEventById(Integer.parseInt(request.getParameter("id")));
	} catch (NumberFormatException e) {
		event = null;
	}
	if (event == null) {
		response.sendRedirect("events.jsp?msg=notFound");
		return;
	}

	ArrayList<Attendance> attendees = attendanceDAO.getAttendees(event.getEventId());
	boolean checkOpen = event.isCheckOpen();

	int present = 0, absent = 0, waiting = 0;
	for (Attendance a : attendees) {
		if (Attendance.PRESENT.equals(a.getStatus())) {
			present++;
		} else if (Attendance.ABSENT.equals(a.getStatus())) {
			absent++;
		} else {
			waiting++;
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<title>출석 체크 - ClubCheck</title>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>
		<%@ include file="message.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold">출석 체크</h1>
				<p class="fs-5 mb-0"><%=HtmlUtil.escape(event.getTitle())%>
					<span class="text-secondary fs-6">· <%=DateUtil.format(event.getEventDate())%></span></p>
			</div>
		</div>

		<div class="d-flex flex-wrap gap-2 mb-3">
			<span class="badge text-bg-light border fs-6">신청 <%=attendees.size()%> / <%=event.getCapacity()%>명</span>
			<span class="badge text-bg-success fs-6">출석 <%=present%></span>
			<span class="badge text-bg-danger fs-6">결석 <%=absent%></span>
			<span class="badge text-bg-secondary fs-6">미처리 <%=waiting%></span>
		</div>

		<%
		if (!checkOpen) {
		%>
		<div class="alert alert-info">출석 체크는 행사 당일부터 할 수 있습니다. 지금은 신청자 명단만 볼 수 있습니다.</div>
		<%
		}
		if (attendees.isEmpty()) {
		%>
		<p class="text-secondary">아직 신청한 회원이 없습니다.</p>
		<%
		} else {
		%>
		<form name="attendanceForm" action="./processCheckAttendance.jsp" method="post">
			<input type="hidden" name="eventId" value="<%=event.getEventId()%>">
			<table class="table align-middle">
				<thead>
					<tr>
						<th scope="col">#</th>
						<th scope="col">이름</th>
						<th scope="col">학번</th>
						<th scope="col">신청 일시</th>
						<th scope="col">상태</th>
						<th scope="col">처리 일시</th>
					</tr>
				</thead>
				<tbody>
					<%
					for (int i = 0; i < attendees.size(); i++) {
						Attendance a = attendees.get(i);
					%>
					<tr>
						<td><%=i + 1%></td>
						<td><%=HtmlUtil.escape(a.getMemberName())%>
							<input type="hidden" name="memberId" value="<%=HtmlUtil.escape(a.getMemberId())%>"></td>
						<td><%=HtmlUtil.escape(a.getStudentNo())%></td>
						<td><%=DateUtil.format(a.getAppliedAt())%></td>
						<td>
							<div class="btn-group" role="group">
								<%=statusRadio(a, Attendance.APPLIED, "미처리", "secondary", !checkOpen)%>
								<%=statusRadio(a, Attendance.PRESENT, "출석", "success", !checkOpen)%>
								<%=statusRadio(a, Attendance.ABSENT, "결석", "danger", !checkOpen)%>
							</div>
						</td>
						<td class="text-secondary"><%=DateUtil.format(a.getCheckedAt())%></td>
					</tr>
					<%
					}
					%>
				</tbody>
			</table>
			<%
			if (checkOpen) {
			%>
			<div class="d-flex gap-2">
				<button type="button" class="btn btn-outline-success" onclick="markAll('PRESENT')">미처리 모두 출석</button>
				<button type="submit" class="btn btn-primary">저장</button>
			</div>
			<%
			}
			%>
		</form>
		<%
		}
		%>
		<p class="mt-4">
			<a href="./event.jsp?id=<%=event.getEventId()%>" class="btn btn-secondary">행사 정보 &raquo;</a>
		</p>

		<jsp:include page="footer.jsp" />
	</div>
	<script>
		// '미처리 모두 출석': 결석으로 표시한 사람은 그대로 두고 나머지를 출석으로 바꾼다 (저장은 따로 눌러야 한다)
		function markAll(status) {
			var radios = document.querySelectorAll('input[type=radio][value=' + status + ']');
			for (var i = 0; i < radios.length; i++) {
				var absent = document.getElementById(radios[i].id.replace(/_PRESENT$/, '_ABSENT'));
				if (!absent || !absent.checked) {
					radios[i].checked = true;
				}
			}
		}
	</script>
</body>
</html>
