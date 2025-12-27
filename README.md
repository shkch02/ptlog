# ptlog

개인 PT(Personal Training) 세션을 관리하고 기록하기 위한 Flutter 기반 애플리케이션입니다.

## ✨ 주요 기능

- 운동 세션 기록
- 운동 종목 관리
- 진행 상황 추적
- (추가 예정) 트레이너-회원 간 커뮤니케이션

## 📂 프로젝트 구조

프로젝트의 주요 소스 코드는 `lib` 폴더에 있으며, 다음과 같은 구조로 구성되어 있습니다.

```
lib/
├── data/         # 앱에서 사용하는 목(mock) 데이터 또는 데이터 소스
├── models/       # 데이터 모델(클래스) 정의
├── screens/      # 애플리케이션의 각 화면(UI)
├── widgets/      # 여러 화면에서 재사용되는 공통 위젯
└── main.dart     # 앱 시작점
```

## 🚀 시작하기

### 요구 사항

- [Flutter SDK](https://flutter.dev/docs/get-started/install)가 설치되어 있어야 합니다.

### 설치 및 실행

1.  **저장소를 클론합니다.**
    ```bash
    git clone <repository-url>
    ```

2.  **프로젝트 폴더로 이동합니다.**
    ```bash
    cd ptlog
    ```

3.  **필요한 패키지를 설치합니다.**
    ```bash
    flutter pub get
    ```

4.  **앱을 실행합니다.**
    ```bash
    flutter run
    ```