import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 초기화
  await _initializeEnvironment();

  // 날짜 포맷팅 초기화
  await initializeDateFormatting('ko_KR', null);

  runApp(
    const ProviderScope(
      child: PtTrainerApp(),
    ),
  );
}

/// 환경 변수를 초기화합니다.
/// .env 파일이 없거나 로드에 실패해도 앱이 크래시되지 않도록 처리합니다.
Future<void> _initializeEnvironment() async {
  try {
    await dotenv.load(fileName: '.env');
    if (kDebugMode) {
      print('[ENV] Environment variables loaded successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('[ENV] Warning: Failed to load .env file: $e');
      print('[ENV] The app will continue with default/fallback values.');
    }
  }
}

class PtTrainerApp extends StatelessWidget {
  const PtTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PT Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Pretendard',
      ),
      home: const LoginScreen(),
    );
  }
}
