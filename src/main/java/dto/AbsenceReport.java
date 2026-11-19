package dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * absence_report 테이블의 한 행(결석사유서)을 담는 자바빈.
 * 화면에 함께 보여 주려고 행사 이름·일시, 회원 이름·학번, 현재 출석 상태도 같이 담는다 (JOIN 결과).
 */
public class AbsenceReport implements Serializable {

	private static final long serialVersionUID = 1L;

	private int reportId;
	private int eventId;
	private String memberId;
	private String title;
	private String reason;
	private String evidenceFilename;
	private Timestamp createdAt;
	private Timestamp updatedAt;

	private String eventTitle;
	private Timestamp eventDate;
	private String memberName;
	private String studentNo;
	private String attendanceStatus;

	public AbsenceReport() {
		super();
	}

	/** 처음 낸 뒤 고친 적이 있으면 true (1초 이상 차이) */
	public boolean isEdited() {
		return createdAt != null && updatedAt != null && updatedAt.getTime() - createdAt.getTime() >= 1000;
	}

	public int getReportId() {
		return reportId;
	}

	public void setReportId(int reportId) {
		this.reportId = reportId;
	}

	public int getEventId() {
		return eventId;
	}

	public void setEventId(int eventId) {
		this.eventId = eventId;
	}

	public String getMemberId() {
		return memberId;
	}

	public void setMemberId(String memberId) {
		this.memberId = memberId;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getReason() {
		return reason;
	}

	public void setReason(String reason) {
		this.reason = reason;
	}

	public String getEvidenceFilename() {
		return evidenceFilename;
	}

	public void setEvidenceFilename(String evidenceFilename) {
		this.evidenceFilename = evidenceFilename;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public Timestamp getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(Timestamp updatedAt) {
		this.updatedAt = updatedAt;
	}

	public String getEventTitle() {
		return eventTitle;
	}

	public void setEventTitle(String eventTitle) {
		this.eventTitle = eventTitle;
	}

	public Timestamp getEventDate() {
		return eventDate;
	}

	public void setEventDate(Timestamp eventDate) {
		this.eventDate = eventDate;
	}

	public String getMemberName() {
		return memberName;
	}

	public void setMemberName(String memberName) {
		this.memberName = memberName;
	}

	public String getStudentNo() {
		return studentNo;
	}

	public void setStudentNo(String studentNo) {
		this.studentNo = studentNo;
	}

	public String getAttendanceStatus() {
		return attendanceStatus;
	}

	public void setAttendanceStatus(String attendanceStatus) {
		this.attendanceStatus = attendanceStatus;
	}
}
