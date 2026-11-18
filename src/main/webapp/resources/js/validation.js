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

// 행사 등록·수정 폼: <form name="eventForm" onsubmit="return checkEvent()">
// 서버도 util/EventValidator.java, util/PosterUtil.java 에서 같은 규칙으로 다시 검사한다.
function checkEvent() {
	var form = document.eventForm.elements;
	var title = form["title"];
	var eventDate = form["eventDate"];
	var location = form["location"];
	var capacity = form["capacity"];
	var description = form["description"];
	var poster = form["poster"];

	title.value = title.value.trim();
	location.value = location.value.trim();

	if (title.value === "" || title.value.length > 100) {
		alert("[행사 이름]\n1~100자로 입력하세요.");
		title.focus();
		return false;
	}
	if (eventDate.value === "") {
		alert("[일시]\n행사 일시를 선택하세요.");
		eventDate.focus();
		return false;
	}
	// 새 행사(min 속성이 있는 경우)는 지금 이후만 가능하다
	if (eventDate.min && new Date(eventDate.value) <= new Date()) {
		alert("[일시]\n현재 시각 이후로 선택하세요.");
		eventDate.focus();
		return false;
	}
	if (location.value === "" || location.value.length > 100) {
		alert("[장소]\n1~100자로 입력하세요.");
		location.focus();
		return false;
	}
	if (!check(/^[0-9]{1,3}$/, capacity, "[정원]\n1~500 사이의 숫자를 입력하세요."))
		return false;
	var cap = parseInt(capacity.value, 10);
	var applied = parseInt(capacity.getAttribute("data-applied") || "0", 10);
	if (cap < 1 || cap > 500) {
		alert("[정원]\n1~500 사이의 숫자를 입력하세요.");
		capacity.focus();
		return false;
	}
	if (cap < applied) {
		alert("[정원]\n이미 " + applied + "명이 신청했으므로 그보다 줄일 수 없습니다.");
		capacity.focus();
		return false;
	}
	if (description.value.length > 2000) {
		alert("[설명]\n2000자 이하로 입력하세요.");
		description.focus();
		return false;
	}
	if (poster.files && poster.files.length > 0) {
		var file = poster.files[0];
		if (!/\.(jpe?g|png|gif|webp)$/i.test(file.name)) {
			alert("[포스터]\nJPG, PNG, GIF, WEBP 이미지만 올릴 수 있습니다.");
			return false;
		}
		if (file.size > 5 * 1024 * 1024) {
			alert("[포스터]\n5MB 이하의 파일만 올릴 수 있습니다.");
			return false;
		}
	}
	return true;
}
