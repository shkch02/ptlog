
// 인증(로그인, 로그아웃 등) 관련 데이터 처리를 담당하는 리포지토리입니다.
class AuthRepository {
  AuthRepository();

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // 나중에는 실제 서버 인증 로직으로 교체
    if (email == 'test' && password == '1234') {
      return true;
    }
    return false;
  }
}
