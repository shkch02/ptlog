# PT-Log: 피티로그 (PT 회원 관리 솔루션)

`PT-Log`는 퍼스널 트레이너를 위한 모바일 회원 관리 애플리케이션입니다. 흩어져 있는 회원 정보, 스케줄, 운동 일지를 하나의 앱에서 체계적으로 관리하여 트레이너가 수업에만 집중할 수 있도록 돕습니다.

## 1. 주요 기능

-   **대시보드 (홈 화면)**: 오늘 예정된 수업, 재등록이 필요한 회원을 한눈에 파악합니다.
-   **회원 관리**: 전체 회원 목록을 검색하고, 신규 회원을 등록하며, 각 회원의 상세 정보(기본 정보, PT 세션 내역, 상세 메모, 결제 내역)를 관리합니다.
-   **스케줄 관리**: 일별/주별/월별 스케줄을 확인하고, 새로운 PT 세션을 예약합니다.
-   **운동 일지 작성 및 조회**: PT 세션이 끝난 후, 운동 내역과 피드백을 기록하고 과거의 운동 기록을 조회할 수 있습니다.

## 2. 기술 스택 및 주요 라이브러리

-   **Framework**: `Flutter 3.x`
-   **State Management**: `Riverpod`
-   **UI & Components**:
    -   `lucide_icons`: 깔끔하고 일관된 아이콘 세트
    -   `table_calendar`: 월간/주간 캘린더 UI
-   **Utilities**:
    -   `intl`: 날짜 및 시간 포맷팅

## 3. 프로젝트 구조

프로젝트는 기능과 역할에 따라 명확하게 분리된 디렉토리 구조를 가집니다. 이는 유지보수성과 확장성을 높이기 위함입니다.

```
/lib
├── constants/      # 앱 전역에서 사용되는 상수 (색상, 텍스트 스타일 등)
├── data/           # 임시 데이터 (Mock Data)
├── models/         # 데이터 모델 클래스 (Member, Schedule 등)
├── providers/      # Riverpod Provider 정의
├── repositories/   # 데이터 소스 제어 (API 통신, DB 접근 등)
├── screens/        # 전체 화면 단위의 UI 위젯
└── widgets/        # 재사용 가능한 작은 UI 컴포넌트
```

-   **`/constants`**: 색상(`app_colors.dart`), 텍스트 스타일(`app_text_styles.dart`), 문자열(`app_strings.dart`) 등 하드코딩을 피하기 위한 값들을 모아둡니다. UI를 수정할 때 일관성을 유지하기 위해 이곳의 값을 사용해야 합니다.

-   **`/data`**: 현재 백엔드 없이 앱을 구동하기 위한 임시 데이터(`mock_data.dart`)가 들어있습니다. 향후 실제 백엔드가 구현되면 이 부분은 제거되거나 테스트용으로만 사용됩니다.

-   **`/models`**: 애플리케이션의 핵심 데이터 구조를 정의합니다. 모든 모델 클래스는 불변성(Immutability)을 유지하기 위해 `copyWith` 메서드를 포함하며, 서버 통신을 대비해 `toJson`, `fromJson` 메서드를 구현해두었습니다.

-   **`/repositories`**: 데이터 소스와의 통신을 담당하는 **데이터 계층**입니다. UI는 Repository가 어디서 데이터를 가져오는지(Mock Data인지, API 서버인지) 알 필요가 없습니다. 데이터 관련 로직은 모두 이곳에서 처리합니다.

-   **`/providers`**: **Riverpod 상태 관리의 핵심**입니다. UI와 비즈니스 로직(데이터)을 분리하는 역할을 합니다.
    -   `repository_providers.dart`: Repository 인스턴스를 생성하고 앱 전역에 제공합니다.
    -   `home_providers.dart`, `schedule_providers.dart`: Repository로부터 데이터를 가져와 가공한 후, UI가 사용할 최종 상태(State)를 제공합니다. `FutureProvider`, `StateNotifierProvider` 등이 사용됩니다.

-   **`/screens`**: 사용자에게 보여지는 전체 페이지 단위의 UI입니다. 각 스크린은 `ConsumerWidget` 또는 `ConsumerStatefulWidget`으로 작성되어 `ref.watch`를 통해 Provider가 제공하는 데이터를 구독하고, 데이터가 변경되면 자동으로 UI를 갱신합니다.

