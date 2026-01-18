// 운동일지 작성 화면에서 사용하는 임시 폼 데이터 모델을 정의합니다.
// lib/models/session_form.dart

/// 세트 입력 모드
enum SetInputMode { digital, handwriting }

class ExerciseForm {
  String name = '';
  String targetPart = '';
  List<SetForm> sets = [SetForm()];
  List<String> photos = [];

  /// 세트 입력 모드 기본값 (디지털 입력 또는 필기 입력)
  SetInputMode setInputMode = SetInputMode.handwriting;

  /// 필기 모드 사용 시 저장된 이미지 경로
  String? handwritingImagePath;
}

class SetForm {
  String weight = '';
  String reps = '';
  String rest = '';
}
