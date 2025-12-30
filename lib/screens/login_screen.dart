import 'package:flutter/material.dart';
import 'package:ptlog/constants/app_colors.dart';
import '../repositories/auth_repository.dart';
import 'layout_screen.dart'; // 로그인 성공 시 이동할 화면 import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. 리포지토리 인스턴스 생성 (이제 여기서 직접 씁니다!)
  final AuthRepository _authRepo = AuthRepository();
  
  // 2. 로딩 상태 관리 변수
  bool _isLoading = false;

  // 3. 로그인 처리 함수
  void _handleLogin() async {
    // 로딩 시작 (화면 갱신)
    setState(() {
      _isLoading = true;
    });

    // 실제 로그인 요청 (지금은 더미지만 나중에 진짜 서버 통신됨)
    // 소셜 로그인 버튼이므로 ID/PW는 임시값 혹은 토큰 방식 사용 예정
    final isSuccess = await _authRepo.login('test', '1234'); 

    // 화면이 살아있는지 확인 후 로딩 종료
    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (isSuccess) {
        // 4. 성공 시 화면 이동 (Main -> LayoutScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LayoutScreen(
            // 로그아웃 시 다시 로그인 화면으로 이동하는 로직을 전달합니다.
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
        // 실패 시 에러 메시지
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
          // 로딩 중이면 뺑뺑이, 아니면 카드 보여주기
          child: _isLoading 
              ? const CircularProgressIndicator() 
              : Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          child: const Icon(Icons.fitness_center, color: AppColors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '피티로그',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('회원 관리 시스템', style: TextStyle(color: AppColors.textLight)),
                        const SizedBox(height: 32),
                        
                        // 카카오 로그인 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.chat_bubble, color: AppColors.textPrimary, size: 20),
                            label: const Text('카카오 로그인', style: TextStyle(color: AppColors.textPrimary)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kakaoYellow,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            // [수정] onLogin 대신 내부 함수 연결
                            onPressed: _handleLogin, 
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 구글 로그인 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.g_mobiledata, color: AppColors.textPrimary, size: 20),
                            label: const Text('구글 로그인', style: TextStyle(color: AppColors.textPrimary)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            // [수정] onLogin 대신 내부 함수 연결
                            onPressed: _handleLogin,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('※ 데모 버전입니다', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                        const Text('실제 로그인 기능은 백엔드 연동이 필요합니다', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}