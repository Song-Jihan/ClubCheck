package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Map;

import dto.Attendance;
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
