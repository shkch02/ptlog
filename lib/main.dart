import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/layout_screen.dart';

void main() {
  runApp(const PtTrainerApp());
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
  bool isLoggedIn = false;

  void _login() {
    setState(() {
      isLoggedIn = true;
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
    if (!isLoggedIn) {
      return LoginScreen(onLogin: _login);
    }
    return LayoutScreen(onLogout: _logout);
  }
}