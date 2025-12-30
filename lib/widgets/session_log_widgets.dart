import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
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
              Text(schedule.date, style: AppTextStyles.subtitle2),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(schedule.memberName, style: AppTextStyles.h3),
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

class ExerciseCard extends StatelessWidget {
  final int index;
  final ExerciseForm exercise;
  final VoidCallback onRemove;
  final VoidCallback onAddSet;
  final Function(int) onRemoveSet;
  final bool showRemoveButton;

  const ExerciseCard({
    super.key,
    required this.index,
    required this.exercise,
    required this.onRemove,
    required this.onAddSet,
    required this.onRemoveSet,
    this.showRemoveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.disabled),
        boxShadow: [
          BoxShadow(color: AppColors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('운동 ${index + 1}', style: AppTextStyles.subtitle1),
                if (showRemoveButton)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
                    onPressed: onRemove,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _SimpleTextField(label: '운동 부위', hint: '등', onChanged: (v) => exercise.targetPart = v),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _SimpleTextField(label: '운동 종목', hint: '랫 풀 다운', onChanged: (v) => exercise.name = v),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                _PhotoSlot(),
                SizedBox(width: 12),
                _PhotoSlot(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(width: 32, child: Center(child: Text('SET', style: AppTextStyles.caption.copyWith(fontSize: 11)))),
                Expanded(child: Center(child: Text('kg', style: AppTextStyles.caption.copyWith(fontSize: 11)))),
                Expanded(child: Center(child: Text('회', style: AppTextStyles.caption.copyWith(fontSize: 11)))),
                Expanded(child: Center(child: Text('휴식', style: AppTextStyles.caption.copyWith(fontSize: 11)))),
                const SizedBox(width: 32),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...exercise.sets.asMap().entries.map((entry) {
            return _SetRow(
              index: entry.key,
              onRemove: () => onRemoveSet(entry.key),
              showRemoveButton: exercise.sets.length > 1,
            );
          }),
          InkWell(
            onTap: onAddSet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.background))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plus, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('세트 추가', style: AppTextStyles.button.copyWith(color: AppColors.primary, fontSize: 13)),
                ],
              ),
            ),
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
  final Function(String) onChanged;

  const _SimpleTextField({required this.label, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int index;
  final VoidCallback onRemove;
  final bool showRemoveButton;

  const _SetRow({required this.index, required this.onRemove, required this.showRemoveButton});

  Widget _buildNumberInput() {
    return SizedBox(
      height: 40,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.disabled)),
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
                width: 24, height: 24,
                decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                child: Center(child: Text('${index + 1}', style: AppTextStyles.button.copyWith(fontSize: 12, color: AppColors.primary))),
              ),
            ),
          ),
          Expanded(child: _buildNumberInput()),
          const SizedBox(width: 8),
          Expanded(child: _buildNumberInput()),
          const SizedBox(width: 8),
          Expanded(child: _buildNumberInput()),
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
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.disabled),
        ),
        child: const Center(child: Icon(LucideIcons.camera, color: AppColors.textLight, size: 20)),
      ),
    );
  }
}
