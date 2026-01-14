// 웹 플랫폼용 스텁 구현
// lib/services/handwriting_service_web.dart
//
// 웹에서는 dart:io를 사용할 수 없으므로 스텁 함수를 제공합니다.
// 실제로 이 함수들은 kIsWeb 체크로 인해 호출되지 않습니다.

import 'dart:typed_data';

/// 파일로 이미지 저장 (웹에서는 사용 불가)
Future<String?> saveToFile(Uint8List pngBytes) async {
  throw UnsupportedError('File system is not available on web platform');
}

/// 파일에서 이미지 로드 (웹에서는 사용 불가)
Future<Uint8List?> loadFromFile(String filePath) async {
  throw UnsupportedError('File system is not available on web platform');
}

/// 파일 삭제 (웹에서는 사용 불가)
Future<bool> deleteFile(String filePath) async {
  throw UnsupportedError('File system is not available on web platform');
}

/// 모든 필기 이미지 파일 목록 조회 (웹에서는 사용 불가)
Future<List<String>> getAllDrawingFiles() async {
  throw UnsupportedError('File system is not available on web platform');
}

/// 저장 디렉토리 용량 계산 (웹에서는 사용 불가)
Future<int> calculateStorageUsage() async {
  throw UnsupportedError('File system is not available on web platform');
}

/// 모든 필기 이미지 삭제 (웹에서는 사용 불가)
Future<bool> clearAllFiles() async {
  throw UnsupportedError('File system is not available on web platform');
}
