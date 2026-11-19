package util;

import java.util.ArrayList;

/**
 * 결석사유서 입력값을 서버에서 검사한다.
 * 오류는 메시지 키(bundle/message_*.properties 의 err.absence.*)로 돌려준다.
 * 브라우저 검사(resources/js/validation.js 의 checkAbsence)와 같은 규칙을 쓴다.
 */
public class AbsenceValidator {

	public static final int TITLE_MAX = 100;
	public static final int REASON_MAX = 1000;

	public static ArrayList<String> validate(String title, String reason) {
		ArrayList<String> errors = new ArrayList<String>();
		if (title == null || title.isEmpty()) {
			errors.add("err.absence.title.required");
		} else if (title.length() > TITLE_MAX) {
			errors.add("err.absence.title.length");
		}
		if (reason == null || reason.isEmpty()) {
			errors.add("err.absence.reason.required");
		} else if (reason.length() > REASON_MAX) {
			errors.add("err.absence.reason.length");
		}
		return errors;
	}
}
