-- ClubCheck P5 변경: 이미 만들어 둔 DB 를 데이터는 그대로 두고 고친다
-- (처음부터 다시 만들 때는 schema.sql -> seed.sql 만 실행하면 되고, 이 파일은 필요 없다)
-- 한 번만 실행한다 (두 번째 실행은 'Duplicate column' 오류로 멈춘다. 이미 적용된 것이므로 무시해도 된다).
-- 기존 행사는 모두 대외활동(ACTIVITY)이 된다. 정기세미나로 바꿀 행사는 마지막 UPDATE 예시처럼 고친다.

USE clubcheck;

-- 1) 행사 종류
ALTER TABLE club_event
	ADD COLUMN event_type ENUM('SEMINAR', 'ACTIVITY') NOT NULL DEFAULT 'ACTIVITY' AFTER title;

-- 2) 대외활동 '미참여' 상태
ALTER TABLE attendance
	MODIFY COLUMN status ENUM('APPLIED', 'PRESENT', 'ABSENT', 'DECLINED') NOT NULL DEFAULT 'APPLIED';

-- 3) 결석사유서
CREATE TABLE IF NOT EXISTS absence_report (
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

-- 예시: 1번 행사를 정기세미나로 바꾸기 (정원은 쓰지 않으므로 최대값으로 둔다)
-- UPDATE club_event SET event_type = 'SEMINAR', capacity = 500 WHERE event_id = 1;
