// lib/constants/app_assets.dart

class AppAssets {
  // 인스턴스화 방지 (private 생성자)
  AppAssets._();

  // 기본 경로 (Base Path) - 경로 변경 시 여기만 수정하면 됨
  static const String _imageBasePath = 'assets/images';
  static const String _templatePath = '$_imageBasePath/templates';
  //static const String _iconPath = '$_imageBasePath/icons'; // 예시

  // --- 템플릿 이미지 ---
  static const String workoutTemplateV1 = '$_templatePath/workout_template_v1.png';

  // --- 템플릿 이미지 비율 ---
  // Aspect Ratio = Width / Height
  // 실제 이미지 크기에 맞게 조정 필요 (예: 1200x1697 → 1200/1697 ≈ 0.707)
  // A4 비율 기준: 1 / 1.414 ≈ 0.707
  //아니이거 이미지가서 조회 못하나? 흠
  static const double workoutTemplateAspectRatio = 1476/359;

  // --- 기타 이미지 (예시) ---
  // static const String logo = '$_imageBasePath/logo.png';
}