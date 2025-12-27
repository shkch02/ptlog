// lib/widgets/session_log_widgets.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/index.dart'; // Schedule
import '../models/session_form.dart'; // ExerciseForm, SetForm

// 1. 헤더 위젯
class SessionLogHeader extends StatelessWidget {
  final Schedule schedule;

  const SessionLogHeader({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(schedule.date, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(schedule.memberName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('15회차', style: TextStyle(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const Icon(LucideIcons.calendarCheck, size: 32, color: Colors.blue),
        ],
      ),
    );
  }
}

// 2. 운동 카드 위젯
class ExerciseCard extends StatelessWidget {
  final int index;
  final ExerciseForm exercise;
  final VoidCallback onRemove;
  final VoidCallback onAddSet;
  final Function(int) onRemoveSet;
  final bool showRemoveButton; // 최소 1개일 때 삭제 버튼 숨김용

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // 상단: 타이틀 + 삭제 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('운동 ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (showRemoveButton)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                    onPressed: onRemove,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),

          // 운동 정보 입력
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

          // 사진 슬롯
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

          // 세트 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                SizedBox(width: 32, child: Center(child: Text('SET', style: TextStyle(fontSize: 11, color: Colors.grey)))),
                Expanded(child: Center(child: Text('kg', style: TextStyle(fontSize: 11, color: Colors.grey)))),
                Expanded(child: Center(child: Text('회', style: TextStyle(fontSize: 11, color: Colors.grey)))),
                Expanded(child: Center(child: Text('휴식', style: TextStyle(fontSize: 11, color: Colors.grey)))),
                SizedBox(width: 32),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 세트 리스트
          ...exercise.sets.asMap().entries.map((entry) {
            return _SetRow(
              index: entry.key,
              onRemove: () => onRemoveSet(entry.key),
              showRemoveButton: exercise.sets.length > 1,
            );
          }).toList(),

          // 세트 추가 버튼
          InkWell(
            onTap: onAddSet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[100]!))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.plus, size: 14, color: Colors.blue),
                  SizedBox(width: 4),
                  Text('세트 추가', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. 피드백 및 메모 입력 위젯
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
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

// --- 내부 사용 작은 위젯들 (Private) ---

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
        fillColor: Colors.grey[50],
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
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
                decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                child: Center(child: Text('${index + 1}', style: TextStyle(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.bold))),
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
                    icon: const Icon(LucideIcons.x, size: 16, color: Colors.grey),
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
      onTap: () {
        // TODO: 이미지 피커
      },
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(child: Icon(LucideIcons.camera, color: Colors.grey, size: 20)),
      ),
    );
  }
}