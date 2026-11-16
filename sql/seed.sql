-- ClubCheck 시연용 시드 데이터
-- 행사 날짜는 실행한 날을 기준으로 계산하므로, 언제 실행해도
-- "지난 행사 2개 + 예정 행사 3개"가 만들어진다.
-- 회원 이름과 학번은 모두 가상의 값이다.

USE clubcheck;

-- 기존 데이터를 비운다.
-- Workbench 안전 업데이트 모드(오류 1175)는 WHERE 없는 DELETE 를 막으므로
-- TRUNCATE 를 쓴다. 외래키가 걸린 테이블은 검사를 잠시 끄고 비워야 한다.
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE attendance;
TRUNCATE TABLE club_event;
TRUNCATE TABLE club_member;
SET FOREIGN_KEY_CHECKS = 1;

-- 회원 (비밀번호는 수업 수준에 맞춰 평문으로 저장한다)
INSERT INTO club_member (id, password, name, student_no, role) VALUES
	('admin',  'admin1234', '관리자', '202200001', 'ADMIN'),
	('haneul', 'pass1234',  '김하늘', '202300011', 'MEMBER'),
	('doyun',  'pass1234',  '이도윤', '202400022', 'MEMBER'),
	('seoyeon','pass1234',  '박서연', '202500033', 'MEMBER'),
	('minjun', 'pass1234',  '최민준', '202600044', 'MEMBER');

-- 행사 (1, 2번은 지난 행사 / 3, 4, 5번은 예정 행사)
INSERT INTO club_event (event_id, title, description, event_date, location, capacity, poster_filename) VALUES
	(1, '신입 부원 오리엔테이션',
	 '동아리 소개와 한 학기 활동 계획을 안내합니다.\n신입 부원은 꼭 참석해 주세요.',
	 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 14 DAY), '18:00:00'), '학생회관 301호', 30, 'seed_orientation.jpg'),
	(2, '모의유엔(MUN) 교육 세션 1차',
	 '의사 진행 규칙과 발언 방식을 처음부터 배웁니다.\n필기도구를 준비해 주세요.',
	 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY), '18:30:00'), '제2강의동 204호', 20, 'seed_mun1.jpg'),
	(3, '모의유엔(MUN) 교육 세션 2차',
	 '결의안 초안 작성과 수정안 절차를 실습합니다.\n1차 세션 자료를 가져오세요.',
	 TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 3 DAY), '18:30:00'), '제2강의동 204호', 20, 'seed_mun2.jpg'),
	(4, '가을 피크닉',
	 '부원 친목을 위한 야외 피크닉입니다.\n돗자리와 간식은 동아리에서 준비합니다.',
	 TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 10 DAY), '13:00:00'), '광교호수공원 잔디광장', 4, 'seed_picnic.jpg'),
	(5, '정기 총회',
	 '한 학기 활동 결산과 다음 임원진 선출을 진행합니다.',
	 TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 21 DAY), '19:00:00'), '학생회관 대회의실', 40, NULL);

ALTER TABLE club_event AUTO_INCREMENT = 6;

-- 출석 기록
-- 지난 행사는 출석/결석 처리가 끝난 상태, 예정 행사는 신청만 된 상태
INSERT INTO attendance (event_id, member_id, status, applied_at, checked_at) VALUES
	(1, 'haneul',  'PRESENT', DATE_SUB(NOW(), INTERVAL 16 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY)),
	(1, 'doyun',   'PRESENT', DATE_SUB(NOW(), INTERVAL 16 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY)),
	(1, 'seoyeon', 'PRESENT', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY)),
	(1, 'minjun',  'ABSENT',  DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY)),
	(2, 'haneul',  'PRESENT', DATE_SUB(NOW(), INTERVAL 5 DAY),  DATE_SUB(NOW(), INTERVAL 3 DAY)),
	(2, 'doyun',   'ABSENT',  DATE_SUB(NOW(), INTERVAL 5 DAY),  DATE_SUB(NOW(), INTERVAL 3 DAY)),
	(2, 'seoyeon', 'PRESENT', DATE_SUB(NOW(), INTERVAL 4 DAY),  DATE_SUB(NOW(), INTERVAL 3 DAY));

INSERT INTO attendance (event_id, member_id, status) VALUES
	(3, 'haneul',  'APPLIED'),
	(3, 'seoyeon', 'APPLIED'),
	(4, 'haneul',  'APPLIED'),
	(4, 'doyun',   'APPLIED'),
	(4, 'seoyeon', 'APPLIED');
