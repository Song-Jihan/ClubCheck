<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="dto.Event"%>
<%@ page import="dto.Attendance"%>
<%@ page import="dto.MemberSummary"%>
<%@ page import="dao.AttendanceDAO"%>
<%@ page import="util.HtmlUtil"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="locale.jsp"%>
<%@ include file="adminCheck.jsp"%>
<jsp:useBean id="eventDAO" class="dao.EventDAO" scope="page" />
<jsp:useBean id="attendanceDAO" class="dao.AttendanceDAO" scope="page" />
<%!
	// 선언문 태그: 행사별 출결표의 칸 하나를 만든다
	private String cell(PageContext pc, String status) {
		if (Attendance.PRESENT.equals(status)) {
			return "<td class=\"text-success fw-bold\" title=\"" + msg(pc, "members.cell.present") + "\">○</td>";
		}
		if (Attendance.ABSENT.equals(status)) {
			return "<td class=\"text-danger fw-bold\" title=\"" + msg(pc, "members.cell.absent") + "\">✕</td>";
		}
		if (Attendance.APPLIED.equals(status)) {
			return "<td class=\"text-secondary small\" title=\"" + msg(pc, "members.cell.pendingTitle") + "\">"
					+ msg(pc, "members.cell.pending") + "</td>";
		}
		if (Attendance.DECLINED.equals(status)) {
			return "<td class=\"text-secondary small\" title=\"" + msg(pc, "members.cell.declinedTitle") + "\">"
					+ msg(pc, "members.cell.declined") + "</td>";
		}
		return "<td class=\"text-body-tertiary\" title=\"" + msg(pc, "members.cell.none") + "\">-</td>";
	}
%>
<%
	// 관리자 전용 부원 출결 현황
	//  - members.jsp?view=event : 행사별 출결표 (기본)
	//  - members.jsp?view=rate  : 부원별 출석률 목록 (&sort=rate 이면 출석률 높은 순)
	String view = "rate".equals(request.getParameter("view")) ? "rate" : "event";
	boolean sortByRate = "rate".equals(request.getParameter("sort"));

	ArrayList<MemberSummary> members = attendanceDAO.getMemberSummaries();
	int memberCount = members.size();
	String adminBadge = "<span class=\"badge text-bg-dark\">" + msg(pageContext, "role.badge") + "</span>";
