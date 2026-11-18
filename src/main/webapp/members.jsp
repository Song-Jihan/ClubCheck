<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="dto.Event"%>
<%@ page import="dto.Attendance"%>
<%@ page import="dto.MemberSummary"%>
<%@ page import="dao.AttendanceDAO"%>
<%@ page import="util.HtmlUtil"%>
<%@ include file="adminCheck.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<%!
	// 선언문 태그: 행사별 출결표의 칸 하나를 만든다
	private String cell(String status) {
		if (Attendance.PRESENT.equals(status)) {
			return "<td class=\"text-success fw-bold\" title=\"출석\">○</td>";
		}
		if (Attendance.ABSENT.equals(status)) {
			return "<td class=\"text-danger fw-bold\" title=\"결석\">✕</td>";
		}
		if (Attendance.APPLIED.equals(status)) {
			return "<td class=\"text-secondary small\" title=\"신청했지만 출석 처리 전\">미처리</td>";
		}
		return "<td class=\"text-body-tertiary\" title=\"신청하지 않음\">-</td>";
	}
%>
<%
	// 관리자 전용 부원 출결 현황
	//  - members.jsp?view=event : 행사별 출결표 (기본)
	//  - members.jsp?view=rate  : 부원별 출석률 목록 (&sort=rate 이면 출석률 높은 순)
	String view = "rate".equals(request.getParameter("view")) ? "rate" : "event";
	boolean sortByRate = "rate".equals(request.getParameter("sort"));

	ArrayList<MemberSummary> members = attendanceDAO.getMemberSummaries();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<title>부원 출결 현황 - ClubCheck</title>
<style>
	/* 행사가 많아 표가 옆으로 길어져도 이름 칸은 왼쪽에 고정한다 */
	.sticky-col { position: sticky; left: 0; background: var(--bs-body-bg); z-index: 1; }
	.matrix th, .matrix td { text-align: center; white-space: nowrap; }
	.matrix .sticky-col { text-align: left; }
