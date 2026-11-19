package dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * attendance 테이블의 한 행을 담는 자바빈.
 * 화면에 함께 보여 주려고 회원 이름·학번, 행사 이름·일시도 같이 담는다 (JOIN 결과).
 */
public class Attendance implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final String APPLIED = "APPLIED";
	public static final String PRESENT = "PRESENT";
	public static final String ABSENT = "ABSENT";
	/** 대외활동에 '미참여'로 응답함 (결석·출석률에 넣지 않는다) */
	public static final String DECLINED = "DECLINED";

	private int eventId;
	private String memberId;
	private String status;
	private Timestamp appliedAt;
	private Timestamp checkedAt;

	private String memberName;
	private String studentNo;
	private String eventTitle;
	private Timestamp eventDate;
	private String eventType;
	// 이 결석에 낸 결석사유서 번호 (없으면 0)
	private int reportId;

	public Attendance() {
		super();
	}

	/** 관리자가 출석 체크에서 정할 수 있는 상태(APPLIED, PRESENT, ABSENT)이면 true. 폼에서 들어온 값을 검사할 때 쓴다. */
	public static boolean isValidStatus(String status) {
		return APPLIED.equals(status) || PRESENT.equals(status) || ABSENT.equals(status);
	}

	/** 정기세미나 결석이라 결석사유서를 낼 수 있으면 true. */
	public boolean isReportable() {
		return ABSENT.equals(status) && Event.SEMINAR.equals(eventType);
	}

	/** 행사가 이미 시작했으면 true. */
	public boolean isEventPast() {
		return eventDate != null && eventDate.getTime() < System.currentTimeMillis();
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

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Timestamp getAppliedAt() {
		return appliedAt;
	}

	public void setAppliedAt(Timestamp appliedAt) {
		this.appliedAt = appliedAt;
	}

	public Timestamp getCheckedAt() {
		return checkedAt;
	}

	public void setCheckedAt(Timestamp checkedAt) {
		this.checkedAt = checkedAt;
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

	public String getEventTitle() {
		return eventTitle;
	}

	public void setEventTitle(String eventTitle) {
		this.eventTitle = eventTitle;
	}

	public String getEventType() {
		return eventType;
	}

	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

	public int getReportId() {
		return reportId;
	}

	public void setReportId(int reportId) {
		this.reportId = reportId;
	}

	public Timestamp getEventDate() {
		return eventDate;
	}

	public void setEventDate(Timestamp eventDate) {
		this.eventDate = eventDate;
	}
}
