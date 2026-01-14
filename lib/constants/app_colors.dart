// 앱에서 사용하는 주요 색상을 정의합니다.
import 'package:flutter/material.dart';

class AppColors {
  // Main Colors
  static const Color primary = Color(0xFF1976D2); // Colors.blue[800]
  static const Color primaryLight = Color(0xFFE3F2FD); // Colors.blue[50]
  static const Color accent = Color(0xFF303F9F); // Colors.indigo
  static const Color accentLight = Color(0xFFC5CAE9); // Colors.indigo[100]
  
  // Text Colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Color(0xFF757575); // Colors.grey[600]
  static const Color textLight = Colors.grey;

  // Status Colors
  static const Color danger = Color(0xFFD32F2F); // Colors.red[800]
  static const Color dangerLight = Color(0xFFFFEBEE); // Colors.red[50]
  static const Color warning = Color(0xFFFFC107); // Colors.amber
  static const Color warningLight = Color(0xFFFFF8E1); // Colors.amber[50]
  static const Color success = Colors.green;
  static const Color successLight = Color(0xFFC8E6C9); // Colors.green[100]

  // Background Colors
  static const Color background = Color(0xFFFAFAFA); // Colors.grey[50]
  static const Color disabled = Color(0xFFE0E0E0); // Colors.grey[300]
  static const Color disabledText = Color(0xFF9E9E9E); // Colors.grey[500]

  // Common Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Brand Colors
  static const Color kakaoYellow = Color(0xFFFFE812);
}
