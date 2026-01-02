// 임시 User 모델. 실제로는 백엔드의 User 모델과 일치해야 합니다.
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}
