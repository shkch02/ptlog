import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/providers/repository_providers.dart';
import 'layout_screen.dart'; // 로그인 성공 시 이동할 화면 import

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final authRepo = ref.read(authRepositoryProvider);
    final isSuccess = await authRepo.login('test', '1234');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (isSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LayoutScreen(
              onLogout: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: _isLoading
              ? const CircularProgressIndicator()
              : Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.fitness_center,
                              color: AppColors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '피티로그',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('회원 관리 시스템',
                            style: TextStyle(color: AppColors.textLight)),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.chat_bubble,
                                color: AppColors.textPrimary, size: 20),
                            label: const Text('카카오 로그인',
                                style: TextStyle(color: AppColors.textPrimary)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kakaoYellow,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _handleLogin,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.g_mobiledata,
                                color: AppColors.textPrimary, size: 20),
                            label: const Text('구글 로그인',
                                style: TextStyle(color: AppColors.textPrimary)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _handleLogin,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('※ 데모 버전입니다',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textLight)),
                        const Text('실제 로그인 기능은 백엔드 연동이 필요합니다',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
