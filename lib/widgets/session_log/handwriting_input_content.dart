// 필기 모드 입력 위젯
// lib/widgets/session_log/handwriting_input_content.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_assets.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/services/handwriting_service.dart';

class HandwritingInputContent extends StatefulWidget {
  final String templateAssetPath;
  final Function(String savedPath)? onSaved;
  final String? initialImagePath;

  const HandwritingInputContent({
    super.key,
    this.templateAssetPath = AppAssets.workoutTemplateV1,
    this.onSaved,
    this.initialImagePath,
  });

  @override
  State<HandwritingInputContent> createState() => _HandwritingInputContentState();
}

class _HandwritingInputContentState extends State<HandwritingInputContent> {
  PainterController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  // 현재 선택된 도구
  DrawingTool _currentTool = DrawingTool.pen;
  Color _currentColor = Colors.black;
  double _currentStrokeWidth = 3.0;

  // 템플릿 이미지의 실제 비율
  double _templateAspectRatio = 4 / 3;

  @override
  void initState() {
    super.initState();
    _initializePainter();
  }

  Future<void> _initializePainter() async {
    try {
      // PainterController 초기화
      _controller = PainterController(
        settings: PainterSettings(
          freeStyle: FreeStyleSettings(
            color: _currentColor,
            strokeWidth: _currentStrokeWidth,
            mode: FreeStyleMode.draw,
          ),
          scale: ScaleSettings(
            enabled: false,
          ),
        ),
      );

      // 배경 이미지 로드
      await _loadBackgroundImage();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '템플릿 로드 실패: $e';
      });
    }
  }

  Future<void> _loadBackgroundImage() async {
    try {
      Uint8List? bytes;

      // 기존 저장된 이미지가 있으면 해당 이미지 로드, 없으면 템플릿 로드
      if (widget.initialImagePath != null) {
        // HandwritingService를 통해 로드 (웹: Data URI 디코딩, 모바일: 파일 읽기)
        bytes = await HandwritingService.loadDrawing(widget.initialImagePath!);
      }

      // 저장된 이미지가 없거나 로드 실패 시 템플릿 로드
      if (bytes == null) {
        final ByteData data = await rootBundle.load(widget.templateAssetPath);
        bytes = data.buffer.asUint8List();
      }

      // 이미지 디코딩
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // 템플릿 이미지의 실제 비율 계산
      _templateAspectRatio = image.width / image.height;

      // 배경으로 설정
      _controller?.background = image.backgroundDrawable;
    } catch (e) {
      debugPrint('배경 이미지 로드 오류: $e');
      rethrow;
    }
  }

  void _updatePenSettings() {
    if (_controller == null) return;

    _controller!.freeStyleColor = _currentColor;
    _controller!.freeStyleStrokeWidth = _currentStrokeWidth;

    if (_currentTool == DrawingTool.eraser) {
      _controller!.freeStyleMode = FreeStyleMode.erase;
    } else {
      _controller!.freeStyleMode = FreeStyleMode.draw;
    }
  }

  void _selectTool(DrawingTool tool) {
    setState(() {
      _currentTool = tool;
      if (tool == DrawingTool.eraser) {
        _currentStrokeWidth = 20.0;
      } else {
        _currentStrokeWidth = 3.0;
      }
    });
    _updatePenSettings();
  }

  void _selectColor(Color color) {
    setState(() {
      _currentColor = color;
      _currentTool = DrawingTool.pen;
    });
    _updatePenSettings();
  }

  void _clearCanvas() {
    _controller?.clearDrawables();
  }

  void _undo() {
    _controller?.undo();
  }

  void _redo() {
    _controller?.redo();
  }

  Future<void> _saveDrawing() async {
    if (_controller == null) return;

    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 템플릿 비율에 맞는 렌더링 사이즈 계산 (가로 기준 1200px)
      const double baseWidth = 1200;
      final Size renderSize = Size(baseWidth, baseWidth / _templateAspectRatio);

      // 이미지 렌더링 및 저장
      final savedPath = await HandwritingService.saveDrawing(
        _controller!,
        size: renderSize,
      );

      // 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      if (savedPath != null) {
        // 콜백 호출
        widget.onSaved?.call(savedPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('필기가 저장되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('저장 실패');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _initializePainter();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // 캔버스 영역
        _buildCanvas(),
        const SizedBox(height: 12),
        // 툴바
        _buildToolbar(),
        const SizedBox(height: 8),
        // 색상 선택
        _buildColorPalette(),
        const SizedBox(height: 12),
        // 저장 버튼
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildCanvas() {
    return AspectRatio(
      aspectRatio: _templateAspectRatio,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.disabled, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _controller != null
              ? FlutterPainter(controller: _controller!)
              : const Center(child: Text('캔버스 로딩 중...')),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(
            icon: LucideIcons.pencil,
            label: '펜',
            isSelected: _currentTool == DrawingTool.pen,
            onTap: () => _selectTool(DrawingTool.pen),
          ),
          _buildToolButton(
            icon: LucideIcons.eraser,
            label: '지우개',
            isSelected: _currentTool == DrawingTool.eraser,
            onTap: () => _selectTool(DrawingTool.eraser),
          ),
          _buildToolButton(
            icon: LucideIcons.undo2,
            label: '실행취소',
            onTap: _undo,
          ),
          _buildToolButton(
            icon: LucideIcons.redo2,
            label: '다시실행',
            onTap: _redo,
          ),
          _buildToolButton(
            icon: LucideIcons.trash2,
            label: '전체삭제',
            onTap: _clearCanvas,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.danger
        : isSelected
            ? AppColors.primary
            : AppColors.textLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('색상: ', style: AppTextStyles.caption),
        const SizedBox(width: 8),
        ...colors.map((color) => _buildColorButton(color)),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _currentColor == color && _currentTool != DrawingTool.eraser;

    return GestureDetector(
      onTap: () => _selectColor(color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveDrawing,
        icon: const Icon(LucideIcons.save, size: 18),
        label: const Text('필기 저장'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

enum DrawingTool { pen, eraser }
