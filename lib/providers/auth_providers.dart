// 인증 관련 상태(로그인 여부 등)를 관리하는 프로바이더를 정의합니다.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/models/user.dart';

class AuthStateNotifier extends StateNotifier<User?> {
  AuthStateNotifier() : super(null);

  void login(User user) {
    state = user;
  }

  void logout() {
    state = null;
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, User?>((ref) {
  return AuthStateNotifier();
});