// 회원 상세 정보의 PT 세션 탭 위젯
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_strings.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/index.dart';
import 'package:ptlog/providers/repository_providers.dart';
import 'package:ptlog/providers/schedule_providers.dart'; // [추가] Provider import
import 'package:ptlog/screens/workout_log_detail_screen.dart';
import 'package:ptlog/widgets/session_add_dialog.dart'; // [추가] 다이얼로그 import

/**주의: PtSessionsTab을 사용할 때 부모 위젯에서 memberId를 정확히 전달해주어야 합니다. (기존에 List<Schedule>만 받던 것을 Member 객체 또는 memberId를 받도록 변경하는 것이 좋습니다. 여기서는 member 객체를 받는다고 가정하고 수정합니다.) */

class PtSessionsTab extends ConsumerWidget {
  // [수정] 리스트를 직접 받는 대신, 회원 정보를 받아 Provider로 조회합니다.
  final Member member; 

  const PtSessionsTab({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [수정] memberSchedulesProvider -> memberSchedulesHistoryProvider
    final schedulesAsync = ref.watch(memberSchedulesHistoryProvider(member.id));

    return SizedBox(
      height: 400, // 탭 내부 높이 지정 (필요 시 조정)
      child: Stack(
        children: [
          // 1. 스케줄 리스트 (AsyncValue 처리)
          schedulesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('오류 발생: $err')),
            data: (schedules) {
              if (schedules.isEmpty) {
                return const Center(child: Text('예약된 스케줄이 없습니다.'));
              }
              final now = DateTime.now();

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), // 버튼에 가리지 않게 여백 추가
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
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
                                '${DateFormat('yyyy-MM-dd').format(schedule.date)} ${schedule.startTime}',
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
                          onPressed: () async {
                            if (isPast) {
                              final memberId = schedule.memberId;
                              if (memberId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('오류: 회원 ID를 찾을 수 없습니다.')),
                                );
                                return;
                              }
                              try {
                                final log = await ref
                                    .read(workoutLogRepositoryProvider)
                                    .getLogBySchedule(memberId, DateFormat('yyyy-MM-dd').format(schedule.date));

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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            minimumSize: const Size(0, 32),
                            side: BorderSide(
                                color: isPast ? AppColors.primary : AppColors.disabled),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // 2. 닫기 버튼 위에 위치할 Floating Action Button (세션 추가 버튼)
          Positioned(
            bottom: 16,
            right: 0, // 오른쪽 정렬 (필요 시 조정)
            child: FloatingActionButton(
              mini: true, // 작고 동그랗게
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SessionAddDialog(member: member),
                );
              },
              child: const Icon(LucideIcons.plus, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}