</style>
</head>
<body>
	<div class="container py-4">
		<%@ include file="menu.jsp"%>

		<div class="p-5 mb-4 bg-body-tertiary rounded-3">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold">부원 출결 현황</h1>
				<p class="col-md-8 fs-5 mb-0">전체 부원 <%=members.size()%>명</p>
			</div>
		</div>

		<ul class="nav nav-tabs mb-4">
			<li class="nav-item"><a href="./members.jsp?view=event"
				class="nav-link <%="event".equals(view) ? "active" : ""%>">행사별</a></li>
			<li class="nav-item"><a href="./members.jsp?view=rate"
				class="nav-link <%="rate".equals(view) ? "active" : ""%>">출석률</a></li>
		</ul>

		<%
		if ("event".equals(view)) {
			// ===== 행사별 출결표: 행 = 부원, 열 = 오늘까지의 행사 =====
			ArrayList<Event> events = eventDAO.getCheckOpenEvents();
			HashMap<String, String> statusMap = attendanceDAO.getStatusMap();
			SimpleDateFormat headerFormat = new SimpleDateFormat("MM.dd");
			int[] presentByEvent = new int[events.size()];
			int[] appliedByEvent = new int[events.size()];
		%>
		<p class="text-secondary small mb-2">
			<span class="text-success fw-bold">○</span> 출석 &nbsp;
			<span class="text-danger fw-bold">✕</span> 결석 &nbsp;
			미처리: 신청했지만 출석 처리 전 &nbsp; -: 신청하지 않음 &nbsp;·&nbsp;
			오늘까지의 행사 <%=events.size()%>개 · 결석 횟수에 미신청은 포함하지 않습니다.
		</p>
		<%
			if (events.isEmpty()) {
		%>
		<p class="text-secondary">아직 출석 체크가 열린 행사가 없습니다.</p>
		<%
			} else {
		%>
		<div class="table-responsive">
			<table class="table table-bordered table-sm align-middle matrix">
				<thead class="table-light">
					<tr>
						<th scope="col" class="sticky-col">이름</th>
						<th scope="col">학번</th>
						<%
						for (Event e : events) {
						%>
						<th scope="col" title="<%=HtmlUtil.escape(e.getTitle())%>">
							<a href="./checkAttendance.jsp?id=<%=e.getEventId()%>" class="text-decoration-none">
								<%=headerFormat.format(e.getEventDate())%></a></th>
						<%
						}
						%>
						<th scope="col" class="table-success">출석</th>
						<th scope="col" class="table-danger">결석</th>
					</tr>
				</thead>
				<tbody>
					<%
					for (MemberSummary m : members) {
						int present = 0, absent = 0;
					%>
					<tr>
						<th scope="row" class="sticky-col fw-normal"><%=HtmlUtil.escape(m.getName())%></th>
						<td class="text-secondary"><%=HtmlUtil.escape(m.getStudentNo())%></td>
						<%
						for (int i = 0; i < events.size(); i++) {
							String status = statusMap.get(AttendanceDAO.statusKey(events.get(i).getEventId(), m.getId()));
							if (Attendance.PRESENT.equals(status)) {
								present++;
								presentByEvent[i]++;
							} else if (Attendance.ABSENT.equals(status)) {
								absent++;
							}
							if (status != null) {
								appliedByEvent[i]++;
							}
						%>
						<%=cell(status)%>
						<%
						}
						%>
						<td class="fw-bold"><%=present%></td>
						<td class="fw-bold <%=absent > 0 ? "text-danger" : ""%>"><%=absent%></td>
					</tr>
					<%
					}
					%>
				</tbody>
				<tfoot class="table-light">
					<tr>
						<th scope="row" class="sticky-col">출석 / 신청</th>
						<td></td>
						<%
						for (int i = 0; i < events.size(); i++) {
						%>
						<td class="small"><%=presentByEvent[i]%> / <%=appliedByEvent[i]%></td>
						<%
						}
						%>
						<td></td>
						<td></td>
					</tr>
				</tfoot>
			</table>
		</div>
		<%
			}
		} else {
			// ===== 출석률 목록 =====
			if (sortByRate) {
				// 출석률 높은 순, 기록이 없는(-1) 부원은 맨 뒤, 같으면 이름순
				members.sort((a, b) -> a.getAttendanceRate() != b.getAttendanceRate()
						? Integer.compare(b.getAttendanceRate(), a.getAttendanceRate())
						: a.getName().compareTo(b.getName()));
			}
		%>
		<div class="d-flex justify-content-between align-items-center mb-2">
			<p class="text-secondary small mb-0">출석률 = 출석 ÷ (출석 + 결석). 미처리 신청은 계산에서 뺍니다.</p>
			<div class="btn-group btn-group-sm">
				<a href="./members.jsp?view=rate" class="btn btn-outline-secondary <%=sortByRate ? "" : "active"%>">이름순</a>
				<a href="./members.jsp?view=rate&sort=rate" class="btn btn-outline-secondary <%=sortByRate ? "active" : ""%>">출석률순</a>
			</div>
		</div>
		<table class="table align-middle">
			<thead>
				<tr>
					<th scope="col">#</th>
					<th scope="col">이름</th>
					<th scope="col">학번</th>
					<th scope="col">출석</th>
					<th scope="col">결석</th>
					<th scope="col">미처리·예정</th>
					<th scope="col" style="width: 30%;">출석률</th>
				</tr>
			</thead>
			<tbody>
				<%
				for (int i = 0; i < members.size(); i++) {
					MemberSummary m = members.get(i);
					int rate = m.getAttendanceRate();
				%>
				<tr>
					<td><%=i + 1%></td>
					<td><%=HtmlUtil.escape(m.getName())%>
						<%=m.isAdmin() ? "<span class=\"badge text-bg-dark\">관리자</span>" : ""%></td>
					<td class="text-secondary"><%=HtmlUtil.escape(m.getStudentNo())%></td>
					<td><%=m.getPresentCount()%></td>
					<td class="<%=m.getAbsentCount() > 0 ? "text-danger" : ""%>"><%=m.getAbsentCount()%></td>
					<td class="text-secondary"><%=m.getAppliedCount()%></td>
					<td>
						<%
						if (rate < 0) {
						%>
						<span class="text-secondary small">출석 처리된 행사 없음</span>
						<%
						} else {
							// 출석률에 따라 막대 색을 바꾼다 (80% 이상 초록, 50% 이상 노랑, 그 아래 빨강)
							String barColor = rate >= 80 ? "bg-success" : rate >= 50 ? "bg-warning" : "bg-danger";
						%>
						<div class="d-flex align-items-center gap-2">
							<div class="progress flex-grow-1" role="progressbar" aria-valuenow="<%=rate%>"
								aria-valuemin="0" aria-valuemax="100">
								<div class="progress-bar <%=barColor%>" style="width: <%=rate%>%"></div>
							</div>
							<span class="fw-bold" style="width: 3.5em;"><%=rate%>%</span>
						</div>
						<%
						}
						%>
					</td>
				</tr>
				<%
				}
				%>
			</tbody>
		</table>
		<%
		}
		%>

		<jsp:include page="footer.jsp" />
	</div>
</body>
</html>
