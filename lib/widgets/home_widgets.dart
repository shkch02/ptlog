// 홈 화면에 사용되는 위젯 모음
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import '../models/index.dart';

// ----------------------------------------------------------------------
// 1. 헤더 위젯 (날짜 + 수업 시작 버튼)
// ----------------------------------------------------------------------
class HomeHeader extends StatelessWidget {
  final int scheduleCount;
  final VoidCallback onManualStartTap;

  const HomeHeader({
    super.key,
    required this.scheduleCount,
    required this.onManualStartTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('M월 d일 EEEE', 'ko_KR').format(now),
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 4),
              Text(
                '오늘 수업 $scheduleCount개',
                style: AppTextStyles.subtitle2.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: onManualStartTap,
            icon: const Icon(LucideIcons.play, size: 16),
            label: const Text('수업 시작'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 2. 빈 화면 위젯
// ----------------------------------------------------------------------
class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.calendarCheck, size: 64, color: AppColors.disabled),
          const SizedBox(height: 16),
          const Text('오늘 예정된 수업이 없습니다.', style: AppTextStyles.subtitle1),
          const SizedBox(height: 8),
          const Text('편안한 하루 되세요!', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 3. 스케줄 카드 위젯
// ----------------------------------------------------------------------
class HomeScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final bool isPast;
  final VoidCallback onMemberTap;
  final VoidCallback onStartTap;
  final String? memberPhone;

  const HomeScheduleCard({
    super.key,
    required this.schedule,
    required this.isPast,
    required this.onMemberTap,
    required this.onStartTap,
    this.memberPhone,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPast ? Colors.grey[100] : AppColors.white;
    final textColor = isPast ? AppColors.textSecondary : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPast ? AppColors.disabled : AppColors.primaryLight,
          width: 1,
        ),
        boxShadow: isPast
            ? []
            : [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: InkWell(
        onTap: onStartTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 시간 표시
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    schedule.startTime,
                    style: AppTextStyles.h3.copyWith(
                      color: isPast ? AppColors.textSecondary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPast ? Colors.grey[300] : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPast ? '종료' : '예정',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey[600] : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 40,
                color: isPast ? AppColors.disabled : AppColors.primaryLight,
              ),
              const SizedBox(width: 16),

              // 내용 표시
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          schedule.memberName ?? '이름 없음',
                          style: AppTextStyles.subtitle1.copyWith(color: textColor),
                        ),
                        if (memberPhone != null && memberPhone!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            memberPhone!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        if (!isPast)
                          const Icon(LucideIcons.dumbbell, size: 14, color: AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.notes.isNotEmpty ? schedule.notes : '내용 없음',
                      style: AppTextStyles.subtitle2.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 회원 정보 버튼
              IconButton(
                onPressed: onMemberTap,
                icon: Icon(
                  LucideIcons.info,
                  color: isPast ? AppColors.textSecondary : AppColors.primary,
                  size: 24,
                ),
                tooltip: '회원 정보',
              ),
            ],
          ),
        ),
      ),
    );
  }
}