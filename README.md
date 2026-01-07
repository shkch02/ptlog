# PTLog - 피트니스 트레이너를 위한 회원 관리 앱

PTLog는 피트니스 트레이너가 회원을 효율적으로 관리하고, 수업 스케줄을 계획하며, 운동 일지를 기록할 수 있도록 돕는 모바일 애플리케이션입니다.

## 주요 기능

-   **회원 관리**: 신규 회원 등록, 정보 수정, 검색 및 보관/삭제 기능을 제공합니다.
-   **스케줄 관리**: 트레이너별/일자별/주간별 수업 스케줄을 한눈에 파악하고 관리할 수 있습니다.
-   **수업 및 운동 일지**: 수업별 운동 내용, 세트, 피드백 등을 상세히 기록하고 조회할 수 있습니다.
-   **대시보드**: 오늘 예정된 수업, 만료 임박 회원 등 주요 정보를 빠르게 확인할 수 있습니다.

## 기술 스택

-   **프레임워크**: Flutter
-   **상태 관리**: Riverpod
-   **UI**: Material Design 3
-   **아이콘**: Lucide Icons

---

## 벡엔드 구현 가이드

이 문서는 프론트엔드 코드 분석을 통해 백엔드 API를 설계하고 구현하는 데 필요한 정보를 제공합니다.

### 1. 데이터 모델 구조

애플리케이션에서 사용하는 핵심 데이터 모델은 다음과 같습니다. JSON 직렬화/역직렬화를 위한 `toJson`/`fromJson` 메서드가 각 모델에 포함되어 있습니다.

#### `Member`

회원의 기본 정보 및 신체 정보를 관리합니다.

-   `id`: `String` (PK)
-   `name`: `String`
-   `phone`: `String`
-   `email`: `String`
-   `remainingSessions`: `int` (남은 세션 횟수)
-   `totalSessions`: `int` (총 등록 횟수)
-   `registrationDate`: `DateTime`
-   `notes`: `String` (특이사항, 메모)
-   `profileImage`: `String?` (프로필 이미지 URL)
-   `isArchived`: `bool` (보관(비활성) 여부, 기본값 `false`)
-   **신체 정보 (nullable)**:
    -   `height`: `double?`
    -   `weight`: `double?`
    -   `targetWeight`: `double?`
    -   `age`: `int?`
    -   `bodyFat`: `double?`
    -   `skeletalMuscle`: `double?`
    -   `targetMuscle`: `double?`
    -   `activityLevel`: `String?`
    -   `sleepTime`: `String?`

#### `TrainerMemberRelation`

트레이너와 회원 간의 '계약' 또는 '소속' 관계를 정의합니다. 한 명의 회원은 여러 트레이너와 관계를 맺을 수 있습니다.

-   `id`: `String` (PK)
-   `trainerId`: `String` (FK, User/Trainer 모델 참조)
-   `memberId`: `String` (FK, Member 모델 참조)
-   `startDate`: `DateTime` (관계 시작일)
-   `endDate`: `DateTime?` (관계 종료일)
-   `isActive`: `bool` (현재 유효한 관계인지 여부)
-   `memberName`: `String?` (JOIN된 데이터, 편의용)
-   `trainerName`: `String?` (JOIN된 데이터, 편의용)

#### `Schedule`

수업 스케줄 정보를 관리합니다. 특정 `TrainerMemberRelation`에 종속됩니다.

-   `id`: `String` (PK)
-   `relationId`: `String` (FK, TrainerMemberRelation 모델 참조)
-   `memberId`: `String?` (JOIN된 데이터, 편의용)
-   `memberName`: `String?` (JOIN된 데이터, 편의용)
-   `date`: `DateTime` (수업 날짜)
-   `startTime`: `String` (예: "09:00")
-   `endTime`: `String` (예: "09:50")
-   `notes`: `String` (수업 관련 메모)
-   `reminder`: `String` (알림 설정)

#### `WorkoutLog`

수업 완료 후 작성하는 운동 일지입니다.

-   `id`: `String` (PK)
-   `memberId`: `String` (FK, Member 모델 참조)
-   `memberName`: `String`
-   `date`: `DateTime`
-   `sessionNumber`: `int` (몇 회차 수업인지)
-   `exercises`: `List<WorkoutExercise>` (운동 목록)
-   `overallNotes`: `String` (총평, 피드백)
-   `reminderForNext`: `String` (다음 수업을 위한 메모)
-   `photos`: `List<String>` (사진 URL 목록)

