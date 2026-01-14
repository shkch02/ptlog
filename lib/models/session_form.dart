// 운동일지 작성 화면에서 사용하는 임시 폼 데이터 모델을 정의합니다.
// lib/models/session_form.dart

class ExerciseForm {
  String name = '';
  String targetPart = '';
  List<SetForm> sets = [SetForm()];
}

class SetForm {
  String weight = '';
  String reps = '';
  String rest = '';
}