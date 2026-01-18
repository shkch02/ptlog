// 세션 로그에 사용되는 위젯 모음
// lib/widgets/session_log_widgets.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_assets.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/services/handwriting_service.dart';
import 'package:ptlog/widgets/session_log/handwriting_input_content.dart';
import '../models/index.dart';

class SessionLogHeader extends StatelessWidget {
  final Schedule schedule;

  const SessionLogHeader({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('yyyy-MM-dd').format(schedule.date), style: AppTextStyles.subtitle2),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(schedule.memberName ?? '이름 없음', style: AppTextStyles.h3),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('15회차', style: AppTextStyles.button.copyWith(fontSize: 12, color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          ),
          const Icon(LucideIcons.calendarCheck, size: 32, color: AppColors.primary),
        ],
      ),
    );
  }
}

/// 개별 운동 카드 위젯
///
/// 구조:
/// - 헤더 (운동 번호, 삭제 버튼)
/// - 세트 입력 모드 토글 (디지털/필기)
/// - 세트 입력 영역 (모드에 따라 변경)
///   - 디지털: 공통 정보 섹션 (운동명, 부위, 사진) + 세트 입력
///   - 필기: 캔버스만 표시
class ExerciseCard extends StatefulWidget {
  final int index;
  final ExerciseForm exercise;
  final VoidCallback onRemove;
  final VoidCallback onAddSet;
  final Function(int) onRemoveSet;
  final bool showRemoveButton;
  final Function(String)? onHandwritingSaved;

