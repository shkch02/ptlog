import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;

  const LoginScreen({super.key, required this.onLogin});//생성자, 이 로그인화면 생성시 onLogin 콜백 필요(main.dart에서 _login을 받아 onlogin에 연결)

  //화면 그리기 시작
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( //전체 화면 컨테이너
        decoration: BoxDecoration( //배경 장식
          gradient: LinearGradient( //배경 그라데이션
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.indigo[100]!], //배경 그라데이션 색 지정
          ),
        ),
        child: Center( //화면 중앙에 넣을 위젯
          child: Card( // Card : 입체감이 있는 하얀 박스
            margin: const EdgeInsets.symmetric(horizontal: 24), //좌우 여백 설정, 24
            elevation: 4, //그림자 효과, 깊이는 4
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), //모서리 둥글게
            child: Padding( // 박스 안쪽 버튼들을 위한 여백 설정
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, //컬럼 높이를 자식 위젯에 맞춤,없으면 카드가 위아래로 꽉 참
                children: [
                  Container( // 앱 로고 
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fitness_center, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '피티로그',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('회원 관리 시스템', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  
                  // 카카오 로그인 버튼 (스타일 모방)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble, color: Colors.black87, size: 20),
                      label: const Text('카카오 로그인', style: TextStyle(color: Colors.black87)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE812),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onLogin, // 버튼 누르면 onLogin 콜백 함수 실행
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 구글 로그인 버튼 (카카오 버튼 스타일과 통일)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, color: Colors.black87, size: 20),
                      label: const Text('구글 로그인', style: TextStyle(color: Colors.black87)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onLogin,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('※ 데모 버전입니다', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const Text('실제 로그인 기능은 백엔드 연동이 필요합니다', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}