-   **`/widgets`**: 여러 화면에서 재사용될 수 있는 작은 UI 조각들입니다. 다이얼로그, 카드, 버튼 등이 포함됩니다. 복잡한 위젯은 하위 디렉토리(예: `member_detail_tabs/`)로 한번 더 그룹화하여 관리합니다.

## 4. 아키텍처 및 데이터 흐름 (Riverpod)

이 앱은 Riverpod를 사용한 단방향 데이터 흐름 아키텍처를 따릅니다. 이를 이해하는 것이 유지보수의 핵심입니다.

**`UI` → `Provider` → `Repository` → `Data Source` → (State Update) → `UI`**

1.  **UI (Screen/Widget)**: 사용자가 버튼을 클릭하는 등 이벤트를 발생시킵니다.
2.  **Provider 호출**: UI는 `ref.read()`나 `ref.watch()`를 통해 Provider에 접근하고, Repository의 메서드를 호출하도록 요청합니다.
    -   *예시: `ref.read(memberRepositoryProvider).addMember(newMember);`*
3.  **Repository**: 요청을 받아 데이터 소스(현재는 `mock_data.dart`)의 데이터를 변경(추가, 수정, 삭제)합니다.
4.  **상태 무효화 (Invalidation)**: 데이터 변경 후, Repository는 이 데이터와 관련된 Provider를 무효화(`ref.invalidate()`)하여 상태가 변경되었음을 Riverpod에 알립니다.
    -   *예시: `ref.invalidate(allMembersProvider);`*
5.  **UI 자동 갱신**: Riverpod는 무효화된 Provider를 재실행하여 새로운 데이터를 가져옵니다. 해당 Provider를 `ref.watch`하고 있던 모든 UI는 **자동으로 리빌드**되어 최신 데이터를 화면에 표시합니다.

이 구조 덕분에 UI는 상태를 직접 관리할 필요가 없으며, 데이터 로직은 Repository에 캡슐화되어 코드가 명확하고 테스트하기 쉬워집니다.

## 5. 시작 가이드

1.  **Flutter SDK 설치**: Flutter 개발 환경이 설정되어 있어야 합니다.
2.  **저장소 클론**: `git clone <repository-url>`
3.  **패키지 설치**: 프로젝트 루트 디렉토리에서 아래 명령어를 실행합니다.
    ```bash
    flutter pub get
    ```
4.  **앱 실행**: 연결된 디바이스나 에뮬레이터에서 앱을 실행합니다.
    ```bash
    flutter run
    ```
    -   **데모 계정**: 로그인 화면에서 아무 버튼이나 누르면 `test`/`1234` 계정으로 로그인됩니다.

## 6. 향후 유지보수 가이드

-   **새로운 기능(화면) 추가 시**:
    1.  `/screens`에 새로운 화면 파일을 생성합니다.
    2.  필요한 데이터가 있다면, `/repositories`에 데이터 로직을 추가하고 `/providers`에 새 Provider를 만듭니다.
    3.  새로운 화면에서 `ref.watch`를 통해 Provider의 데이터를 사용합니다.

-   **UI 컴포넌트 수정 시**:
    -   전체 페이지라면 `/screens`에서 해당 파일을 찾습니다.
    -   재사용되는 작은 부분이라면 `/widgets`에서 관련 파일을 찾습니다.

-   **데이터 로직 변경 시**:
    -   데이터를 가져오거나 변경하는 로직은 `/repositories` 디렉토리의 파일들을 수정하면 됩니다.

-   **백엔드 API 연동 방법**:
    1.  `http` 또는 `dio` 패키지를 `pubspec.yaml`에 추가합니다.
    2.  `/repositories` 디렉토리의 각 Repository 메서드 내부를 수정합니다.
    3.  `Future.delayed`와 `mockMembers`를 사용하던 부분을 실제 API를 호출하는 코드로 교체합니다.
    4.  **중요**: Repository 내부만 수정하면, Provider나 UI 코드는 거의 변경할 필요 없이 실제 서버 데이터와 연동됩니다. 이것이 현재 아키텍처의 가장 큰 장점입니다.
