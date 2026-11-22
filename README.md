# ClubCheck — 동아리 행사·출석 관리

JSP 기초 기술만으로 만든 동아리 행사 등록·참석 신청·출석 관리 웹 애플리케이션입니다.

## 실행 환경

| 항목 | 버전 |
|---|---|
| JDK | 20 이상 (Eclipse 프로젝트 설정은 JavaSE-21) |
| 서버 | Apache Tomcat 10.1 |
| DB | MySQL 8.0 |
| IDE | Eclipse (Dynamic Web Project) |

## 실행 방법

1. **프로젝트 가져오기**
   `ClubCheck` 폴더를 Eclipse 워크스페이스 폴더에 넣고
   `File > Import > General > Existing Projects into Workspace`로 가져옵니다.

2. **MySQL 드라이버 추가**
   `src/main/webapp/WEB-INF/lib/mysql-connector-j-8.0.33.jar`가 저장소에 포함되어 있습니다.
   다른 버전을 쓰려면 이 파일을 교체합니다.

3. **DB 만들기**
   MySQL Workbench 또는 콘솔에서 아래 순서로 실행합니다.
   ```
   sql/schema.sql
   sql/seed.sql
   ```
   P4 이전에 만든 DB를 데이터 그대로 쓰려면 `sql/migrate_p5.sql`을 **한 번만** 실행합니다 (기존 행사는 모두 대외활동이 됩니다).

4. **DB 접속 정보 설정**
   `src/main/java/db.properties.example`을 같은 폴더에 `db.properties`라는 이름으로 복사한 뒤,
   `DB_USER`, `DB_PASSWORD`를 본인 MySQL 계정에 맞게 고칩니다.
   `db.properties`는 `.gitignore`에 등록되어 있어 저장소에 올라가지 않습니다.
   파일을 새로 만들거나 고친 뒤에는 서버를 다시 시작해야 반영됩니다.

5. **서버 실행**
   프로젝트를 Tomcat 10.1 서버에 추가하고 실행한 뒤 접속합니다.
   ```
   http://localhost:8080/ClubCheck/
   ```

## 시드 계정

| 아이디 | 비밀번호 | 역할 |
|---|---|---|
| admin | admin1234 | 관리자 |
| haneul, doyun, seoyeon, minjun | pass1234 | 일반 회원 |

회원 이름과 학번은 모두 가상의 값입니다.

시드 행사는 실행한 날을 기준으로 지난 행사 3개와 예정 행사 3개(각각 정기세미나 2개, 대외활동 1개)가 되도록 날짜가 정해지고, 결석사유서 1건(doyun)이 들어 있습니다.

## 구현된 기능

| 기능 | 화면 | 사용 기술 |
|---|---|---|
| 회원가입 | `join.jsp` → `processJoin.jsp` | 폼 태그, JS 정규식 검사 + 서버 검사(`MemberValidator`), 중복 검사, `jsp:forward` |
| 로그인 | `login.jsp` → `processLogin.jsp` | 세션(`loginId`, `loginName`, `loginRole`), 로그인 시 세션 재발급 |
| 아이디 저장 | `login.jsp` | 쿠키 `savedId` (30일, HttpOnly) |
| 로그아웃 | `logout.jsp` | `session.invalidate()` |
| 내 정보 | `myPage.jsp` | 로그인 확인 `loginCheck.jsp` |
| 관리자 확인 | `adminCheck.jsp` | 관리자 화면 맨 위에 include |
| 행사 등록·수정 | `eventForm.jsp` → `processEvent.jsp` | 파일 업로드(`cos2.jar` `MultipartRequest`), `jsp:useBean`·`jsp:setProperty`, 서버 검사(`EventValidator`) |
| 행사 삭제 | `event.jsp` → `processDeleteEvent.jsp` | POST 전용, 삭제 확인창, 참석 신청 함께 삭제(ON DELETE CASCADE) |
| 행사 종류 | `eventForm.jsp`, `events.jsp`, `event.jsp` | 정기세미나(전원 필수, 신청·정원 없음) / 대외활동(선택 참여). 종류는 등록할 때만 고른다 |
| 참여 신청·미참여·취소 | `event.jsp` → `processApply.jsp`, `processDecline.jsp`, `processCancel.jsp` | 대외활동만. 세션의 회원 아이디 사용, 트랜잭션 + `SELECT ... FOR UPDATE`로 정원 초과 방지 |
| 출석 체크 | `checkAttendance.jsp` → `processCheckAttendance.jsp` | 관리자 전용, 행사 당일부터, 여러 명을 한 번에 저장(트랜잭션). 정기세미나는 부원 전원 명단(`LEFT JOIN`), 대외활동은 신청자 명단 + 미참여 응답자 |
| 내 참석 기록 | `myPage.jsp` | JOIN 조회, 출석률(출석 ÷ 출석 처리된 행사), div 너비로 그린 막대 |
| 부원 출결 현황 | `members.jsp` | 관리자 전용. 행사별 탭: 부원 × 오늘까지의 행사 출결표와 출석·결석 횟수. 출석률 탭: `GROUP BY` 집계, 이름순·출석률순 정렬 |
| 결석사유서 작성·수정 | `myPage.jsp`, `absenceForm.jsp` → `processAbsence.jsp` | 정기세미나 결석만. 파일 업로드(증빙 이미지, 선택), 서버 검사(`AbsenceValidator`), 낸 뒤에도 본인이 수정 |
| 결석사유서 보기 | `absenceReport.jsp`, `evidence.jsp` | 본인 또는 관리자만. 증빙 이미지는 `WEB-INF/evidence`에 두고 권한 확인 뒤 내보냄 |
| 결석사유서 목록 | `absenceReports.jsp` | 관리자 전용. 행사·이름·학번·제목·증빙 여부·현재 출석 상태 |

