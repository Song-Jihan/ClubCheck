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
import dto.MemberSummary;
import util.DBConnection;

/** attendance 테이블(참석 신청과 출석 상태)에 접근하는 클래스. */
public class AttendanceDAO {

	/** 참석 신청 결과 */
	public enum ApplyResult {
		OK, NOT_FOUND, CLOSED, ALREADY, FULL
	}

	/**
	 * 참석을 신청한다.
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
		int capacity;
		Timestamp eventDate;
		try (PreparedStatement pstmt = conn.prepareStatement(
				"SELECT capacity, event_date FROM club_event WHERE event_id = ? FOR UPDATE")) {
			pstmt.setInt(1, eventId);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (!rs.next()) {
					return ApplyResult.NOT_FOUND;
				}
				capacity = rs.getInt("capacity");
				eventDate = rs.getTimestamp("event_date");
			}
		}
		if (eventDate.getTime() <= System.currentTimeMillis()) {
			return ApplyResult.CLOSED;
		}
		if (getStatus(conn, eventId, memberId) != null) {
			return ApplyResult.ALREADY;
		}
		try (PreparedStatement pstmt = conn.prepareStatement(
				"SELECT COUNT(*) FROM attendance WHERE event_id = ?")) {
			pstmt.setInt(1, eventId);
			try (ResultSet rs = pstmt.executeQuery()) {
				rs.next();
				if (rs.getInt(1) >= capacity) {
					return ApplyResult.FULL;
				}
			}
		}
		try (PreparedStatement pstmt = conn.prepareStatement(
				"INSERT INTO attendance (event_id, member_id, status) VALUES (?, ?, 'APPLIED')")) {
			pstmt.setInt(1, eventId);
			pstmt.setString(2, memberId);
			pstmt.executeUpdate();
		}
		return ApplyResult.OK;
	}

	/**
	 * 신청을 취소한다. 아직 출석 처리되지 않았고(APPLIED) 행사가 시작하지 않은 경우만 지운다.
	 * 지운 행이 있으면 true.
	 */
	public boolean cancel(int eventId, String memberId) throws SQLException {
		String sql = "DELETE a FROM attendance a JOIN club_event e ON e.event_id = a.event_id "
				+ "WHERE a.event_id = ? AND a.member_id = ? AND a.status = 'APPLIED' AND e.event_date > NOW()";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, eventId);
			pstmt.setString(2, memberId);
			return pstmt.executeUpdate() == 1;
		}
	}

	/** 회원의 신청 상태(APPLIED, PRESENT, ABSENT). 신청하지 않았으면 null. */
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

	/** 행사 신청자 명단 (신청한 순서). 관리자 출석 체크 화면에서 쓴다. */
	public ArrayList<Attendance> getAttendees(int eventId) throws SQLException {
		String sql = "SELECT a.event_id, a.member_id, a.status, a.applied_at, a.checked_at, "
				+ "m.name, m.student_no, e.title, e.event_date "
				+ "FROM attendance a "
				+ "JOIN club_member m ON m.id = a.member_id "
				+ "JOIN club_event e ON e.event_id = a.event_id "
				+ "WHERE a.event_id = ? ORDER BY a.applied_at, a.att_id";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, eventId);
			return toList(pstmt);
		}
	}

	/** 회원의 참석 기록 (최근 행사부터). 내 정보 화면에서 쓴다. */
	public ArrayList<Attendance> getByMember(String memberId) throws SQLException {
		String sql = "SELECT a.event_id, a.member_id, a.status, a.applied_at, a.checked_at, "
				+ "m.name, m.student_no, e.title, e.event_date "
				+ "FROM attendance a "
				+ "JOIN club_member m ON m.id = a.member_id "
				+ "JOIN club_event e ON e.event_id = a.event_id "
				+ "WHERE a.member_id = ? ORDER BY e.event_date DESC";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, memberId);
			return toList(pstmt);
		}
	}

	/**
	 * 출석 상태를 한꺼번에 저장한다 (회원 아이디 → 새 상태).
	 * 모두 성공하거나 모두 실패하도록 트랜잭션으로 묶는다.
	 * checked_at 은 상태가 바뀐 행만 갱신한다: 출석·결석이면 지금 시각, 미처리(APPLIED)로 되돌리면 NULL.
	 * MySQL 의 UPDATE ... SET 은 왼쪽부터 계산하므로 checked_at 을 status 보다 먼저 써야 '바뀌기 전 상태'와 비교된다.
	 * @return 처리한 행 수 (MySQL 드라이버 기본 설정에서는 값이 그대로인 행도 센다)
	 */
	public int updateStatuses(int eventId, Map<String, String> statusByMember) throws SQLException {
		String sql = "UPDATE attendance SET "
				+ "checked_at = CASE WHEN status = ? THEN checked_at WHEN ? = 'APPLIED' THEN NULL ELSE NOW() END, "
				+ "status = ? "
				+ "WHERE event_id = ? AND member_id = ?";
		try (Connection conn = DBConnection.getConnection()) {
			conn.setAutoCommit(false);
			try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
				int count = 0;
				for (Map.Entry<String, String> entry : statusByMember.entrySet()) {
					String status = entry.getValue();
					if (!Attendance.isValidStatus(status)) {
						throw new SQLException("잘못된 출석 상태 값: " + status);
					}
					pstmt.setString(1, status);
					pstmt.setString(2, status);
					pstmt.setString(3, status);
					pstmt.setInt(4, eventId);
					pstmt.setString(5, entry.getKey());
					count += pstmt.executeUpdate();
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
	 * 모든 부원의 출결을 GROUP BY 로 집계한다 (출석·결석·미처리 신청 횟수).
	 * 한 번도 신청하지 않은 부원도 나오도록 LEFT JOIN 을 쓴다. 이때 SUM 이 NULL 이 되므로 COALESCE 로 0 을 넣는다.
	 */
	public ArrayList<MemberSummary> getMemberSummaries() throws SQLException {
		String sql = "SELECT m.id, m.name, m.student_no, m.role, "
				+ "COALESCE(SUM(a.status = 'PRESENT'), 0) AS present_count, "
				+ "COALESCE(SUM(a.status = 'ABSENT'), 0) AS absent_count, "
				+ "COALESCE(SUM(a.status = 'APPLIED'), 0) AS applied_count "
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

	private ArrayList<Attendance> toList(PreparedStatement pstmt) throws SQLException {
		ArrayList<Attendance> list = new ArrayList<Attendance>();
		try (ResultSet rs = pstmt.executeQuery()) {
			while (rs.next()) {
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
				list.add(a);
			}
		}
		return list;
	}
}
