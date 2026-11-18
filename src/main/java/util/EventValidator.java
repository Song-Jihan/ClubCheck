package util;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;

import dto.Event;

/**
 * 행사 등록·수정 입력값을 서버에서 검사한다.
 * 브라우저 검사(resources/js/validation.js 의 checkEvent)와 같은 규칙을 쓴다.
 */
public class EventValidator {

	public static final int TITLE_MAX = 100;
	public static final int LOCATION_MAX = 100;
	public static final int DESCRIPTION_MAX = 2000;
	public static final int CAPACITY_MIN = 1;
	public static final int CAPACITY_MAX = 500;

	/**
	 * @param original 수정할 때는 원래 행사, 새로 등록할 때는 null
	 * @return 오류 메시지 목록. 비어 있으면 통과다.
	 */
	public static ArrayList<String> validate(String title, String description, String eventDate,
			String location, String capacity, Event original) {
		ArrayList<String> errors = new ArrayList<String>();

		if (title == null || title.isEmpty()) {
			errors.add("행사 이름을 입력하세요.");
		} else if (title.length() > TITLE_MAX) {
			errors.add("행사 이름은 " + TITLE_MAX + "자 이하로 입력하세요.");
		}

		Timestamp date = parseDate(eventDate);
		if (date == null) {
			errors.add("행사 일시를 올바르게 입력하세요.");
		} else {
			// 새 행사이거나 수정하면서 일시를 바꾼 경우에만 '앞으로의 일시'인지 검사한다.
			// (이미 지난 행사의 오타만 고치는 경우는 막지 않는다)
			boolean dateChanged = original == null || original.getEventDate() == null
					|| !truncateToMinute(original.getEventDate()).equals(date);
			if (dateChanged && date.getTime() <= System.currentTimeMillis()) {
				errors.add("행사 일시는 현재 시각 이후여야 합니다.");
			}
		}

		if (location == null || location.isEmpty()) {
			errors.add("장소를 입력하세요.");
		} else if (location.length() > LOCATION_MAX) {
			errors.add("장소는 " + LOCATION_MAX + "자 이하로 입력하세요.");
		}

		Integer cap = parseCapacity(capacity);
		if (cap == null || cap < CAPACITY_MIN || cap > CAPACITY_MAX) {
			errors.add("정원은 " + CAPACITY_MIN + "~" + CAPACITY_MAX + " 사이의 숫자로 입력하세요.");
		} else if (original != null && cap < original.getAppliedCount()) {
			errors.add("이미 " + original.getAppliedCount() + "명이 신청했으므로 정원을 그보다 줄일 수 없습니다.");
		}

		if (description != null && description.length() > DESCRIPTION_MAX) {
			errors.add("설명은 " + DESCRIPTION_MAX + "자 이하로 입력하세요.");
		}
		return errors;
	}

	/** "2026-11-19T18:30" 형식을 Timestamp 로 바꾼다. 형식이 틀리면 null. */
	public static Timestamp parseDate(String value) {
		if (value == null || value.isEmpty()) {
			return null;
		}
		try {
			return Timestamp.valueOf(LocalDateTime.parse(value).truncatedTo(ChronoUnit.MINUTES));
		} catch (DateTimeParseException e) {
			return null;
		}
	}

	/** 숫자가 아니면 null. */
	public static Integer parseCapacity(String value) {
		if (value == null || !value.matches("^[0-9]{1,4}$")) {
			return null;
		}
		return Integer.valueOf(value);
	}

	private static Timestamp truncateToMinute(Timestamp t) {
		return Timestamp.valueOf(t.toLocalDateTime().truncatedTo(ChronoUnit.MINUTES));
	}
}
