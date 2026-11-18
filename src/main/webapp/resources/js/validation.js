// 폼 유효성 검사 (브라우저 쪽)
// 서버도 util/MemberValidator.java 에서 같은 규칙으로 한 번 더 검사한다.

// 공통: 값이 정규식에 맞지 않으면 메시지를 띄우고 그 칸으로 커서를 옮긴다
function check(regExp, input, msg) {
	if (regExp.test(input.value)) {
		return true;
	}
	alert(msg);
	input.select();
	input.focus();
	return false;
}

// 회원가입 폼: <form onsubmit="return checkJoin()">
function checkJoin() {
	// form.id, form.name 은 입력칸이 아니라 폼 자신의 속성이라서 elements 로 꺼낸다
	var form = document.joinForm.elements;
	form["name"].value = form["name"].value.trim();
	form["studentNo"].value = form["studentNo"].value.trim();

	if (!check(/^[a-z][a-z0-9]{3,19}$/, form["id"],
			"[아이디]\n영문 소문자로 시작하고, 영문 소문자와 숫자로 4~20자를 입력하세요."))
		return false;

	if (!check(/^(?=.*[A-Za-z])(?=.*[0-9])\S{8,20}$/, form["password"],
			"[비밀번호]\n공백 없이 8~20자로, 영문과 숫자를 모두 포함해야 합니다."))
		return false;

	if (form["password"].value !== form["passwordConfirm"].value) {
		alert("[비밀번호 확인]\n비밀번호가 일치하지 않습니다.");
		form["passwordConfirm"].select();
		form["passwordConfirm"].focus();
		return false;
	}

	if (!check(/^[가-힣A-Za-z][가-힣A-Za-z ]{0,18}[가-힣A-Za-z]$/, form["name"],
			"[이름]\n한글 또는 영문으로 2~20자를 입력하세요."))
		return false;

	if (!check(/^20[0-9]{7}$/, form["studentNo"],
			"[학번]\n9자리 숫자로 입력하세요. (예: 202211469)"))
		return false;

	var year = parseInt(form["studentNo"].value.substring(0, 4), 10);
	if (year > new Date().getFullYear()) {
		alert("[학번]\n입학 연도(앞 4자리)가 올해보다 늦을 수 없습니다.");
		form["studentNo"].select();
		form["studentNo"].focus();
		return false;
	}
	return true;
}

// 로그인 폼: 빈칸만 확인한다 (아이디·비밀번호가 맞는지는 서버가 확인한다)
function checkLogin() {
	var form = document.loginForm.elements;
	if (form["id"].value.trim() === "") {
		alert("아이디를 입력하세요.");
		form["id"].focus();
		return false;
	}
	if (form["password"].value === "") {
		alert("비밀번호를 입력하세요.");
		form["password"].focus();
		return false;
	}
	return true;
}