### 다국어 처리 (한/영)

- 화면 문구는 `src/main/java/bundle/message_ko.properties`, `message_en.properties`에 있고, JSP는 JSTL `<fmt:message>`로 꺼냅니다.
- 한글은 `\uXXXX`로 저장되어 있습니다. IntelliJ에서 한글로 보려면 Settings > Editor > File Encodings > *Transparent native-to-ascii conversion*을 켭니다.
- `locale.jsp`: 모든 화면 맨 위에 include. `?lang=ko|en`이면 그 언어를 쓰고 쿠키 `lang`(1년)에 저장, 없으면 쿠키, 둘 다 없으면 한국어. 언어와 메시지 묶음은 request 범위라서 `jsp:include`한 푸터와 forward된 화면도 같은 언어를 씁니다.
- 메뉴 오른쪽의 "한국어 | English"로 바꿉니다. 지금 보고 있는 주소에서 언어만 바꿉니다.
- 서버 검사 오류(`MemberValidator`, `EventValidator`)는 문장 대신 메시지 키를 돌려주고, JS 알림 문구는 `jsMessages.jsp`가 현재 언어로 만들어 `validation.js`에 넘깁니다.
- 날짜의 요일도 언어에 맞춰 바뀝니다 (예: (목) / (Thu)).

### 에러 페이지

| 상황 | 연결 방법 | 화면 |
|---|---|---|
| 없는 주소 | `web.xml` `<error-page>` 404 | `error404.jsp` |
| 처리 페이지(`process*.jsp`)의 예외 | page 디렉티브 `errorPage="error500.jsp"` | `error500.jsp` |
| 그 밖의 예외·500 | `web.xml` `<error-page>` 500, `java.lang.Throwable` | `error500.jsp` |

`error500.jsp`는 `isErrorPage="true"`라서 내장 객체 `exception`을 씁니다. 예외 내용은 서버 로그에 남기고, 화면에는 관리자에게만 원인(예외 종류와 메시지)을 보여 줍니다.

### 참석 신청 규칙

- **정기세미나**: 신청 없이 부원 전원(임원 포함)이 대상입니다. 출석 체크를 저장할 때 기록이 만들어지고, 기록이 없으면 미처리로 봅니다.
- **대외활동**: 참여 신청(APPLIED) 또는 미참여(DECLINED)로 응답합니다. 미참여는 결석이 아니며 출석률에도 넣지 않습니다. 관리자는 출석 체크 화면에서 미참여 응답자를 볼 수 있습니다.
- 응답 바꾸기와 취소는 행사 시작 전까지만 가능합니다. 출석 처리가 끝난 신청은 취소할 수 없습니다. 정원은 미참여 응답을 빼고 셉니다.
- 정원 확인과 저장을 하나의 트랜잭션으로 묶고 행사 행을 잠가서, 마지막 자리에 동시에 신청해도 한 명만 성공합니다.
- 출석 체크는 행사 당일 0시부터 열립니다. 상태는 미처리(APPLIED) → 출석(PRESENT) 또는 결석(ABSENT)입니다.

### 포스터 업로드 처리

