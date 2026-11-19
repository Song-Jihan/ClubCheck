// 폼 유효성 검사 (브라우저 쪽)
// 서버도 util/MemberValidator.java, util/EventValidator.java, util/PosterUtil.java 에서 같은 규칙으로 다시 검사한다.
// 알림 문구는 jsMessages.jsp 가 현재 언어(한/영)로 만들어 둔 MSG 객체에서 꺼낸다.

// MSG 에 없는 키면 키 이름을 그대로 보여 준다 (문구가 빠졌는지 바로 알 수 있게)
function t(key) {
	return (typeof MSG !== "undefined" && MSG[key]) ? MSG[key] : key;
}

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

	if (!check(/^[a-z][a-z0-9]{3,19}$/, form["id"], t("join.id")))
		return false;

	if (!check(/^(?=.*[A-Za-z])(?=.*[0-9])\S{8,20}$/, form["password"], t("join.password")))
		return false;

	if (form["password"].value !== form["passwordConfirm"].value) {
		alert(t("join.passwordConfirm"));
		form["passwordConfirm"].select();
		form["passwordConfirm"].focus();
		return false;
	}

	if (!check(/^[가-힣A-Za-z][가-힣A-Za-z ]{0,18}[가-힣A-Za-z]$/, form["name"], t("join.name")))
		return false;

	if (!check(/^20[0-9]{7}$/, form["studentNo"], t("join.studentNo")))
		return false;

	var year = parseInt(form["studentNo"].value.substring(0, 4), 10);
	if (year > new Date().getFullYear()) {
		alert(t("join.studentYear"));
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
		alert(t("login.id"));
		form["id"].focus();
		return false;
	}
	if (form["password"].value === "") {
		alert(t("login.password"));
		form["password"].focus();
		return false;
	}
	return true;
}

// 행사 등록·수정 폼: <form name="eventForm" onsubmit="return checkEvent()">
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
		alert(t("event.title"));
		title.focus();
		return false;
	}
	if (eventDate.value === "") {
		alert(t("event.dateEmpty"));
		eventDate.focus();
		return false;
	}
	// 새 행사(min 속성이 있는 경우)는 지금 이후만 가능하다
	if (eventDate.min && new Date(eventDate.value) <= new Date()) {
		alert(t("event.datePast"));
		eventDate.focus();
		return false;
	}
	if (location.value === "" || location.value.length > 100) {
		alert(t("event.location"));
		location.focus();
		return false;
	}
	// 정기세미나는 정원 칸이 꺼져(disabled) 있으므로 검사하지 않는다
	if (!capacity.disabled) {
		if (!check(/^[0-9]{1,3}$/, capacity, t("event.capacity")))
			return false;
		var cap = parseInt(capacity.value, 10);
		var applied = parseInt(capacity.getAttribute("data-applied") || "0", 10);
		if (cap < 1 || cap > 500) {
			alert(t("event.capacity"));
			capacity.focus();
			return false;
		}
		if (cap < applied) {
			alert(t("event.capacityApplied").replace("{0}", applied));
			capacity.focus();
			return false;
		}
	}
	if (description.value.length > 2000) {
		alert(t("event.description"));
		description.focus();
		return false;
	}
	if (poster.files && poster.files.length > 0) {
		var file = poster.files[0];
		if (!/\.(jpe?g|png|gif|webp)$/i.test(file.name)) {
			alert(t("event.posterType"));
			return false;
		}
		if (file.size > 5 * 1024 * 1024) {
			alert(t("event.posterSize"));
			return false;
		}
	}
	return true;
}

// 행사 등록 폼: 종류 라디오를 바꿀 때 정원 칸을 보이거나 숨긴다
function toggleEventType() {
	var seminar = document.getElementById("typeSeminar");
	var group = document.getElementById("capacityGroup");
	var capacity = document.getElementById("capacity");
	if (!seminar || !group || !capacity)
		return;
	group.style.display = seminar.checked ? "none" : "";
	capacity.disabled = seminar.checked;
}

// 결석사유서 폼: <form name="absenceForm" onsubmit="return checkAbsence()">
function checkAbsence() {
	var form = document.absenceForm.elements;
	var title = form["title"];
	var reason = form["reason"];
	var evidence = form["evidence"];

	title.value = title.value.trim();
	reason.value = reason.value.trim();

	if (title.value === "" || title.value.length > 100) {
		alert(t("absence.title"));
		title.focus();
		return false;
	}
	if (reason.value === "" || reason.value.length > 1000) {
		alert(t("absence.reason"));
		reason.focus();
		return false;
	}
	if (evidence.files && evidence.files.length > 0) {
		var file = evidence.files[0];
		if (!/\.(jpe?g|png|gif|webp)$/i.test(file.name)) {
			alert(t("absence.evidenceType"));
			return false;
		}
		if (file.size > 5 * 1024 * 1024) {
			alert(t("absence.evidenceSize"));
			return false;
		}
	}
	return true;
}