#### `WorkoutExercise` / `WorkoutSet`

`WorkoutLog`에 포함되는 상세 운동 및 세트 정보입니다.

-   **WorkoutExercise**: `id`, `name`, `sets: List<WorkoutSet>`, `notes`
-   **WorkoutSet**: `setNumber`, `reps`, `weight`

### 2. Repository API (엔드포인트 설계 참고)

프론트엔드의 Repository 클래스들은 백엔드 API 엔드포인트와 1:1로 매칭될 수 있습니다.

#### `AuthRepository`

-   `login(email, password)`: `POST /api/auth/login`
    -   로그인 성공 시 사용자 정보 및 토큰 반환.

#### `RelationRepository`

-   `getActiveRelationsForTrainer(trainerId)`: `GET /api/trainers/{trainerId}/relations?active=true`
    -   특정 트레이너에게 소속된 모든 활성 계약 목록을 반환합니다.
-   `createRelation(trainerId, memberId)`: `POST /api/relations`
    -   Body: `{ "trainerId": "...", "memberId": "..." }`
    -   새로운 트레이너-회원 관계를 생성합니다.
-   `deactivateRelation(relationId)`: `PATCH /api/relations/{relationId}/deactivate`
    -   특정 관계를 비활성화(계약 종료) 처리합니다.

#### `MemberRepository`

-   `getMembersForTrainer(trainerId)`: `GET /api/trainers/{trainerId}/members`
    -   `RelationRepository`를 통해 해당 트레이ナー와 연결된 활성 회원 목록을 조회합니다.
-   `getArchivedMembersForTrainer(trainerId)`: `GET /api/trainers/{trainerId}/members?archived=true`
    -   보관된 회원 목록을 조회합니다.
-   `getRenewalNeededMembersForTrainer(trainerId)`: `GET /api/trainers/{trainerId}/members?renewal=true`
    -   남은 세션 횟수가 적은(예: 3회 이하) 회원 목록을 반환합니다.
-   `addMember(member)`: `POST /api/members`
    -   신규 회원을 시스템에 등록합니다.
-   `updateMemberNotes(memberId, newNotes)`: `PATCH /api/members/{memberId}/notes`
    -   Body: `{ "notes": "..." }`
-   `archiveMember(memberId)`: `PATCH /api/members/{memberId}/archive`
    -   회원을 보관 상태로 변경합니다.
-   `unarchiveMember(memberId)`: `PATCH /api/members/{memberId}/unarchive`
    -   회원을 다시 활성 상태로 복원합니다.
-   `deleteMember(memberId)`: `DELETE /api/members/{memberId}`
    -   회원 정보를 영구 삭제합니다.

#### `ScheduleRepository`

-   `getSchedulesForTrainerByDate(trainerId, dateStr)`: `GET /api/trainers/{trainerId}/schedules?date={dateStr}`
    -   특정 트레이너의 특정 날짜 스케줄 목록을 반환합니다.
-   `getUpcomingSchedulesForTrainer(trainerId)`: `GET /api/trainers/{trainerId}/schedules/upcoming`
    -   오늘 예정된 수업 중 가장 가까운 수업 1개를 반환합니다.
-   `getSchedulesByMember(memberId)`: `GET /api/members/{memberId}/schedules`
    -   특정 회원의 전체 수업 이력을 반환합니다.
-   `checkConflictForTrainer(...)`: `GET /api/trainers/{trainerId}/schedules/check-conflict?date=...&startTime=...&endTime=...`
    -   새로운 스케줄 등록 시 중복 여부를 확인합니다.
-   `addSchedule(schedule)`: `POST /api/schedules`
    -   새로운 수업 스케줄을 추가합니다.

#### `WorkoutLogRepository`

-   `getLogBySchedule(memberId, date)`: `GET /api/logs?memberId={memberId}&date={date}`
    -   특정 회원의 특정 날짜 운동 일지를 조회합니다.

## 프로젝트 실행 방법

1.  Flutter SDK 설치
2.  `pubspec.yaml` 파일이 있는 프로젝트 루트에서 다음 명령어 실행:
    ```bash
    flutter pub get
    ```
3.  연결된 디바이스 또는 에뮬레이터에서 앱 실행:
    ```bash
    flutter run
    ```

---
*이 문서는 Gemini에 의해 자동으로 생성되었습니다.*