// 필기 이미지 저장 서비스
// lib/services/handwriting_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:path_provider/path_provider.dart';

class HandwritingService {
  /// 필기 이미지를 로컬 파일시스템에 저장
  ///
  /// [controller] - PainterController 인스턴스
  /// [size] - 렌더링할 이미지 크기 (기본값: 800x600)
  ///
  /// 반환값: 저장된 파일의 절대 경로 또는 실패 시 null
  static Future<String?> saveDrawing(
    PainterController controller, {
    Size size = const Size(800, 600),
  }) async {
    try {
      // 이미지 렌더링 (배경 + 드로잉 합성)
      final ui.Image renderedImage = await controller.renderImage(size);

      // PNG 바이트로 변환
      final ByteData? byteData = await renderedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        debugPrint('HandwritingService: 이미지 바이트 변환 실패');
        return null;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 저장 경로 생성
      final String filePath = await _generateFilePath();

      // 파일 저장
      final File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      debugPrint('HandwritingService: 이미지 저장 완료 - $filePath');
      return filePath;
    } catch (e) {
      debugPrint('HandwritingService: 저장 실패 - $e');
      return null;
    }
  }

  /// 고유한 파일 경로 생성
  static Future<String> _generateFilePath() async {
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

  /// 저장된 필기 이미지 로드
  static Future<Uint8List?> loadDrawing(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('HandwritingService: 로드 실패 - $e');
      return null;
    }
  }

  /// 필기 이미지 삭제
  static Future<bool> deleteDrawing(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('HandwritingService: 이미지 삭제 완료 - $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('HandwritingService: 삭제 실패 - $e');
      return false;
    }
  }

  /// 모든 필기 이미지 목록 조회
  static Future<List<String>> getAllDrawings() async {
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

  /// 필기 이미지 저장 디렉토리 용량 계산 (bytes)
  static Future<int> getStorageUsage() async {
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

  /// 모든 필기 이미지 삭제 (캐시 정리)
  static Future<bool> clearAllDrawings() async {
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
}
