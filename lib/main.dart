import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/layout_screen.dart';

void main() {
  runApp(const PtTrainerApp()); //앱 진입점
}

class PtTrainerApp extends StatelessWidget {
  const PtTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PT Trainer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Tailwind 색상 대체
      ),
      home: const AppContainer(),
    );
  }
}

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  bool isLoggedIn = false; //로그인 상태 관리

  void _login() {
    setState(() {//로그인 상태 변경
      isLoggedIn = true; // 지금은 그냥 로그인 버튼 누르기만 하면 true로 로그인 처리
    });
  }

  void _logout() {
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // React의 조건부 렌더링과 동일
    if (!isLoggedIn) {//로그인 안되어있으면 loginScreen 보여줌
      return LoginScreen(onLogin: _login);
    }
    //로그인 되어있으면 LayoutScreen 보여줌
    return LayoutScreen(onLogout: _logout);
  }
}