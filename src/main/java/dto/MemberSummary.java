package dto;

import java.io.Serializable;

/** 부원 한 명의 출결 집계 (AttendanceDAO.getMemberSummaries 의 GROUP BY 결과 한 행). */
public class MemberSummary implements Serializable {

	private static final long serialVersionUID = 1L;

	private String id;
	private String name;
	private String studentNo;
	private String role;
	private int presentCount;
	private int absentCount;
	private int appliedCount;
	private int declinedCount;

	public MemberSummary() {
		super();
	}

	/** 출석 처리가 끝난(출석 또는 결석) 횟수 */
	public int getCheckedCount() {
		return presentCount + absentCount;
	}

	/** 출석률(%) = 출석 ÷ 출석 처리된 행사. 처리된 행사가 없으면 -1 */
	public int getAttendanceRate() {
		int checked = getCheckedCount();
		return (checked == 0) ? -1 : Math.round(presentCount * 100f / checked);
	}

	public int getDeclinedCount() {
		return declinedCount;
	}

	public void setDeclinedCount(int declinedCount) {
		this.declinedCount = declinedCount;
	}

	public boolean isAdmin() {
		return Member.ROLE_ADMIN.equals(role);
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
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

	public int getPresentCount() {
		return presentCount;
	}

	public void setPresentCount(int presentCount) {
		this.presentCount = presentCount;
	}

	public int getAbsentCount() {
		return absentCount;
	}

	public void setAbsentCount(int absentCount) {
		this.absentCount = absentCount;
	}

	public int getAppliedCount() {
		return appliedCount;
	}

	public void setAppliedCount(int appliedCount) {
		this.appliedCount = appliedCount;
	}
}
