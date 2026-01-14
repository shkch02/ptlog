// 필기 이미지 저장 서비스
// lib/services/handwriting_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';

// dart:io와 path_provider는 웹에서 사용 불가하므로 조건부 import
import 'handwriting_service_io.dart'
    if (dart.library.html) 'handwriting_service_web.dart' as platform;

class HandwritingService {
  /// 필기 이미지를 저장
  ///
  /// [controller] - PainterController 인스턴스
  /// [size] - 렌더링할 이미지 크기 (기본값: 800x600)
  ///
  /// 반환값:
  /// - 웹: Base64 Data URI 문자열 ('data:image/png;base64,...')
  /// - 모바일: 저장된 파일의 절대 경로
  /// - 실패 시: null
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

      // 플랫폼에 따라 다른 저장 방식 사용
      if (kIsWeb) {
        // 웹: Base64 Data URI로 변환
        final String base64String = base64Encode(pngBytes);
        final String dataUri = 'data:image/png;base64,$base64String';
        debugPrint('HandwritingService: 이미지 Data URI 생성 완료');
        return dataUri;
      } else {
        // 모바일: 파일로 저장
        return await platform.saveToFile(pngBytes);
      }
    } catch (e) {
      debugPrint('HandwritingService: 저장 실패 - $e');
      return null;
    }
  }

  /// 저장된 필기 이미지 로드
  ///
  /// 웹에서 Data URI가 전달되면 Base64 디코딩하여 반환
  /// 모바일에서 파일 경로가 전달되면 파일을 읽어서 반환
  static Future<Uint8List?> loadDrawing(String pathOrDataUri) async {
    try {
      if (kIsWeb || pathOrDataUri.startsWith('data:image/png;base64,')) {
        // Data URI에서 Base64 디코딩
        final String base64String = pathOrDataUri.split(',').last;
        return base64Decode(base64String);
      } else {
        // 모바일: 파일에서 로드
        return await platform.loadFromFile(pathOrDataUri);
      }
    } catch (e) {
      debugPrint('HandwritingService: 로드 실패 - $e');
      return null;
    }
  }

  /// 필기 이미지 삭제
  ///
  /// 웹에서는 파일 시스템이 없으므로 항상 true 반환
  static Future<bool> deleteDrawing(String pathOrDataUri) async {
    try {
      if (kIsWeb || pathOrDataUri.startsWith('data:image/png;base64,')) {
        // 웹: Data URI는 메모리에만 존재하므로 삭제할 필요 없음
        return true;
      } else {
        // 모바일: 파일 삭제
        return await platform.deleteFile(pathOrDataUri);
      }
    } catch (e) {
      debugPrint('HandwritingService: 삭제 실패 - $e');
      return false;
    }
  }

  /// 모든 필기 이미지 목록 조회
  ///
  /// 웹에서는 빈 리스트 반환 (파일 시스템 접근 불가)
  static Future<List<String>> getAllDrawings() async {
    if (kIsWeb) {
      // 웹: 파일 시스템 접근 불가
      return [];
    }
    try {
      return await platform.getAllDrawingFiles();
    } catch (e) {
      debugPrint('HandwritingService: 목록 조회 실패 - $e');
      return [];
    }
  }

  /// 필기 이미지 저장 디렉토리 용량 계산 (bytes)
  ///
  /// 웹에서는 0 반환
  static Future<int> getStorageUsage() async {
    if (kIsWeb) {
      return 0;
    }
    try {
      return await platform.calculateStorageUsage();
    } catch (e) {
      debugPrint('HandwritingService: 용량 계산 실패 - $e');
      return 0;
    }
  }

  /// 모든 필기 이미지 삭제 (캐시 정리)
  ///
  /// 웹에서는 항상 true 반환
  static Future<bool> clearAllDrawings() async {
    if (kIsWeb) {
      return true;
    }
    try {
      return await platform.clearAllFiles();
    } catch (e) {
      debugPrint('HandwritingService: 전체 삭제 실패 - $e');
      return false;
    }
  }
}
