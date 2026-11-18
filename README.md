# ClubCheck — 동아리 행사·출석 관리

JSP 기초 기술만으로 만든 동아리 행사 등록·참석 신청·출석 관리 웹 애플리케이션입니다.

> 현재 구현 단계: **P2 (행사 등록·수정·삭제, 포스터 업로드)**
>
> - P0: DB 스키마, 공통 뼈대, 행사 목록·상세 조회
> - P1: 회원 기능 (가입, 로그인, 세션, 아이디 저장 쿠키)
> - P2: 행사 관리 (관리자 전용, cos 로 포스터 업로드)

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

### 포스터 업로드 처리

1. 업로드 파일은 웹 폴더 밖의 임시 폴더(`java.io.tmpdir/clubcheck-upload`)에 **임시 이름**으로 먼저 저장합니다. 사용자가 보낸 파일 이름은 디스크에 쓰지 않습니다.
2. 파일 크기(5MB 이하)와 파일 앞부분(매직 넘버)으로 실제 JPG·PNG·GIF·WEBP 이미지인지 확인합니다.
3. 통과하면 `upload_날짜_임의값.확장자`로 이름을 바꿔 `resources/images`로 옮깁니다.
4. 포스터를 바꾸거나 행사를 지우면 예전 업로드 파일도 지웁니다. 시드 이미지(`seed_*.jpg`)는 지우지 않습니다.

업로드된 포스터(`upload_*`)는 `.gitignore`에 등록되어 저장소에 올라가지 않습니다.

## 디렉터리 구조

```
ClubCheck
├─ sql/                      DB 스키마와 시드 데이터
├─ src/main/java
│  ├─ db.properties.example  DB 접속 정보 양식 (복사해서 db.properties로 사용)
│  ├─ dao/                   EventDAO, MemberDAO (테이블 접근)
│  ├─ dto/                   Event, Member (자바빈)
│  └─ util/                  DB 연결, 출력 도우미, 입력 검사, 포스터 업로드
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
   ├─ menu.jsp, footer.jsp   공통 메뉴와 푸터
   ├─ resources/             CSS, JS(유효성 검사), 포스터 이미지
   └─ WEB-INF/               web.xml, 라이브러리
```

## DB 테이블

| 테이블 | 설명 |
|---|---|
| `club_member` | 회원 (역할: ADMIN / MEMBER) |
| `club_event` | 행사 (일시, 장소, 정원, 포스터 파일명) |
| `attendance` | 참석 신청과 출석 상태 (APPLIED → PRESENT / ABSENT) |
