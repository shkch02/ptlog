// 사용자 로그인 화면을 구성하는 위젯입니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/providers/auth_providers.dart';
import 'layout_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (_isSignUpMode && (value == null || value.isEmpty)) {
      return '이름을 입력해주세요.';
    }
    return null;
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authStateProvider.notifier);

    if (_isSignUpMode) {
      notifier.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    } else {
      notifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _handleSocialLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('준비 중입니다. 이메일 로그인을 이용해주세요.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LayoutScreen(
          onLogout: () {
            ref.read(authStateProvider.notifier).logout();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        _navigateToHome();
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.danger,
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryLight, AppColors.accentLight],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: AppColors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '피티로그',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '회원 관리 시스템',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                      const SizedBox(height: 32),

                      // Name Field (Sign Up only)
                      if (_isSignUpMode) ...[
                        TextFormField(
                          controller: _nameController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            labelText: '이름',
                            hintText: '홍길동',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          hintText: 'example@email.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          hintText: '6자 이상 입력',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        onFieldSubmitted: (_) => _handleSubmit(),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : Text(
                                  _isSignUpMode ? '회원가입' : '로그인',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Toggle Sign In / Sign Up
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isSignUpMode = !_isSignUpMode;
                                  _formKey.currentState?.reset();
                                });
                              },
                        child: Text(
                          _isSignUpMode
                              ? '이미 계정이 있으신가요? 로그인'
                              : '계정이 없으신가요? 회원가입',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.disabled)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '또는',
                              style: TextStyle(color: AppColors.textLight),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.disabled)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Social Login Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.chat_bubble,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          label: const Text(
                            '카카오 로그인',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kakaoYellow,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isLoading ? null : _handleSocialLogin,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.g_mobiledata,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          label: const Text(
                            '구글 로그인',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.disabled),
                            ),
                          ),
                          onPressed: isLoading ? null : _handleSocialLogin,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        '소셜 로그인은 준비 중입니다',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
