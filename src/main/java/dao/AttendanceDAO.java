package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import dto.Attendance;
import dto.Event;
import dto.MemberSummary;
import util.DBConnection;

/**
 * attendance 테이블(참석 신청과 출석 상태)에 접근하는 클래스.
 * - 대외활동(ACTIVITY): 회원이 참여 신청(APPLIED) 또는 미참여(DECLINED)로 응답하고, 신청한 사람만 출석 체크한다.
 * - 정기세미나(SEMINAR): 신청 없이 전원이 대상이다. 관리자가 출석을 저장할 때 행이 만들어진다.
 */
public class AttendanceDAO {

	/** 참석 신청 결과 */
	public enum ApplyResult {
		OK, NOT_FOUND, CLOSED, ALREADY, FULL, SEMINAR
	}

	/** 미참여 응답 결과 */
	public enum DeclineResult {
		OK, NOT_FOUND, CLOSED, ALREADY, SEMINAR
	}

	/** 행 잠금으로 읽은 행사 정보 (트랜잭션 안에서만 쓴다) */
	private static class LockedEvent {
		int capacity;
		Timestamp eventDate;
		String eventType;
	}

	/**
	 * 대외활동에 참여를 신청한다. '미참여'로 응답했던 회원은 참여로 바꾼다.
	 * 정원 확인과 저장을 하나의 트랜잭션으로 묶고, 행사 행을 FOR UPDATE 로 잠근다.
	 * 마지막 한 자리에 두 사람이 동시에 신청해도 한 명만 성공하게 하려는 것이다.
	 */
	public ApplyResult apply(int eventId, String memberId) throws SQLException {
		try (Connection conn = DBConnection.getConnection()) {
			conn.setAutoCommit(false);
			try {
				ApplyResult result = applyInTransaction(conn, eventId, memberId);
				if (result == ApplyResult.OK) {
					conn.commit();
				} else {
					conn.rollback();
				}
				return result;
			} catch (SQLIntegrityConstraintViolationException e) {
				// UNIQUE(event_id, member_id) 위반: 같은 회원이 거의 동시에 두 번 누른 경우
				conn.rollback();
				return ApplyResult.ALREADY;
			} catch (SQLException e) {
				conn.rollback();
				throw e;
			}
		}
	}

