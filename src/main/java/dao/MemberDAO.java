package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dto.Member;
import util.DBConnection;

public class MemberDAO {

	/** 아이디로 회원 한 명을 조회한다. 없으면 null 을 돌려준다. */
	public Member findById(String id) throws SQLException {
		String sql = "SELECT id, password, name, student_no, role, joined_at FROM club_member WHERE id = ?";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, id);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return toMember(rs);
				}
				return null;
			}
		}
	}

	/**
	 * 아이디와 비밀번호가 맞으면 회원 정보를, 틀리면 null 을 돌려준다.
	 * 비밀번호는 SQL 의 WHERE 가 아니라 자바에서 비교한다.
	 * 테이블 문자 정렬 규칙(utf8mb4_unicode_ci)이 대소문자를 구분하지 않아서,
	 * WHERE password = ? 로 비교하면 'PASS1234' 도 'pass1234' 와 같다고 판단하기 때문이다.
	 */
	public Member login(String id, String password) throws SQLException {
		Member member = findById(id);
		if (member == null || password == null || !password.equals(member.getPassword())) {
			return null;
		}
		return member;
	}

	public boolean existsById(String id) throws SQLException {
		return exists("SELECT 1 FROM club_member WHERE id = ?", id);
	}

	public boolean existsByStudentNo(String studentNo) throws SQLException {
		return exists("SELECT 1 FROM club_member WHERE student_no = ?", studentNo);
	}

	/** 새 회원을 일반 회원(MEMBER) 권한으로 저장한다. 관리자 권한은 가입으로 얻을 수 없다. */
	public void insert(Member member) throws SQLException {
		String sql = "INSERT INTO club_member (id, password, name, student_no, role) VALUES (?, ?, ?, ?, ?)";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, member.getId());
			pstmt.setString(2, member.getPassword());
			pstmt.setString(3, member.getName());
			pstmt.setString(4, member.getStudentNo());
			pstmt.setString(5, Member.ROLE_MEMBER);
			pstmt.executeUpdate();
		}
	}

	private boolean exists(String sql, String value) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, value);
			try (ResultSet rs = pstmt.executeQuery()) {
				return rs.next();
			}
		}
	}

	private Member toMember(ResultSet rs) throws SQLException {
		Member member = new Member();
		member.setId(rs.getString("id"));
		member.setPassword(rs.getString("password"));
		member.setName(rs.getString("name"));
		member.setStudentNo(rs.getString("student_no"));
		member.setRole(rs.getString("role"));
		member.setJoinedAt(rs.getTimestamp("joined_at"));
		return member;
	}
}
