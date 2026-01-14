// 세션 로그에 사용되는 위젯 모음
// lib/widgets/session_log_widgets.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
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
/// - 공통 정보 섹션 (운동명, 부위, 사진) - 항상 표시
/// - 세트 입력 모드 토글 (디지털/필기)
/// - 세트 입력 영역 (모드에 따라 변경)
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

          // ========== 2. 공통 정보 섹션 (항상 표시) ==========
          _buildCommonInfoSection(),

          // ========== 3. 구분선 + 세트 기록 라벨 ==========
          _buildSetSectionDivider(),

          // ========== 4. 세트 입력 모드 토글 ==========
          _buildSetInputModeToggle(),

          // ========== 5. 세트 입력 영역 (모드에 따라 변경) ==========
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

  /// 공통 정보 섹션: 운동 부위, 운동 종목, 사진 - 항상 표시됨
  Widget _buildCommonInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 운동 부위 / 종목 입력
          Row(
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
          const SizedBox(height: 12),
          // 사진 슬롯
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
      children: [
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

  /// 필기 세트 입력 UI (캔버스)
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
                    '템플릿 위에 스타일러스 또는 손가락으로 세트 정보를 기록하세요.',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 필기 캔버스
          HandwritingInputContent(
            templateAssetPath: 'assets/images/templates/workout_template_v1.png',
            initialImagePath: widget.exercise.handwritingImagePath,
            onSaved: (path) {
              setState(() {
                widget.exercise.handwritingImagePath = path;
              });
              widget.onHandwritingSaved?.call(path);
            },
          ),
        ],
      ),
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