	private ApplyResult applyInTransaction(Connection conn, int eventId, String memberId) throws SQLException {
		LockedEvent event = lockEvent(conn, eventId);
		if (event == null) {
			return ApplyResult.NOT_FOUND;
		}
		if (Event.SEMINAR.equals(event.eventType)) {
			return ApplyResult.SEMINAR;
		}
		if (event.eventDate.getTime() <= System.currentTimeMillis()) {
			return ApplyResult.CLOSED;
		}
		String current = getStatus(conn, eventId, memberId);
		if (current != null && !Attendance.DECLINED.equals(current)) {
			return ApplyResult.ALREADY;
		}
		// 정원은 '미참여' 응답을 빼고 센다
		try (PreparedStatement pstmt = conn.prepareStatement(
				"SELECT COUNT(*) FROM attendance WHERE event_id = ? AND status <> 'DECLINED'")) {
			pstmt.setInt(1, eventId);
			try (ResultSet rs = pstmt.executeQuery()) {
				rs.next();
				if (rs.getInt(1) >= event.capacity) {
					return ApplyResult.FULL;
				}
			}
		}
		String sql = (current == null)
				? "INSERT INTO attendance (event_id, member_id, status) VALUES (?, ?, 'APPLIED')"
				: "UPDATE attendance SET status = 'APPLIED', applied_at = NOW() WHERE event_id = ? AND member_id = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, eventId);
			pstmt.setString(2, memberId);
			pstmt.executeUpdate();
		}
		return ApplyResult.OK;
	}

	/**
	 * 대외활동에 '미참여'로 응답한다. 참여 신청했던 회원은 미참여로 바꾼다.
	 * 정기세미나는 전원 필수라 미참여를 고를 수 없다.
	 */
	public DeclineResult decline(int eventId, String memberId) throws SQLException {
		try (Connection conn = DBConnection.getConnection()) {
			conn.setAutoCommit(false);
			try {
				DeclineResult result = declineInTransaction(conn, eventId, memberId);
				if (result == DeclineResult.OK) {
					conn.commit();
				} else {
					conn.rollback();
				}
				return result;
			} catch (SQLIntegrityConstraintViolationException e) {
				conn.rollback();
				return DeclineResult.ALREADY;
			} catch (SQLException e) {
				conn.rollback();
				throw e;
			}
		}
	}

	private DeclineResult declineInTransaction(Connection conn, int eventId, String memberId) throws SQLException {
		LockedEvent event = lockEvent(conn, eventId);
		if (event == null) {
			return DeclineResult.NOT_FOUND;
		}
		if (Event.SEMINAR.equals(event.eventType)) {
			return DeclineResult.SEMINAR;
		}
		if (event.eventDate.getTime() <= System.currentTimeMillis()) {
			return DeclineResult.CLOSED;
		}
		String current = getStatus(conn, eventId, memberId);
		if (current != null && !Attendance.APPLIED.equals(current)) {
			return DeclineResult.ALREADY;   // 이미 미참여, 또는 출석 처리가 끝난 경우
		}
		String sql = (current == null)
				? "INSERT INTO attendance (event_id, member_id, status) VALUES (?, ?, 'DECLINED')"
				: "UPDATE attendance SET status = 'DECLINED', applied_at = NOW() WHERE event_id = ? AND member_id = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, eventId);
			pstmt.setString(2, memberId);
			pstmt.executeUpdate();
		}
		return DeclineResult.OK;
	}

	/** 행사 행을 잠그고 정원·일시·종류를 읽는다. 없으면 null. */
	private LockedEvent lockEvent(Connection conn, int eventId) throws SQLException {
		try (PreparedStatement pstmt = conn.prepareStatement(
				"SELECT capacity, event_date, event_type FROM club_event WHERE event_id = ? FOR UPDATE")) {
			pstmt.setInt(1, eventId);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (!rs.next()) {
					return null;
				}
				LockedEvent event = new LockedEvent();
				event.capacity = rs.getInt("capacity");
				event.eventDate = rs.getTimestamp("event_date");
				event.eventType = rs.getString("event_type");
				return event;
			}
		}
	}

	/**
	 * 대외활동의 응답(참여 신청 또는 미참여)을 지운다. 행사 시작 전이고 출석 처리 전인 경우만 지운다.
	 * 지운 행이 있으면 true.
	 */
	public boolean cancel(int eventId, String memberId) throws SQLException {
		String sql = "DELETE a FROM attendance a JOIN club_event e ON e.event_id = a.event_id "
				+ "WHERE a.event_id = ? AND a.member_id = ? AND a.status IN ('APPLIED', 'DECLINED') "
				+ "AND e.event_type = 'ACTIVITY' AND e.event_date > NOW()";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, eventId);
			pstmt.setString(2, memberId);
			return pstmt.executeUpdate() == 1;
		}
	}

	/** 회원의 상태(APPLIED, PRESENT, ABSENT, DECLINED). 기록이 없으면 null. */
	public String getStatus(int eventId, String memberId) throws SQLException {
		try (Connection conn = DBConnection.getConnection()) {
			return getStatus(conn, eventId, memberId);
		}
	}

	private String getStatus(Connection conn, int eventId, String memberId) throws SQLException {
		try (PreparedStatement pstmt = conn.prepareStatement(
				"SELECT status FROM attendance WHERE event_id = ? AND member_id = ?")) {
			pstmt.setInt(1, eventId);
			pstmt.setString(2, memberId);
			try (ResultSet rs = pstmt.executeQuery()) {
				return rs.next() ? rs.getString("status") : null;
			}
		}
	}

	private static final String SELECT_JOINED = "SELECT a.event_id, a.member_id, a.status, a.applied_at, a.checked_at, "
			+ "m.name, m.student_no, e.title, e.event_date, e.event_type, "
			+ "COALESCE(r.report_id, 0) AS report_id "
			+ "FROM attendance a "
			+ "JOIN club_member m ON m.id = a.member_id "
			+ "JOIN club_event e ON e.event_id = a.event_id "
			+ "LEFT JOIN absence_report r ON r.event_id = a.event_id AND r.member_id = a.member_id ";

	/** 대외활동의 출석 체크 명단: 참여를 신청한 사람 (신청한 순서, '미참여' 제외). */
	public ArrayList<Attendance> getAttendees(int eventId) throws SQLException {
		return selectJoined(SELECT_JOINED + "WHERE a.event_id = ? AND a.status <> 'DECLINED' ORDER BY a.applied_at, a.att_id",
				eventId);
	}

	/** 대외활동에 '미참여'로 응답한 사람. 관리자 출석 체크 화면에 따로 보여 준다. */
	public ArrayList<Attendance> getDeclined(int eventId) throws SQLException {
		return selectJoined(SELECT_JOINED + "WHERE a.event_id = ? AND a.status = 'DECLINED' ORDER BY m.name", eventId);
	}

	/**
	 * 정기세미나의 출석 체크 명단: 가입한 회원 전원(임원 포함).
	 * 아직 출석 기록이 없는 회원은 미처리(APPLIED)로 채운다. LEFT JOIN 으로 기록이 없는 회원도 나온다.
	 */
	public ArrayList<Attendance> getSeminarRoster(int eventId) throws SQLException {
		String sql = "SELECT m.id, m.name, m.student_no, a.status, a.applied_at, a.checked_at, "
				+ "COALESCE(r.report_id, 0) AS report_id "
				+ "FROM club_member m "
				+ "LEFT JOIN attendance a ON a.member_id = m.id AND a.event_id = ? "
				+ "LEFT JOIN absence_report r ON r.member_id = m.id AND r.event_id = ? "
				+ "ORDER BY m.name, m.id";
		ArrayList<Attendance> list = new ArrayList<Attendance>();
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, eventId);
			pstmt.setInt(2, eventId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					Attendance a = new Attendance();
					a.setEventId(eventId);
					a.setEventType(Event.SEMINAR);
					a.setMemberId(rs.getString("id"));
					a.setMemberName(rs.getString("name"));
					a.setStudentNo(rs.getString("student_no"));
					String status = rs.getString("status");
					a.setStatus(status == null ? Attendance.APPLIED : status);
					a.setAppliedAt(rs.getTimestamp("applied_at"));
					a.setCheckedAt(rs.getTimestamp("checked_at"));
					a.setReportId(rs.getInt("report_id"));
					list.add(a);
				}
			}
		}
		return list;
	}

	/** 회원의 참석 기록 (최근 행사부터, '미참여' 응답 포함). 내 정보 화면에서 쓴다. */
	public ArrayList<Attendance> getByMember(String memberId) throws SQLException {
		String sql = SELECT_JOINED + "WHERE a.member_id = ? ORDER BY e.event_date DESC";
		ArrayList<Attendance> list = new ArrayList<Attendance>();
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, memberId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					list.add(toAttendance(rs));
				}
			}
		}
		return list;
	}

	/**
	 * 출석 상태를 한꺼번에 저장한다 (회원 아이디 → 새 상태).
	 * 모두 성공하거나 모두 실패하도록 트랜잭션으로 묶는다.
	 * insertMissing 이 true 이면(정기세미나) 기록이 없는 회원은 새로 넣는다. 단 미처리(APPLIED)는 넣지 않는다(기록 없음 = 미처리).
	 * checked_at 은 상태가 바뀐 행만 갱신한다: 출석·결석이면 지금 시각, 미처리(APPLIED)로 되돌리면 NULL.
	 * MySQL 의 UPDATE ... SET 은 왼쪽부터 계산하므로 checked_at 을 status 보다 먼저 써야 '바뀌기 전 상태'와 비교된다.
	 * '미참여'(DECLINED) 응답은 출석 체크로 바꾸지 않는다.
	 * @return 처리한 행 수
	 */
	public int updateStatuses(int eventId, Map<String, String> statusByMember, boolean insertMissing) throws SQLException {
		String update = "UPDATE attendance SET "
				+ "checked_at = CASE WHEN status = ? THEN checked_at WHEN ? = 'APPLIED' THEN NULL ELSE NOW() END, "
				+ "status = ? "
				+ "WHERE event_id = ? AND member_id = ? AND status <> 'DECLINED'";
		String insert = "INSERT INTO attendance (event_id, member_id, status, checked_at) "
				+ "VALUES (?, ?, ?, CASE WHEN ? = 'APPLIED' THEN NULL ELSE NOW() END)";
		try (Connection conn = DBConnection.getConnection()) {
			conn.setAutoCommit(false);
			try (PreparedStatement up = conn.prepareStatement(update);
					PreparedStatement in = conn.prepareStatement(insert)) {
				int count = 0;
				for (Map.Entry<String, String> entry : statusByMember.entrySet()) {
					String status = entry.getValue();
					if (!Attendance.isValidStatus(status)) {
						throw new SQLException("잘못된 출석 상태 값: " + status);
					}
					up.setString(1, status);
					up.setString(2, status);
					up.setString(3, status);
					up.setInt(4, eventId);
					up.setString(5, entry.getKey());
					// MySQL 드라이버 기본 설정에서는 값이 그대로인 행도 1로 센다 → 0 이면 기록이 없는 것
					int updated = up.executeUpdate();
					if (updated == 0 && insertMissing && !Attendance.APPLIED.equals(status)
							&& getStatus(conn, eventId, entry.getKey()) == null) {
						in.setInt(1, eventId);
						in.setString(2, entry.getKey());
						in.setString(3, status);
						in.setString(4, status);
						updated = in.executeUpdate();
					}
					count += updated;
				}
				conn.commit();
				return count;
			} catch (SQLException e) {
				conn.rollback();
				throw e;
			}
		}
	}

	/**
	 * 모든 부원의 출결을 GROUP BY 로 집계한다 (출석·결석·미처리 신청·미참여 횟수).
	 * 한 번도 신청하지 않은 부원도 나오도록 LEFT JOIN 을 쓴다. 이때 SUM 이 NULL 이 되므로 COALESCE 로 0 을 넣는다.
	 */
	public ArrayList<MemberSummary> getMemberSummaries() throws SQLException {
		String sql = "SELECT m.id, m.name, m.student_no, m.role, "
				+ "COALESCE(SUM(a.status = 'PRESENT'), 0) AS present_count, "
				+ "COALESCE(SUM(a.status = 'ABSENT'), 0) AS absent_count, "
				+ "COALESCE(SUM(a.status = 'APPLIED'), 0) AS applied_count, "
				+ "COALESCE(SUM(a.status = 'DECLINED'), 0) AS declined_count "
				+ "FROM club_member m LEFT JOIN attendance a ON a.member_id = m.id "
				+ "GROUP BY m.id, m.name, m.student_no, m.role "
				+ "ORDER BY m.name, m.id";
		ArrayList<MemberSummary> list = new ArrayList<MemberSummary>();
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql);
				ResultSet rs = pstmt.executeQuery()) {
			while (rs.next()) {
				MemberSummary s = new MemberSummary();
				s.setId(rs.getString("id"));
				s.setName(rs.getString("name"));
				s.setStudentNo(rs.getString("student_no"));
				s.setRole(rs.getString("role"));
				s.setPresentCount(rs.getInt("present_count"));
				s.setAbsentCount(rs.getInt("absent_count"));
				s.setAppliedCount(rs.getInt("applied_count"));
				s.setDeclinedCount(rs.getInt("declined_count"));
				list.add(s);
			}
		}
		return list;
	}

	/** 모든 출석 기록을 "행사번호/회원아이디" → 상태 로 돌려준다. 행사별 출결표를 채울 때 쓴다. */
	public HashMap<String, String> getStatusMap() throws SQLException {
		HashMap<String, String> map = new HashMap<String, String>();
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement("SELECT event_id, member_id, status FROM attendance");
				ResultSet rs = pstmt.executeQuery()) {
			while (rs.next()) {
				map.put(statusKey(rs.getInt("event_id"), rs.getString("member_id")), rs.getString("status"));
			}
		}
		return map;
	}

	/** getStatusMap 의 키 */
	public static String statusKey(int eventId, String memberId) {
		return eventId + "/" + memberId;
	}

	private ArrayList<Attendance> selectJoined(String sql, int eventId) throws SQLException {
		ArrayList<Attendance> list = new ArrayList<Attendance>();
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, eventId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					list.add(toAttendance(rs));
				}
			}
		}
		return list;
	}

	private Attendance toAttendance(ResultSet rs) throws SQLException {
		Attendance a = new Attendance();
		a.setEventId(rs.getInt("event_id"));
		a.setMemberId(rs.getString("member_id"));
		a.setStatus(rs.getString("status"));
		a.setAppliedAt(rs.getTimestamp("applied_at"));
		a.setCheckedAt(rs.getTimestamp("checked_at"));
		a.setMemberName(rs.getString("name"));
		a.setStudentNo(rs.getString("student_no"));
		a.setEventTitle(rs.getString("title"));
		a.setEventDate(rs.getTimestamp("event_date"));
		a.setEventType(rs.getString("event_type"));
		a.setReportId(rs.getInt("report_id"));
		return a;
	}
}