1. 업로드 파일은 웹 폴더 밖의 임시 폴더(`java.io.tmpdir/clubcheck-upload`)에 **임시 이름**으로 먼저 저장합니다. 사용자가 보낸 파일 이름은 디스크에 쓰지 않습니다.
2. 파일 크기(5MB 이하)와 파일 앞부분(매직 넘버)으로 실제 JPG·PNG·GIF·WEBP 이미지인지 확인합니다.
3. 통과하면 `upload_날짜_임의값.확장자`로 이름을 바꿔 `resources/images`로 옮깁니다.
4. 포스터를 바꾸거나 행사를 지우면 예전 업로드 파일도 지웁니다. 시드 이미지(`seed_*.jpg`)는 지우지 않습니다.

업로드된 포스터(`upload_*`)는 `.gitignore`에 등록되어 저장소에 올라가지 않습니다.

### 결석사유서

- 정기세미나에 **결석**으로 처리된 회원만 새로 낼 수 있습니다 (행사 하나에 한 장, `UNIQUE(event_id, member_id)`). 해당 행사와 행사 날짜는 자동으로 채워지고, 제목·사유·증빙 이미지를 입력합니다.
- 낸 사유서는 본인이 언제든 고칠 수 있습니다. 관리자가 나중에 출석으로 바꿔도 사유서는 남고, 보기 화면에 그 사실을 알려 줍니다.
- 증빙 이미지는 포스터와 같은 방법(임시 이름 → 매직 넘버 확인 → `upload_날짜_임의값.확장자`)으로 저장하지만, 위치는 주소로 바로 열 수 없는 `WEB-INF/evidence`입니다. `evidence.jsp`가 로그인한 본인 또는 관리자인지 확인한 뒤 이미지를 바이트로 내보냅니다.
- `WEB-INF/evidence/`도 `.gitignore`에 등록되어 있습니다.

## 디렉터리 구조

```
ClubCheck
├─ sql/                      DB 스키마와 시드 데이터
├─ src/main/java
│  ├─ db.properties.example  DB 접속 정보 양식 (복사해서 db.properties로 사용)
│  ├─ bundle/                메시지 (message_ko / message_en .properties)
│  ├─ dao/                   EventDAO, MemberDAO, AttendanceDAO, AbsenceReportDAO (테이블 접근)
│  ├─ dto/                   Event, Member, Attendance, MemberSummary, AbsenceReport (자바빈)
│  └─ util/                  DB 연결, 출력 도우미, 입력 검사, 포스터 업로드, 언어
└─ src/main/webapp
   ├─ events.jsp             행사 목록 (첫 화면)
   ├─ event.jsp              행사 상세
   ├─ join.jsp, login.jsp    회원가입, 로그인 (process*.jsp 가 처리)
   ├─ logout.jsp, myPage.jsp 로그아웃, 내 정보
   ├─ loginCheck.jsp         로그인 확인 (include 용)
   ├─ adminCheck.jsp         관리자 확인 (include 용)
   ├─ message.jsp            안내 문구 (include 용)
   ├─ eventForm.jsp          행사 등록·수정 (processEvent.jsp 가 처리)
   ├─ processDeleteEvent.jsp 행사 삭제
   ├─ processApply.jsp       참여 신청 (processDecline.jsp: 미참여, processCancel.jsp: 응답 취소)
   ├─ checkAttendance.jsp    출석 체크 (processCheckAttendance.jsp 가 저장)
   ├─ members.jsp            부원 출결 현황 (행사별 / 출석률)
   ├─ absenceForm.jsp        결석사유서 작성·수정 (processAbsence.jsp 가 저장)
   ├─ absenceReport.jsp      결석사유서 보기 (evidence.jsp: 증빙 이미지)
   ├─ absenceReports.jsp     결석사유서 목록 (관리자)
   ├─ locale.jsp             언어 선택·쿠키 (include 용)
   ├─ jsMessages.jsp         JS 알림 문구 (include 용)
   ├─ errorList.jsp          검사 오류 목록 (include 용)
   ├─ error404.jsp, error500.jsp 에러 페이지
   ├─ menu.jsp, footer.jsp   공통 메뉴와 푸터
   ├─ resources/             CSS, JS(유효성 검사), 포스터 이미지
   └─ WEB-INF/               web.xml, 라이브러리, evidence/(증빙 이미지, 실행 중 생성)
```

## DB 테이블

| 테이블 | 설명 |
|---|---|
| `club_member` | 회원 (역할: ADMIN / MEMBER) |
| `club_event` | 행사 (종류 SEMINAR / ACTIVITY, 일시, 장소, 정원, 포스터 파일명) |
| `attendance` | 참석 응답과 출석 상태 (APPLIED → PRESENT / ABSENT, 대외활동 미참여는 DECLINED) |
| `absence_report` | 결석사유서 (행사, 회원, 제목, 사유, 증빙 파일명, 제출·수정 일시) |
