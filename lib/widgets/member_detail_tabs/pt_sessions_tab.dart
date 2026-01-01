import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Riverpod import
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_strings.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/index.dart';
import 'package:ptlog/providers/repository_providers.dart'; // 2. Provider import
import 'package:ptlog/screens/workout_log_detail_screen.dart'; // 상세 화면 import

// 3. ConsumerWidget으로 변경
class PtSessionsTab extends ConsumerWidget {
  final List<Schedule> memberSchedules;

  const PtSessionsTab({super.key, required this.memberSchedules});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // 4. WidgetRef ref 파라미터 추가
    if (memberSchedules.isEmpty) {
      return const Center(child: Text('예약된 스케줄이 없습니다.'));
    }
    final now = DateTime.now();

    return ListView.builder(
      itemCount: memberSchedules.length,
      itemBuilder: (context, index) {
        final schedule = memberSchedules[index];
        DateTime scheduleTime;
        try {
          scheduleTime = DateFormat(AppStrings.dateFormatYmdHm)
              .parse('${schedule.date} ${schedule.startTime}');
        } catch (e) {
          scheduleTime = now;
        }
        final isPast = scheduleTime.isBefore(now);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isPast ? AppColors.background : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isPast ? AppColors.disabled : AppColors.primaryLight,
                width: isPast ? 1 : 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${schedule.date} ${schedule.startTime}',
                      style: AppTextStyles.subtitle1.copyWith(
                        color: isPast
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPast
                          ? '완료'
                          : (schedule.notes.isNotEmpty
                              ? schedule.notes
                              : '예약됨'),
                      style: AppTextStyles.caption.copyWith(
                          color: isPast ? AppColors.textLight : AppColors.primary,
                          fontWeight:
                              isPast ? FontWeight.normal : FontWeight.w600),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                // 5. 비동기 콜백으로 변경
                onPressed: () async {
                  if (isPast) {
                    try {
                      // ★ 리포지토리 패턴 적용 부분 ★
                      // Provider를 통해 Repository 인스턴스를 가져오고 메서드 호출
                      final log = await ref
                          .read(workoutLogRepositoryProvider)
                          .getLogBySchedule(schedule.memberId, schedule.date);

                      // 비동기 작업 후 context 마운트 여부 확인
                      if (!context.mounted) return;

                      if (log != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkoutLogDetailScreen(log: log),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('작성된 운동 일지가 없습니다.')),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('오류가 발생했습니다.')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('수업 완료 후 작성할 수 있습니다.')),
                    );
                  }
                },
                icon: Icon(
                  LucideIcons.fileText,
                  size: 14,
                  color: isPast ? AppColors.primary : AppColors.textSecondary,
                ),
                label: Text(
                  '운동기록',
                  style: AppTextStyles.caption.copyWith(
                    color: isPast ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  side: BorderSide(
                      color:
                          isPast ? AppColors.primary : AppColors.disabled),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}