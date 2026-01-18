// 인증 API 응답 모델을 정의합니다.

import 'package:ptlog/models/user.dart';

class AuthResponse {
  final User user;
  final String accessToken;
  final String? refreshToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}
