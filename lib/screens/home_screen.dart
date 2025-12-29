import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/index.dart';
import '../widgets/manual_session_dialog.dart';
import '../widgets/upcoming_session_section.dart'; 
import '../widgets/renewal_needed_section.dart';   
import '../screens/session_log_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoToSchedule; // 스케줄 탭으로 이동하기 위한 콜백

  const HomeScreen({super.key, required this.onGoToSchedule});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 현재 시간 (데모용)
  final DateTime now = DateTime.now();

  // ------------------------------------------------------------------------
  // 기능: 수동 수업 시작 다이얼로그 호출
  // ------------------------------------------------------------------------
  void _showManualSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => ManualSessionDialog(
        members: mockMembers,
        // [수정] 다이얼로그에서 스케줄 정보를 받아 화면 이동
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

  @override
  Widget build(BuildContext context) {
    // 1. 임박한 세션 필터링 로직 (오늘 날짜 + 현재 시간 ~ 2시간 뒤)
    final upcomingSchedules = mockSchedules.where((schedule) {
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      if (schedule.date != todayStr) return false;

      final scheduleHour = int.parse(schedule.startTime.split(':')[0]);
      final currentHour = now.hour;
      
      return scheduleHour >= currentHour && scheduleHour <= currentHour + 2;
    }).toList();

    // 2. 재등록 필요 회원 (3회 이하)
    final renewalMembers = mockMembers.where((m) => m.remainingSessions <= 3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 수업 섹션 (데이터와 동작 전달)
          UpcomingSessionSection(
            schedules: upcomingSchedules,
            onManualStart: _showManualSessionDialog,
          ),

          // 스케줄 전체보기 버튼 (섹션 아래 배치)
          Center(
            child: TextButton(
              onPressed: widget.onGoToSchedule,
              child: const Text('전체 스케줄 확인하러 가기', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ),

          const SizedBox(height: 24),

          // 2. 재등록 섹션 (데이터 전달)
          RenewalNeededSection(members: renewalMembers),
        ],
      ),
    );
  }
}