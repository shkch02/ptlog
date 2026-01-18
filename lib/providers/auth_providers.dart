// 인증 관련 상태(로그인 여부 등)를 관리하는 프로바이더를 정의합니다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/models/auth_response.dart';
import 'package:ptlog/models/user.dart';
import 'package:ptlog/providers/repository_providers.dart';

/// 인증 상태를 나타내는 sealed class
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final String? code;
  const AuthError(this.message, {this.code});
}

/// 인증 상태를 관리하는 StateNotifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthStateNotifier(this._ref) : super(const AuthInitial());

  /// 앱 시작 시 저장된 인증 정보 확인
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final isLoggedIn = await authRepo.isLoggedIn();

      if (isLoggedIn) {
        final user = await authRepo.getCurrentUser();
        if (user != null) {
          state = AuthAuthenticated(user);
          return;
        }
      }

      state = const AuthUnauthenticated();
    } catch (e) {
      state = const AuthUnauthenticated();
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final response = await authRepo.signIn(email: email, password: password);
      state = AuthAuthenticated(response.user);
    } on AuthException catch (e) {
      state = AuthError(e.message, code: e.code);
    } catch (e) {
      state = const AuthError('로그인 중 오류가 발생했습니다.');
    }
  }

  /// 이메일/비밀번호로 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AuthLoading();

    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final response = await authRepo.signUp(
        email: email,
        password: password,
        name: name,
      );
      state = AuthAuthenticated(response.user);
    } on AuthException catch (e) {
      state = AuthError(e.message, code: e.code);
    } catch (e) {
      state = const AuthError('회원가입 중 오류가 발생했습니다.');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      await authRepo.logout();
    } finally {
      state = const AuthUnauthenticated();
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }

  /// [Deprecated] 기존 login 메서드 - 하위 호환성을 위해 유지
  @Deprecated('Use signIn instead')
  void login(User user) {
    state = AuthAuthenticated(user);
  }
}

/// 인증 상태 프로바이더
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref);
});

/// 현재 사용자 프로바이더 (편의 제공)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});

/// 로그인 여부 프로바이더 (편의 제공)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState is AuthAuthenticated;
});
