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