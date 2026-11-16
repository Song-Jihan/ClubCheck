# ClubCheck — 동아리 행사·출석 관리

JSP 기초 기술만으로 만든 동아리 행사 등록·참석 신청·출석 관리 웹 애플리케이션입니다.

> 현재 구현 단계: **1단계 (DB 스키마, 공통 뼈대, 행사 목록·상세 조회)**

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
   `mysql-connector-j-8.x.x.jar`를 `src/main/webapp/WEB-INF/lib/`에 복사합니다.
   (이 jar는 저장소에 포함되어 있지 않습니다.)

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

회원 이름과 학번은 모두 가상의 값입니다. (로그인 기능은 2단계에서 추가됩니다.)

## 디렉터리 구조

```
ClubCheck
├─ sql/                      DB 스키마와 시드 데이터
├─ src/main/java
│  ├─ db.properties.example  DB 접속 정보 양식 (복사해서 db.properties로 사용)
│  ├─ dao/EventDAO.java      행사 테이블 조회
│  ├─ dto/Event.java         행사 자바빈
│  └─ util/                  DB 연결, 출력 도우미
└─ src/main/webapp
   ├─ events.jsp             행사 목록 (첫 화면)
   ├─ event.jsp              행사 상세
   ├─ menu.jsp, footer.jsp   공통 메뉴와 푸터
   ├─ resources/             CSS, 포스터 이미지
   └─ WEB-INF/               web.xml, 라이브러리
```

## DB 테이블

| 테이블 | 설명 |
|---|---|
| `club_member` | 회원 (역할: ADMIN / MEMBER) |
| `club_event` | 행사 (일시, 장소, 정원, 포스터 파일명) |
| `attendance` | 참석 신청과 출석 상태 (APPLIED → PRESENT / ABSENT) |
