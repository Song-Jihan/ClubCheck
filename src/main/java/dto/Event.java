package dto;

import java.io.Serializable;
import java.sql.Timestamp;

/** club_event 테이블의 한 행을 담는 자바빈. */
public class Event implements Serializable {

	private static final long serialVersionUID = 1L;

	private int eventId;
	private String title;
	private String description;
	private Timestamp eventDate;
	private String location;
	private int capacity;
	private String posterFilename;

	// 테이블 컬럼이 아니라 attendance 를 집계한 값 (현재 신청 인원)
	private int appliedCount;

	public Event() {
		super();
	}

	/** 행사 시작 시각이 이미 지났으면 true. */
	public boolean isPast() {
		return eventDate != null && eventDate.getTime() < System.currentTimeMillis();
	}

	/** 출석 체크를 할 수 있으면 true. 행사 당일 0시부터 가능하다. */
	public boolean isCheckOpen() {
		if (eventDate == null) {
			return false;
		}
		java.time.LocalDateTime dayStart = eventDate.toLocalDateTime().toLocalDate().atStartOfDay();
		return !java.time.LocalDateTime.now().isBefore(dayStart);
	}

	/** 신청 인원이 정원에 도달했으면 true. */
	public boolean isFull() {
		return appliedCount >= capacity;
	}

	public int getEventId() {
		return eventId;
	}

	public void setEventId(int eventId) {
		this.eventId = eventId;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Timestamp getEventDate() {
		return eventDate;
	}

	public void setEventDate(Timestamp eventDate) {
		this.eventDate = eventDate;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public int getCapacity() {
		return capacity;
	}

	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}

	public String getPosterFilename() {
		return posterFilename;
	}

	public void setPosterFilename(String posterFilename) {
		this.posterFilename = posterFilename;
	}

	public int getAppliedCount() {
		return appliedCount;
	}

	public void setAppliedCount(int appliedCount) {
		this.appliedCount = appliedCount;
	}
}
