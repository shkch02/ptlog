import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 날짜 포맷팅 초기화용 (필요시)
import 'screens/login_screen.dart';

void main() async {
  // 날짜 포맷팅 등 비동기 초기화가 필요할 때를 대비해 미리 바인딩
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  
  runApp(const PtTrainerApp());
}

class PtTrainerApp extends StatelessWidget {
  const PtTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PT Trainer',
      debugShowCheckedModeBanner: false, // 디버그 띠 제거
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.grey[50], // 앱 전체 배경색 설정
        fontFamily: 'Pretendard', // (만약 폰트 적용했다면)
      ),
      // [수정] AppContainer 없이 바로 로그인 화면으로 시작!
      home: const LoginScreen(), 
    );
  }
}