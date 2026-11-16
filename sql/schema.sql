-- ClubCheck 스키마 (MySQL 8.0)
-- 실행 순서: schema.sql -> seed.sql
-- 주의: 기존 clubcheck 테이블을 지우고 다시 만든다.

CREATE DATABASE IF NOT EXISTS clubcheck
	DEFAULT CHARACTER SET utf8mb4
	COLLATE utf8mb4_unicode_ci;

USE clubcheck;

-- 외래키 때문에 자식 테이블(attendance)부터 지운다
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
CREATE TABLE club_event (
	event_id         INT          NOT NULL AUTO_INCREMENT,
	title            VARCHAR(100) NOT NULL,
	description      TEXT,
	event_date       DATETIME     NOT NULL,
	location         VARCHAR(100) NOT NULL,
	capacity         INT          NOT NULL,
	poster_filename  VARCHAR(255),
	created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (event_id)
);

-- 출석: 한 회원은 한 행사에 한 번만 신청할 수 있다 (UNIQUE)
-- status 흐름: APPLIED(신청) -> PRESENT(출석) 또는 ABSENT(결석)
CREATE TABLE attendance (
	att_id      INT         NOT NULL AUTO_INCREMENT,
	event_id    INT         NOT NULL,
	member_id   VARCHAR(20) NOT NULL,
	status      ENUM('APPLIED', 'PRESENT', 'ABSENT') NOT NULL DEFAULT 'APPLIED',
	applied_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
	checked_at  DATETIME,
	PRIMARY KEY (att_id),
	UNIQUE KEY uq_attendance_event_member (event_id, member_id),
	CONSTRAINT fk_attendance_event FOREIGN KEY (event_id)
		REFERENCES club_event (event_id) ON DELETE CASCADE,
	CONSTRAINT fk_attendance_member FOREIGN KEY (member_id)
		REFERENCES club_member (id) ON DELETE CASCADE
);
