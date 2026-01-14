// 예정된 세션 목록 섹션 위젯
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import '../models/index.dart';
import '../screens/session_log_screen.dart';

typedef OnMemberInfoTap = void Function(String memberId);

class UpcomingSessionSection extends StatelessWidget {
  final List<Schedule> schedules;
  final List<Member> members;
  final VoidCallback onManualStart;
  final String? emptyMessage;
  final OnMemberInfoTap onMemberInfoTap;

  const UpcomingSessionSection({
    super.key,
    required this.schedules,
    required this.members,
    required this.onManualStart,
    this.emptyMessage,
    required this.onMemberInfoTap,
  });

  // memberId로 Member를 찾는 헬퍼 메서드
  Member? _findMember(String? memberId) {
    if (memberId == null) return null;
    try {
      return members.firstWhere((m) => m.id == memberId);
    } catch (_) {
      return null;
    }
  }

  String _getDynamicHeaderText() {
    if (schedules.isEmpty) {
      return emptyMessage ?? '오늘은 예약된 세션이 없습니다';
    }

    final now = DateTime.now();
    final firstSchedule = schedules.first;
    
    try {
      final timeParts = firstSchedule.startTime.split(':');
      final scheduleTime = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
      final diffMinutes = scheduleTime.difference(now).inMinutes;

      if (diffMinutes <= 0 && diffMinutes > -60) {
        return '수업 시작 시간이에요! 🔥';
      } else {
        return '$diffMinutes분 뒤에 수업이 있어요! ⏰';
      }
    } catch (e) {
      return '오늘 예정된 수업이 있어요 💪';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getDynamicHeaderText(), 
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: 12),

        if (schedules.isEmpty)
          _buildManualStartCard()
        else
          ...schedules.take(1).map((schedule) => _buildSessionCard(context, schedule)),
      ],
    );
  }

  Widget _buildManualStartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.dumbbell, size: 24, color: AppColors.warning),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '예약된 수업이 없나요?',
                      style: AppTextStyles.subtitle1.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '타 매체 예약이나 신규 회원을 위해\n바로 운동 일지를 시작할 수 있어요.',
                      style: AppTextStyles.caption.copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onManualStart,
              icon: const Icon(LucideIcons.plus, size: 18, color: AppColors.white),
              label: Text('수동으로 수업 시작하기', style: AppTextStyles.button.copyWith(color: AppColors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, Schedule schedule) {
    final member = _findMember(schedule.memberId);
    final phoneNumber = member?.phone ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.clock, color: AppColors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${schedule.startTime} - ${schedule.endTime}',
                        style: AppTextStyles.button.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('예약 변경 팝업을 띄웁니다.')),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.white.withAlpha(77)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.calendarSearch, color: AppColors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '예약 수정',
                          style: AppTextStyles.button.copyWith(color: AppColors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.white,
                  child: Text((schedule.memberName ?? ' ')[0], style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${schedule.memberName ?? '이름 없음'} 회원님',
                            style: AppTextStyles.h3.copyWith(color: AppColors.white),
                          ),
                          if (phoneNumber.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              phoneNumber,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        schedule.notes.isNotEmpty ? schedule.notes : '특이사항 없음',
                        style: AppTextStyles.body.copyWith(color: AppColors.white.withAlpha(204)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onMemberInfoTap(schedule.memberId ?? ''), // [수정] Null 처리
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.white.withAlpha(77), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.clipboardList, color: AppColors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "정보",
                          style: AppTextStyles.button.copyWith(color: AppColors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SessionLogScreen(schedule: schedule),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.play, size: 20, color: AppColors.primary),
                label: Text('세션 시작하기', style: AppTextStyles.button.copyWith(color: AppColors.primary, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}