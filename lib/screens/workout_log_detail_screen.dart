// 작성된 운동일지의 상세 내용을 보여주는 화면입니다.
// lib/screens/workout_log_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import '../models/index.dart';

class WorkoutLogDetailScreen extends StatelessWidget {
  final WorkoutLog log;

  const WorkoutLogDetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${log.date} 수업 일지'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.user, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('${log.memberName} 회원님', style: AppTextStyles.h3),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${log.sessionNumber}회차',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. 운동 목록
            const Text('운동 내역', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            ...log.exercises.map((exercise) => _buildExerciseCard(exercise)),

            const SizedBox(height: 24),

            // 3. 총평 및 피드백
            const Text('피드백 & 메모', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.disabled),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(LucideIcons.messageSquare, '오늘의 피드백', log.overallNotes),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.stickyNote, '다음 수업 메모', log.reminderForNext),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.disabled),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 운동 종목명
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(exercise.name, style: AppTextStyles.subtitle1),
                if (exercise.notes.isNotEmpty)
                  Tooltip(
                    message: exercise.notes,
                    child: const Icon(LucideIcons.info, size: 16, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 세트 정보 테이블
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(child: Center(child: Text('SET', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                    Expanded(child: Center(child: Text('kg', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                    Expanded(child: Center(child: Text('Reps', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                  ],
                ),
                const SizedBox(height: 8),
                ...exercise.sets.map((set) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                              child: Center(
                                  child: Text('${set.setNumber}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)))),
                          Expanded(child: Center(child: Text('${set.weight}'))),
                          Expanded(child: Center(child: Text('${set.reps}'))),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.subtitle2),
        ]),
        const SizedBox(height: 8),
        Text(value.isEmpty ? '-' : value, style: AppTextStyles.body),
      ],
    );
  }
}