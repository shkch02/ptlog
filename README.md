# PTLog - 피트니스 트레이너를 위한 회원 관리 앱

PTLog는 피트니스 트레이너가 회원을 효율적으로 관리하고, 수업 스케줄을 계획하며, 운동 일지를 기록할 수 있도록 돕는 크로스 플랫폼 애플리케이션입니다. Flutter와 Riverpod를 기반으로 구축되어 반응형 UI와 확장 가능한 아키텍처를 제공합니다.

## 주요 기능 (현재 구현 기준)

-   **대시보드 (`HomeScreen`):**
    -   오늘 예정된 수업 목록을 시간순으로 표시합니다.
    -   예약된 수업이 없을 경우, 수동으로 세션을 시작할 수 있는 UI를 제공합니다.
    -   각 수업 카드를 통해 회원 상세 정보 조회 또는 운동 일지 작성을 시작할 수 있습니다.

-   **회원 관리 (`MemberListScreen`):**
    -   트레이너에게 등록된 모든 활성 회원을 목록 형태로 보여줍니다.
    -   이름, 전화번호로 회원을 실시간 검색할 수 있습니다.
    -   **신규 회원 등록:** 다이얼로그를 통해 새 회원의 기본 정보를 추가하고, 현재 트레이너와 자동으로 연결합니다.
    -   **회원 상세 정보:** 탭(Tab) 기반 UI로 회원의 PT 세션 이력, 기본 정보, 상세 메모, 설정을 관리합니다.
        -   **PT 세션:** 과거 및 예정된 모든 수업 이력을 조회하고, 지난 수업의 운동 기록을 확인할 수 있습니다.
        -   **기본 정보:** 인적사항과 키, 체중 등 상세한 신체 정보를 조회하고 수정합니다.
        -   **상세 메모:** 회원 관련 특이사항 (부상 이력, 목표 등)을 자유롭게 기록하고 저장합니다.
        -   **설정:** 회원을 '보관' 상태로 변경하거나 시스템에서 영구 '삭제'할 수 있습니다.
    -   **보관된 회원 관리:** 별도 다이얼로그에서 보관된 회원 목록을 확인하고 다시 '복원'할 수 있습니다.

-   **스케줄 관리 (`ScheduleViewScreen`):**
    -   주간(Weekly) 타임테이블 형식으로 트레이너의 모든 스케줄을 시각적으로 보여줍니다.
    -   상단의 월간 캘린더를 통해 특정 날짜가 포함된 주로 빠르게 이동할 수 있습니다.
    -   시간표의 빈 슬롯을 탭하여 새 세션을 추가하거나, 기존 세션을 탭하여 정보를 수정/삭제할 수 있습니다. (UI 구현 완료, 기능 연동 필요)

-   **운동 일지 작성 (`SessionLogScreen`):**
    -   수업 정보를 바탕으로 운동 일지를 작성합니다.
    -   **디지털 입력:** 운동 종목, 부위, 세트(무게, 횟수, 휴식)를 키보드로 직접 입력합니다.
    -   **필기 입력:** 템플릿 이미지 위에서 손글씨로 자유롭게 기록할 수 있습니다. (웹: Base64, 모바일: 파일로 저장)
    -   운동별로 사진을 첨부할 수 있습니다. (UI 구현 완료, 기능 연동 필요)
    -   수업에 대한 총평(피드백)과 다음 세션을 위한 메모를 남길 수 있습니다.

## 기술 스택

-   **프레임워크**: Flutter (Dart)
-   **상태 관리**: Flutter Riverpod
-   **아키텍처**: Repository Pattern, Service Layer
-   **UI**: Material Design 3
-   **주요 라이브러리**:
    -   `table_calendar`: 월간/주간 캘린더 UI
    -   `flutter_painter_v2`: 필기 입력 기능
    -   `lucide_icons`: 아이콘 시스템
    -   `intl`: 날짜 및 시간 포맷팅 (한국어 지원)

## 백엔드 구현 가이드 (API 설계 제안)

이 프로젝트는 현재 Mock 데이터를 사용하고 있습니다. 실제 백엔드 연동을 위해 다음과 같은 데이터 모델과 API 엔드포인트를 설계할 수 있습니다.

### 1. 데이터 모델 구조

-   **`Member`**: 회원의 고유 정보 (이름, 연락처, 신체 정보 등)
-   **`User`**: 사용자(트레이너) 정보
-   **`TrainerMemberRelation`**: 트레이너와 회원 간의 '계약' 관계를 정의하는 중간 테이블. 한 명의 회원은 여러 트레이너와 관계를 맺을 수 있습니다.
-   **`Schedule`**: 특정 `TrainerMemberRelation`에 종속되는 수업 스케줄.
-   **`WorkoutLog`**: 완료된 `Schedule`에 대한 상세 운동 기록.
-   **`PaymentLog`**: `TrainerMemberRelation`에 대한 결제 이력.

### 2. Repository 기반 API 엔드포인트 설계

프론트엔드의 Repository 클래스는 백엔드 API와 1:1로 매칭될 수 있습니다.

-   **`AuthRepository`**
    -   `login(email, password)` → `POST /api/auth/login`
-   **`RelationRepository`**
    -   `getActiveRelationsForTrainer(trainerId)` → `GET /api/trainers/{trainerId}/relations?active=true`
    -   `createRelation(trainerId, memberId)` → `POST /api/relations`
-   **`MemberRepository`**
    -   `getMembersForTrainer(trainerId)` → `GET /api/trainers/{trainerId}/members`
    -   `addMember(member)` → `POST /api/members`
    -   `archiveMember(memberId)` → `PATCH /api/members/{memberId}/archive`
-   **`ScheduleRepository`**
    -   `getSchedulesForTrainerByDate(trainerId, date)` → `GET /api/trainers/{trainerId}/schedules?date={date}`
    -   `addSchedule(schedule)` → `POST /api/schedules`
-   **`WorkoutLogRepository`**
    -   `getLogBySchedule(memberId, date)` → `GET /api/logs?memberId={memberId}&date={date}`
    -   `createLog(log)` → `POST /api/logs`

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── constants/                # 앱 전역 상수 (색상, 스타일, 문자열 등)
├── data/
│   └── mock_data.dart        # 현재 사용 중인 목업 데이터
├── models/                   # 데이터 모델 (Member, Schedule 등)
├── providers/                # Riverpod 프로바이더 (상태 관리)
├── repositories/             # 데이터 접근 레이어 (API 통신 추상화)
├── screens/                  # 주요 화면 (로그인, 홈, 회원 목록 등)
├── services/                 # 비즈니스 로직 서비스 (HandwritingService 등)
└── widgets/                  # 재사용 가능한 UI 컴포넌트
    ├── member_detail_tabs/   # 회원 상세 정보의 탭 위젯
    └── session_log/          # 세션 로그 관련 위젯
```

## 실행 방법

1.  **Flutter SDK 설치**
2.  **의존성 설치:**
    ```bash
    flutter pub get
    ```
3.  **앱 실행:**
    ```bash
    flutter run
    ```
    또는 VS Code, Android Studio에서 `F5` 키를 눌러 디버그 모드로 실행할 수 있습니다.
