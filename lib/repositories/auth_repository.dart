class AuthRepository {
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // 나중에는 실제 서버 인증 로직으로 교체
    if (email == 'test' && password == '1234') {
      return true;
    }
    return false;
  }
}