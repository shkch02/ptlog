// 인증(로그인, 로그아웃 등) 관련 데이터 처리를 담당하는 리포지토리입니다.

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ptlog/models/auth_response.dart';
import 'package:ptlog/models/user.dart';

class AuthRepository {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  final FlutterSecureStorage _secureStorage;
  final http.Client _httpClient;
  final String _baseUrl;

  AuthRepository({
    FlutterSecureStorage? secureStorage,
    http.Client? httpClient,
    String? baseUrl,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? _getBaseUrl();

  /// 환경 변수에서 API 기본 URL을 가져옵니다.
  static String _getBaseUrl() {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw StateError(
        'API_BASE_URL is not configured. '
        'Please set API_BASE_URL in your .env file.',
      );
    }
    return url;
  }

  /// 이메일/비밀번호로 로그인합니다.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _handleAuthResponse(response);
    } on http.ClientException catch (e) {
      throw AuthException('네트워크 오류가 발생했습니다: ${e.message}', code: 'NETWORK_ERROR');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('알 수 없는 오류가 발생했습니다.', code: 'UNKNOWN_ERROR');
    }
  }

  /// 이메일/비밀번호로 회원가입합니다.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register');

    try {
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        }),
      );

      return _handleAuthResponse(response);
    } on http.ClientException catch (e) {
      throw AuthException('네트워크 오류가 발생했습니다: ${e.message}', code: 'NETWORK_ERROR');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('알 수 없는 오류가 발생했습니다.', code: 'UNKNOWN_ERROR');
    }
  }

  /// API 응답을 처리하고 토큰을 저장합니다.
  Future<AuthResponse> _handleAuthResponse(http.Response response) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final authResponse = AuthResponse.fromJson(body);

      // 토큰과 사용자 정보를 안전하게 저장
      await _saveTokens(authResponse);

      return authResponse;
    }

    // 에러 응답 처리
    final message = body['message'] as String? ?? '인증에 실패했습니다.';
    final code = body['code'] as String?;

    switch (response.statusCode) {
      case 400:
        throw AuthException(message, code: code ?? 'BAD_REQUEST');
      case 401:
        throw AuthException(message.isNotEmpty ? message : '이메일 또는 비밀번호가 올바르지 않습니다.',
            code: code ?? 'UNAUTHORIZED');
      case 409:
        throw AuthException(message.isNotEmpty ? message : '이미 존재하는 이메일입니다.',
            code: code ?? 'CONFLICT');
      case 422:
        throw AuthException(message, code: code ?? 'VALIDATION_ERROR');
      default:
        throw AuthException('서버 오류가 발생했습니다.', code: 'SERVER_ERROR');
    }
  }

  /// 토큰과 사용자 정보를 안전하게 저장합니다.
  Future<void> _saveTokens(AuthResponse authResponse) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: authResponse.accessToken,
    );

    if (authResponse.refreshToken != null) {
      await _secureStorage.write(
        key: _refreshTokenKey,
        value: authResponse.refreshToken,
      );
    }

    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(authResponse.user.toJson()),
    );
  }

  /// 저장된 액세스 토큰을 가져옵니다.
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// 저장된 사용자 정보를 가져옵니다.
  Future<User?> getCurrentUser() async {
    final userData = await _secureStorage.read(key: _userKey);
    if (userData == null) return null;

    try {
      final json = jsonDecode(userData) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// 로그인 상태를 확인합니다.
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 로그아웃합니다.
  Future<void> logout() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  /// [Deprecated] 기존 로그인 메서드 - 하위 호환성을 위해 유지
  @Deprecated('Use signIn instead')
  Future<bool> login(String email, String password) async {
    try {
      await signIn(email: email, password: password);
      return true;
    } catch (_) {
      return false;
    }
  }
}
