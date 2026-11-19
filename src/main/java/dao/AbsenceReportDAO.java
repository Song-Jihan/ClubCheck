package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import dto.AbsenceReport;
import util.DBConnection;

/** absence_report 테이블(결석사유서)에 접근하는 클래스. */
public class AbsenceReportDAO {

	// 사유서와 함께 행사 이름·일시, 회원 이름·학번, 지금의 출석 상태를 같이 읽는다
	private static final String SELECT_REPORT = "SELECT r.report_id, r.event_id, r.member_id, r.title, r.reason, "
			+ "r.evidence_filename, r.created_at, r.updated_at, "
			+ "e.title AS event_title, e.event_date, m.name, m.student_no, a.status AS attendance_status "
			+ "FROM absence_report r "
			+ "JOIN club_event e ON e.event_id = r.event_id "
			+ "JOIN club_member m ON m.id = r.member_id "
			+ "LEFT JOIN attendance a ON a.event_id = r.event_id AND a.member_id = r.member_id ";

	/** 사유서 번호로 한 건을 조회한다. 없으면 null. */
	public AbsenceReport findById(int reportId) throws SQLException {
		return selectOne(SELECT_REPORT + "WHERE r.report_id = ?", reportId, null);
	}

	/** 그 회원이 그 행사에 낸 사유서. 없으면 null. */
	public AbsenceReport findByEventAndMember(int eventId, String memberId) throws SQLException {
		return selectOne(SELECT_REPORT + "WHERE r.event_id = ? AND r.member_id = ?", eventId, memberId);
	}

	/** 관리자용 전체 목록 (최근에 내거나 고친 것부터). */
	public ArrayList<AbsenceReport> findAll() throws SQLException {
		ArrayList<AbsenceReport> list = new ArrayList<AbsenceReport>();
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(SELECT_REPORT + "ORDER BY r.updated_at DESC, r.report_id DESC");
				ResultSet rs = pstmt.executeQuery()) {
			while (rs.next()) {
				list.add(toReport(rs));
			}
		}
		return list;
	}

	/** 새 사유서를 저장하고 번호를 돌려준다. 같은 행사에 두 번 내면 UNIQUE 제약 위반 예외가 난다. */
	public int insert(AbsenceReport report) throws SQLException {
		String sql = "INSERT INTO absence_report (event_id, member_id, title, reason, evidence_filename) VALUES (?, ?, ?, ?, ?)";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
			pstmt.setInt(1, report.getEventId());
			pstmt.setString(2, report.getMemberId());
			pstmt.setString(3, report.getTitle());
			pstmt.setString(4, report.getReason());
			pstmt.setString(5, report.getEvidenceFilename());
			pstmt.executeUpdate();
			try (ResultSet keys = pstmt.getGeneratedKeys()) {
				if (keys.next()) {
					return keys.getInt(1);
				}
			}
			throw new SQLException("새 사유서 번호를 받지 못했습니다.");
		}
	}

	/** 사유서를 고친다. 본인 것만 고쳐지도록 회원 아이디도 조건에 넣는다. 고친 행이 있으면 true. */
	public boolean update(AbsenceReport report) throws SQLException {
		String sql = "UPDATE absence_report SET title = ?, reason = ?, evidence_filename = ?, updated_at = NOW() "
				+ "WHERE report_id = ? AND member_id = ?";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, report.getTitle());
			pstmt.setString(2, report.getReason());
			pstmt.setString(3, report.getEvidenceFilename());
			pstmt.setInt(4, report.getReportId());
			pstmt.setString(5, report.getMemberId());
			return pstmt.executeUpdate() == 1;
		}
	}

	private AbsenceReport selectOne(String sql, int number, String memberId) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, number);
			if (memberId != null) {
				pstmt.setString(2, memberId);
			}
			try (ResultSet rs = pstmt.executeQuery()) {
				return rs.next() ? toReport(rs) : null;
			}
		}
	}

	private AbsenceReport toReport(ResultSet rs) throws SQLException {
		AbsenceReport r = new AbsenceReport();
		r.setReportId(rs.getInt("report_id"));
		r.setEventId(rs.getInt("event_id"));
		r.setMemberId(rs.getString("member_id"));
		r.setTitle(rs.getString("title"));
		r.setReason(rs.getString("reason"));
		r.setEvidenceFilename(rs.getString("evidence_filename"));
		r.setCreatedAt(rs.getTimestamp("created_at"));
		r.setUpdatedAt(rs.getTimestamp("updated_at"));
		r.setEventTitle(rs.getString("event_title"));
		r.setEventDate(rs.getTimestamp("event_date"));
		r.setMemberName(rs.getString("name"));
		r.setStudentNo(rs.getString("student_no"));
		r.setAttendanceStatus(rs.getString("attendance_status"));
		return r;
	}
}
