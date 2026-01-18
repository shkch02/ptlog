// 모바일/데스크톱 플랫폼용 파일 시스템 구현
// lib/services/handwriting_service_io.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// 파일로 이미지 저장
Future<String?> saveToFile(Uint8List pngBytes) async {
  try {
    final String filePath = await _generateFilePath();
    final File file = File(filePath);
    await file.writeAsBytes(pngBytes);
    debugPrint('HandwritingService: 이미지 저장 완료 - $filePath');
    return filePath;
  } catch (e) {
    debugPrint('HandwritingService: 파일 저장 실패 - $e');
    return null;
  }
}

/// 파일에서 이미지 로드
Future<Uint8List?> loadFromFile(String filePath) async {
  try {
    final File file = File(filePath);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  } catch (e) {
    debugPrint('HandwritingService: 파일 로드 실패 - $e');
    return null;
  }
}

/// 파일 삭제
Future<bool> deleteFile(String filePath) async {
  try {
    final File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      debugPrint('HandwritingService: 이미지 삭제 완료 - $filePath');
      return true;
    }
    return false;
  } catch (e) {
    debugPrint('HandwritingService: 파일 삭제 실패 - $e');
    return false;
  }
}

/// 모든 필기 이미지 파일 목록 조회
Future<List<String>> getAllDrawingFiles() async {
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String handwritingDir = '${directory.path}/handwriting';

    final Directory dir = Directory(handwritingDir);
    if (!await dir.exists()) {
      return [];
    }

    final List<FileSystemEntity> files = await dir.list().toList();
    return files
        .whereType<File>()
        .where((file) => file.path.endsWith('.png'))
        .map((file) => file.path)
        .toList();
  } catch (e) {
    debugPrint('HandwritingService: 목록 조회 실패 - $e');
    return [];
  }
}

/// 저장 디렉토리 용량 계산
Future<int> calculateStorageUsage() async {
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String handwritingDir = '${directory.path}/handwriting';

    final Directory dir = Directory(handwritingDir);
    if (!await dir.exists()) {
      return 0;
    }

    int totalSize = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  } catch (e) {
    debugPrint('HandwritingService: 용량 계산 실패 - $e');
    return 0;
  }
}

/// 모든 필기 이미지 삭제
Future<bool> clearAllFiles() async {
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String handwritingDir = '${directory.path}/handwriting';

    final Directory dir = Directory(handwritingDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      debugPrint('HandwritingService: 모든 필기 이미지 삭제 완료');
    }
    return true;
  } catch (e) {
    debugPrint('HandwritingService: 전체 삭제 실패 - $e');
    return false;
  }
}

/// 고유한 파일 경로 생성
Future<String> _generateFilePath() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String handwritingDir = '${directory.path}/handwriting';

  // 디렉토리가 없으면 생성
  final Directory dir = Directory(handwritingDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  // 타임스탬프 기반 파일명 생성
  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  return '$handwritingDir/workout_note_$timestamp.png';
}
