// 앱의 메인 홈 화면을 구성하는 위젯입니다.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/providers/home_providers.dart';
import '../models/index.dart';
import '../widgets/manual_session_dialog.dart';
import '../widgets/member_detail_dialog.dart';
import '../widgets/home_widgets.dart'; // ★ 분리한 위젯 import
import 'session_log_screen.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onGoToSchedule;
  const HomeScreen({super.key, required this.onGoToSchedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTodaySchedules = ref.watch(todaySchedulesProvider);
    final asyncAllMembers = ref.watch(membersForTrainerProvider);

    if (asyncTodaySchedules.isLoading || asyncAllMembers.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (asyncTodaySchedules.hasError || asyncAllMembers.hasError) {
      return const Center(child: Text('데이터 로드 실패'));
    }

    final schedules = asyncTodaySchedules.value!;
    final allMembers = asyncAllMembers.value!;
    
    // 현재 시간 (비교용)
    final nowTimeStr = DateFormat('HH:mm').format(DateTime.now());

    return Scaffold(
      body: Column(
        children: [
          // 1. 헤더 위젯
          HomeHeader(
            scheduleCount: schedules.length,
            onManualStartTap: () => _showManualSessionDialog(context, allMembers),
          ),
          
          const Divider(height: 1, color: AppColors.disabled),

          // 2. 리스트 영역
          Expanded(
            child: schedules.isEmpty
                ? const HomeEmptyView() // 빈 화면 위젯
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      final isPast = schedule.startTime.compareTo(nowTimeStr) < 0;

                      // memberId로 회원 조회하여 전화번호 가져오기
                      final member = _findMember(allMembers, schedule.memberId);

                      // 3. 스케줄 카드 위젯
                      return HomeScheduleCard(
                        schedule: schedule,
                        isPast: isPast,
                        memberPhone: member?.phone,
                        onMemberTap: () {
                          if (member != null) {
                            showDialog(
                              context: context,
                              builder: (context) => MemberDetailDialog(member: member),
                            );
                          }
                        },
                        onStartTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionLogScreen(schedule: schedule),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // memberId로 Member를 찾는 헬퍼 메서드
  Member? _findMember(List<Member> members, String? memberId) {
    if (memberId == null) return null;
    try {
      return members.firstWhere((m) => m.id == memberId);
    } catch (_) {
      return null;
    }
  }

  void _showManualSessionDialog(BuildContext context, List<Member> allMembers) {
    showDialog(
      context: context,
      builder: (context) => ManualSessionDialog(
        members: allMembers,
        onStart: (schedule) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionLogScreen(schedule: schedule),
            ),
          );
        },
      ),
    );
  }
}