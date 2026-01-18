// 사용자(트레이너) 정보를 관리하는 User 데이터 모델을 정의합니다.
// 임시 User 모델. 실제로는 백엔드의 User 모델과 일치해야 합니다.
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}