  const ExerciseCard({
    super.key,
    required this.index,
    required this.exercise,
    required this.onRemove,
    required this.onAddSet,
    required this.onRemoveSet,
    this.showRemoveButton = true,
    this.onHandwritingSaved,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.disabled),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== 1. 헤더 영역 ==========
          _buildHeader(),

          // ========== 2. 사진 섹션 (항상 표시) ==========
          _buildPhotoSection(),

          // ========== 3. 세트 입력 모드 토글 ==========
          _buildSetInputModeToggle(),

          // ========== 4. 세트 입력 영역 (모드에 따라 변경) ==========
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: widget.exercise.setInputMode == SetInputMode.digital
                ? _buildDigitalSetInput()
                : _buildHandwritingSetInput(),
          ),
        ],
      ),
    );
  }

  /// 헤더 영역: 운동 번호 + 필기 저장 뱃지 + 삭제 버튼
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('운동 ${widget.index + 1}', style: AppTextStyles.subtitle1),
              const SizedBox(width: 8),
              // 필기 저장 완료 뱃지
              if (widget.exercise.handwritingImagePath != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.check, size: 12, color: Colors.green.shade700),
                      const SizedBox(width: 2),
                      Text(
                        '필기 저장됨',
                        style: TextStyle(fontSize: 10, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (widget.showRemoveButton)
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
              onPressed: widget.onRemove,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  /// 사진 섹션: 운동 사진 첨부 슬롯 (항상 표시)
  Widget _buildPhotoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.camera, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                '운동 사진',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _PhotoSlot(),
              SizedBox(width: 12),
              _PhotoSlot(),
            ],
          ),
        ],
      ),
    );
  }

  /// 세트 기록 섹션 구분선 + 라벨
  Widget _buildSetSectionDivider() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.disabled.withAlpha(100)),
          bottom: BorderSide(color: AppColors.disabled.withAlpha(100)),
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.clipboardList, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text(
            '세트 기록',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  /// 세트 입력 모드 토글 버튼
  Widget _buildSetInputModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildModeButton(
                icon: LucideIcons.keyboard,
                label: '디지털 입력',
                isSelected: widget.exercise.setInputMode == SetInputMode.digital,
                onTap: () {
                  setState(() {
                    widget.exercise.setInputMode = SetInputMode.digital;
                  });
                },
              ),
            ),
            Expanded(
              child: _buildModeButton(
                icon: LucideIcons.penTool,
                label: '필기 입력',
                isSelected: widget.exercise.setInputMode == SetInputMode.handwriting,
                onTap: () {
                  setState(() {
                    widget.exercise.setInputMode = SetInputMode.handwriting;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textLight,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 디지털 세트 입력 UI
  Widget _buildDigitalSetInput() {
    return Column(
      key: const ValueKey('digital_input'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========== 운동 정보 섹션 (운동 부위, 종목) ==========
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _SimpleTextField(
                  label: '운동 부위',
                  hint: '등',
                  initialValue: widget.exercise.targetPart,
                  onChanged: (v) => widget.exercise.targetPart = v,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _SimpleTextField(
                  label: '운동 종목',
                  hint: '랫 풀 다운',
                  initialValue: widget.exercise.name,
                  onChanged: (v) => widget.exercise.name = v,
                ),
              ),
            ],
          ),
        ),
        // ========== 구분선 + 세트 기록 라벨 ==========
        _buildSetSectionDivider(),
        const SizedBox(height: 8),
        // 세트 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Center(
                  child: Text('SET', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text('kg', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text('회', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text('휴식', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 세트 목록
        ...widget.exercise.sets.asMap().entries.map((entry) {
          return _SetRow(
            index: entry.key,
            setForm: entry.value,
            onRemove: () => widget.onRemoveSet(entry.key),
            showRemoveButton: widget.exercise.sets.length > 1,
          );
        }),
        // 세트 추가 버튼
        InkWell(
          onTap: widget.onAddSet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.background)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.plus, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '세트 추가',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 필기 세트 입력 UI (미리보기 + 팝업 다이얼로그)
  Widget _buildHandwritingSetInput() {
    return Padding(
      key: const ValueKey('handwriting_input'),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 안내 텍스트
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '아래 이미지를 탭하면 전체 화면에서 필기할 수 있습니다.',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 미리보기 이미지 (탭하면 다이얼로그 열림)
          _buildHandwritingPreview(),
        ],
      ),
    );
  }

  /// 필기 미리보기 이미지 위젯
  Widget _buildHandwritingPreview() {
    final imagePath = widget.exercise.handwritingImagePath;

    return GestureDetector(
      onTap: _showHandwritingDialog,
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
          child: Stack(
            children: [
              // 이미지 (저장된 필기 또는 기본 템플릿)
              AspectRatio(
                aspectRatio: AppAssets.workoutTemplateAspectRatio,
                child: imagePath != null
                    ? _buildSavedImage(imagePath)
                    : Image.asset(
                        AppAssets.workoutTemplateV1,
                        fit: BoxFit.cover,
                      ),
              ),
              // "탭하여 편집" 오버레이
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.penTool,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            imagePath != null ? '탭하여 편집' : '탭하여 필기 시작',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 저장된 필기 이미지 로드 위젯
  Widget _buildSavedImage(String imagePath) {
    // Data URI인 경우 (웹)
    if (imagePath.startsWith('data:image/png;base64,')) {
      final base64String = imagePath.split(',').last;
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }

    // 파일 경로인 경우 (모바일) - FutureBuilder로 로드
    return FutureBuilder<Uint8List?>(
      future: HandwritingService.loadDrawing(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: AppColors.background,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _buildImageError();
        }
        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError();
          },
        );
      },
    );
  }

  /// 이미지 로드 에러 위젯
  Widget _buildImageError() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.imageOff, size: 32, color: AppColors.textLight),
            const SizedBox(height: 8),
            Text(
              '이미지 로드 실패',
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  /// 필기 입력 다이얼로그 표시
  void _showHandwritingDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '필기 입력 닫기',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.95,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 다이얼로그 헤더
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.penTool, size: 20, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                '운동 ${widget.index + 1} - 필기 입력',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(LucideIcons.x, size: 20, color: Colors.white),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    // 필기 캔버스
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: HandwritingInputContent(
                          templateAssetPath: AppAssets.workoutTemplateV1,
                          initialImagePath: widget.exercise.handwritingImagePath,
                          onSaved: (path) {
                            setState(() {
                              widget.exercise.handwritingImagePath = path;
                            });
                            widget.onHandwritingSaved?.call(path);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

class SessionTextInput extends StatelessWidget {
  final String title;
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;

  const SessionTextInput({
    super.key,
    required this.title,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.subtitle1)
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _SimpleTextField extends StatelessWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final Function(String) onChanged;

  const _SimpleTextField({
    required this.label,
    required this.hint,
    this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int index;
  final SetForm setForm;
  final VoidCallback onRemove;
  final bool showRemoveButton;

  const _SetRow({
    required this.index,
    required this.setForm,
    required this.onRemove,
    required this.showRemoveButton,
  });

  Widget _buildNumberInput({
    required String? initialValue,
    required Function(String) onChanged,
  }) {
    return SizedBox(
      height: 40,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.disabled),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildNumberInput(
              initialValue: setForm.weight,
              onChanged: (v) => setForm.weight = v,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildNumberInput(
              initialValue: setForm.reps,
              onChanged: (v) => setForm.reps = v,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildNumberInput(
              initialValue: setForm.rest,
              onChanged: (v) => setForm.rest = v,
            ),
          ),
          SizedBox(
            width: 32,
            child: showRemoveButton
                ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textLight),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.disabled),
        ),
        child: const Center(
          child: Icon(LucideIcons.camera, color: AppColors.textLight, size: 20),
        ),
      ),
    );
  }
}
