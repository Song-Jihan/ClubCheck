package dto;

import java.io.Serializable;
import java.sql.Timestamp;

public class Member implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final String ROLE_ADMIN = "ADMIN";
	public static final String ROLE_MEMBER = "MEMBER";

	private String id;
	private String password;
	private String name;
	private String studentNo;
	private String role;
	private Timestamp joinedAt;

	public Member() {
		super();
	}

	/** 관리자(임원)이면 true. */
	public boolean isAdmin() {
		return ROLE_ADMIN.equals(role);
	}

	/** 학번 앞 4자리(입학 연도). 예: 202211469 → 2022 */
	public String getEntranceYear() {
		if (studentNo == null || studentNo.length() < 4) {
			return "";
		}
		return studentNo.substring(0, 4);
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getStudentNo() {
		return studentNo;
	}

	public void setStudentNo(String studentNo) {
		this.studentNo = studentNo;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public Timestamp getJoinedAt() {
		return joinedAt;
	}

	public void setJoinedAt(Timestamp joinedAt) {
		this.joinedAt = joinedAt;
	}
}