%>
<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="./resources/css/bootstrap.min.css">
<link rel="stylesheet" href="./resources/css/clubcheck.css">
<title><fmt:message key="members.pageTitle" /> - ClubCheck</title>
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

		<div class="cc-hero mb-4">
			<div class="container-fluid py-3">
				<h1 class="display-6 fw-bold"><fmt:message key="members.pageTitle" /></h1>
				<p class="col-md-8 fs-5 mb-0"><fmt:message key="members.lead"><fmt:param value="<%=memberCount%>" /></fmt:message></p>
			</div>
		</div>

		<ul class="nav nav-tabs mb-4">
			<li class="nav-item"><a href="./members.jsp?view=event"
				class="nav-link <%="event".equals(view) ? "active" : ""%>"><fmt:message key="members.tabEvent" /></a></li>
			<li class="nav-item"><a href="./members.jsp?view=rate"
				class="nav-link <%="rate".equals(view) ? "active" : ""%>"><fmt:message key="members.tabRate" /></a></li>
		</ul>

		<%
		if ("event".equals(view)) {
			// ===== 행사별 출결표: 행 = 부원, 열 = 오늘까지의 행사 =====
			ArrayList<Event> events = eventDAO.getCheckOpenEvents();
			HashMap<String, String> statusMap = attendanceDAO.getStatusMap();
			SimpleDateFormat headerFormat = new SimpleDateFormat("MM.dd");
			int[] presentByEvent = new int[events.size()];
			int[] appliedByEvent = new int[events.size()];
			int eventCount = events.size();
		%>
		<p class="text-secondary small mb-2">
			<span class="text-success fw-bold">○</span> <fmt:message key="members.legend.present" /> &nbsp;
			<span class="text-danger fw-bold">✕</span> <fmt:message key="members.legend.absent" /> &nbsp;
			<fmt:message key="members.legend.pending" /> &nbsp; <fmt:message key="members.legend.declined" /> &nbsp;
			<fmt:message key="members.legend.none" /> &nbsp;·&nbsp;
			<fmt:message key="members.eventCount"><fmt:param value="<%=eventCount%>" /></fmt:message>
		</p>
		<%
			if (events.isEmpty()) {
		%>
		<p class="text-secondary"><fmt:message key="members.empty" /></p>
		<%
			} else {
		%>
		<div class="table-responsive">
			<table class="table table-bordered table-sm align-middle matrix">
				<thead class="table-light">
					<tr>
						<th scope="col" class="sticky-col"><fmt:message key="members.colName" /></th>
						<th scope="col"><fmt:message key="members.colStudentNo" /></th>
						<%
						for (Event e : events) {
						%>
						<th scope="col" title="<%=HtmlUtil.escape(e.getTitle())%>">
							<a href="./checkAttendance.jsp?id=<%=e.getEventId()%>" class="text-decoration-none">
								<%=headerFormat.format(e.getEventDate())%></a>
							<%
							if (e.isSeminar()) {
							%>
							<br><span class="badge text-bg-primary fw-normal"><fmt:message key="members.seminarMark" /></span>
							<%
							}
							%></th>
						<%
						}
						%>
						<th scope="col" class="table-success"><fmt:message key="members.colPresent" /></th>
						<th scope="col" class="table-danger"><fmt:message key="members.colAbsent" /></th>
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
							// 정기세미나는 전원이 대상이라 기록이 없으면 '미처리'로 본다
							if (status == null && events.get(i).isSeminar()) {
								status = Attendance.APPLIED;
							}
							if (Attendance.PRESENT.equals(status)) {
								present++;
								presentByEvent[i]++;
							} else if (Attendance.ABSENT.equals(status)) {
								absent++;
							}
							if (status != null && !Attendance.DECLINED.equals(status)) {
								appliedByEvent[i]++;   // 아래 합계 행의 분모: 출석 대상 인원
							}
						%>
						<%=cell(pageContext, status)%>
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
						<th scope="row" class="sticky-col"><fmt:message key="members.footerRow" /></th>
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
			<p class="text-secondary small mb-0"><fmt:message key="members.rateNote" /></p>
			<div class="btn-group btn-group-sm">
				<a href="./members.jsp?view=rate" class="btn btn-outline-secondary <%=sortByRate ? "" : "active"%>"><fmt:message key="members.sortName" /></a>
				<a href="./members.jsp?view=rate&sort=rate" class="btn btn-outline-secondary <%=sortByRate ? "active" : ""%>"><fmt:message key="members.sortRate" /></a>
			</div>
		</div>
		<table class="table align-middle">
			<thead>
				<tr>
					<th scope="col">#</th>
					<th scope="col"><fmt:message key="members.colName" /></th>
					<th scope="col"><fmt:message key="members.colStudentNo" /></th>
					<th scope="col"><fmt:message key="members.colPresent" /></th>
					<th scope="col"><fmt:message key="members.colAbsent" /></th>
					<th scope="col"><fmt:message key="members.colPending" /></th>
					<th scope="col"><fmt:message key="members.colDeclined" /></th>
					<th scope="col" style="width: 30%;"><fmt:message key="members.colRate" /></th>
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
						<%=m.isAdmin() ? adminBadge : ""%></td>
					<td class="text-secondary"><%=HtmlUtil.escape(m.getStudentNo())%></td>
					<td><%=m.getPresentCount()%></td>
					<td class="<%=m.getAbsentCount() > 0 ? "text-danger" : ""%>"><%=m.getAbsentCount()%></td>
					<td class="text-secondary"><%=m.getAppliedCount()%></td>
					<td class="text-secondary"><%=m.getDeclinedCount()%></td>
					<td>
						<%
						if (rate < 0) {
						%>
						<span class="text-secondary small"><fmt:message key="members.noRate" /></span>
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
