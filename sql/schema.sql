-- ClubCheck 스키마 (MySQL 8.0)
-- 실행 순서: schema.sql -> seed.sql
-- 주의: 기존 clubcheck 테이블을 지우고 다시 만든다.

CREATE DATABASE IF NOT EXISTS clubcheck
	DEFAULT CHARACTER SET utf8mb4
	COLLATE utf8mb4_unicode_ci;

USE clubcheck;

-- 외래키 때문에 자식 테이블(absence_report, attendance)부터 지운다
DROP TABLE IF EXISTS absence_report;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS club_event;
DROP TABLE IF EXISTS club_member;

-- 회원: role 로 관리자(임원)와 일반 회원을 구분한다
CREATE TABLE club_member (
	id          VARCHAR(20)  NOT NULL,
	password    VARCHAR(50)  NOT NULL,
	name        VARCHAR(30)  NOT NULL,
	student_no  VARCHAR(10)  NOT NULL,
	role        ENUM('ADMIN', 'MEMBER') NOT NULL DEFAULT 'MEMBER',
	joined_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id),
	UNIQUE KEY uq_member_student_no (student_no)
);

-- 행사: poster_filename 은 업로드된 포스터 파일명 (없으면 NULL)
-- event_type: SEMINAR(정기세미나, 전원 필수 참여) / ACTIVITY(대외활동, 선택 참여)
-- 정기세미나는 정원을 쓰지 않으므로 capacity 를 최대값(500)으로 둔다
CREATE TABLE club_event (
	event_id         INT          NOT NULL AUTO_INCREMENT,
	title            VARCHAR(100) NOT NULL,
	event_type       ENUM('SEMINAR', 'ACTIVITY') NOT NULL DEFAULT 'ACTIVITY',
	description      TEXT,
	event_date       DATETIME     NOT NULL,
	location         VARCHAR(100) NOT NULL,
	capacity         INT          NOT NULL,
	poster_filename  VARCHAR(255),
	created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (event_id)
);

-- 출석: 한 회원은 한 행사에 한 번만 신청할 수 있다 (UNIQUE)
-- status 흐름: APPLIED(신청·미처리) -> PRESENT(출석) 또는 ABSENT(결석)
--             DECLINED: 대외활동에 '미참여'로 응답 (결석·출석률에 넣지 않는다)
-- 정기세미나는 신청 없이 전원이 대상이라, 관리자가 출석을 저장할 때 행이 만들어진다
CREATE TABLE attendance (
	att_id      INT         NOT NULL AUTO_INCREMENT,
	event_id    INT         NOT NULL,
	member_id   VARCHAR(20) NOT NULL,
	status      ENUM('APPLIED', 'PRESENT', 'ABSENT', 'DECLINED') NOT NULL DEFAULT 'APPLIED',
	applied_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
	checked_at  DATETIME,
	PRIMARY KEY (att_id),
	UNIQUE KEY uq_attendance_event_member (event_id, member_id),
	CONSTRAINT fk_attendance_event FOREIGN KEY (event_id)
		REFERENCES club_event (event_id) ON DELETE CASCADE,
	CONSTRAINT fk_attendance_member FOREIGN KEY (member_id)
		REFERENCES club_member (id) ON DELETE CASCADE
);

-- 결석사유서: 정기세미나에 결석(ABSENT)한 회원이 행사마다 하나씩 낸다 (언제든 수정 가능)
-- evidence_filename 은 증빙 이미지 파일명. 파일은 웹에서 바로 열 수 없는 WEB-INF/evidence 에 둔다
CREATE TABLE absence_report (
	report_id          INT          NOT NULL AUTO_INCREMENT,
	event_id           INT          NOT NULL,
	member_id          VARCHAR(20)  NOT NULL,
	title              VARCHAR(100) NOT NULL,
	reason             TEXT         NOT NULL,
	evidence_filename  VARCHAR(255),
	created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (report_id),
	UNIQUE KEY uq_absence_event_member (event_id, member_id),
	CONSTRAINT fk_absence_event FOREIGN KEY (event_id)
		REFERENCES club_event (event_id) ON DELETE CASCADE,
	CONSTRAINT fk_absence_member FOREIGN KEY (member_id)
		REFERENCES club_member (id) ON DELETE CASCADE
);
