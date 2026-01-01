import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_strings.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/index.dart';

class PtSessionsTab extends StatelessWidget {
  final List<Schedule> memberSchedules;

  const PtSessionsTab({super.key, required this.memberSchedules});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  if (isPast) {
                    // 1. 해당 날짜와 멤버 ID에 맞는 로그 찾기
                    try {
                      final log = mockWorkoutLogs.firstWhere(
                        (l) => l.memberId == schedule.memberId && l.date == schedule.date,
                      );
                      
                      // 2. 찾으면 상세 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutLogDetailScreen(log: log),
                        ),
                      );
                    } catch (e) {
                      // 못 찾으면 (StateError)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('작성된 운동 일지가 없습니다.')),
                      );
                    }
                  } else {
                    // 미래 일정인 경우 (수정/작성 기능 등으로 연결 가능)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('수업 완료 후 작성할 수 있습니다.')),
                    );
                  }
                },
                icon: Icon(
                  LucideIcons.fileText,
                  size: 14,
                  color: isPast ? AppColors.primary : AppColors.textSecondary, // 완료된 건 활성화 컬러로 변경 추천
                ),
                label: Text(
                  '운동기록',
                  style: AppTextStyles.caption.copyWith(
                    color: isPast ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  side: BorderSide(
                    color: isPast ? AppColors.primary : AppColors.disabled,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
