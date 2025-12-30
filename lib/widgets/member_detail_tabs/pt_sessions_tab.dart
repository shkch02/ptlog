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
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('보고서 기능 준비중')));
                },
                icon: Icon(LucideIcons.fileText,
                    size: 14,
                    color: isPast
                        ? AppColors.textSecondary
                        : AppColors.primary),
                label: Text('운동기록',
                    style: AppTextStyles.caption.copyWith(
                        color: isPast
                            ? AppColors.textSecondary
                            : AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  side: BorderSide(
                      color:
                          isPast ? AppColors.disabledText : AppColors.primary),
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
