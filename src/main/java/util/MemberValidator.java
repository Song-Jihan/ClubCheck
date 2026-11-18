package util;

import java.time.Year;
import java.util.ArrayList;
import java.util.regex.Pattern;

public class MemberValidator {

	// 아이디: 영문 소문자로 시작, 영문 소문자와 숫자 4~20자
	public static final Pattern ID = Pattern.compile("^[a-z][a-z0-9]{3,19}$");

	// 비밀번호: 공백 없이 8~20자, 영문과 숫자를 각각 하나 이상 포함
	public static final Pattern PASSWORD = Pattern.compile("^(?=.*[A-Za-z])(?=.*[0-9])\\S{8,20}$");

	// 이름: 한글 또는 영문(가운데 공백 허용) 2~20자
	public static final Pattern NAME = Pattern.compile("^[가-힣A-Za-z][가-힣A-Za-z ]{0,18}[가-힣A-Za-z]$");

	// 학번: 입학 연도 4자리 + 일련번호 5자리. 예: 202211469
	public static final Pattern STUDENT_NO = Pattern.compile("^(20[0-9]{2})[0-9]{5}$");

	// 입력값에 대한 오류 메시지 목록을 돌려준다. 비어 있으면 통과다.
	public static ArrayList<String> validateJoin(String id, String password, String passwordConfirm,
			String name, String studentNo) {
		ArrayList<String> errors = new ArrayList<String>();

		if (id == null || !ID.matcher(id).matches()) {
			errors.add("아이디는 영문 소문자로 시작하고, 영문 소문자와 숫자로 4~20자여야 합니다.");
		}
		if (password == null || !PASSWORD.matcher(password).matches()) {
			errors.add("비밀번호는 공백 없이 8~20자이며, 영문과 숫자를 모두 포함해야 합니다.");
		} else if (!password.equals(passwordConfirm)) {
			errors.add("비밀번호 확인이 일치하지 않습니다.");
		}
		if (name == null || !NAME.matcher(name).matches()) {
			errors.add("이름은 한글 또는 영문으로 2~20자여야 합니다.");
		}
		if (studentNo == null || !STUDENT_NO.matcher(studentNo).matches()) {
			errors.add("학번은 9자리 숫자여야 합니다. (예: 202211469)");
		} else {
			int year = Integer.parseInt(studentNo.substring(0, 4));
			if (year > Year.now().getValue()) {
				errors.add("학번의 입학 연도(앞 4자리)가 올해보다 늦을 수 없습니다.");
			}
		}
		return errors;
	}

	// 쿠키 등 외부에서 들어온 아이디가 형식에 맞는지 확인한다.
	public static boolean isValidId(String id) {
		return id != null && ID.matcher(id).matches();
	}
}
