import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/index.dart';
import '../screens/session_log_screen.dart';

typedef OnMemberInfoTap = void Function(String memberId);

class UpcomingSessionSection extends StatelessWidget {
  final List<Schedule> schedules;
  final VoidCallback onManualStart;
  final String? emptyMessage;
  final OnMemberInfoTap onMemberInfoTap;

  const UpcomingSessionSection({
    super.key,
    required this.schedules,
    required this.onManualStart,
    this.emptyMessage,
    required this.onMemberInfoTap,
  });

  // 헤더 멘트 생성 로직 (수정됨)
  String _getDynamicHeaderText() {

    if (schedules.isEmpty) {
      return emptyMessage ?? '오늘 남은 수업이 없어요';
    }

    final now = DateTime.now();
    final firstSchedule = schedules.first;

    // 1. 현재 타임에 전달된 스케줄이 없는 경우 (빈 화면 or 수동 카드 상태)
    try {
      final timeParts = firstSchedule.startTime.split(':');
      final scheduleHour = int.parse(timeParts[0]);
      final scheduleMinute = int.parse(timeParts[1]);
      
      // 날짜까지 고려한 시간 비교
      final scheduleTime = DateTime(now.year, now.month, now.day, scheduleHour, scheduleMinute);
      final diffMinutes = scheduleTime.difference(now).inMinutes;

      if (diffMinutes > 0 && diffMinutes < 60) {
        return '$diffMinutes분 뒤에 수업이 있어요! ⏰';
      } else if (diffMinutes <= 0 && diffMinutes > -60) { // 수업 중
        return '수업 시작 시간이에요! 🔥';
      } else {
        return '오늘 예정된 수업이 있어요 💪';
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
        // 1. 동적 헤더 멘트
        Text(
          _getDynamicHeaderText(), 
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // 2. 데이터 유무에 따른 카드 표시 (그대로 유지)
        if (schedules.isEmpty)
          _buildManualStartCard()
        else
          ...schedules.take(1).map((schedule)   => _buildSessionCard(context, schedule)),
      ],
    );
  }

  Widget _buildManualStartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
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
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.dumbbell, size: 24, color: Colors.orange[800]),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '예약된 수업이 없나요?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '타 매체 예약이나 신규 회원을 위해\n바로 운동 일지를 시작할 수 있어요.',
                      style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.3),
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
              icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
              label: const Text('수동으로 수업 시작하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
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

  // 3. 예약된 세션 카드
  Widget _buildSessionCard(BuildContext context, Schedule schedule) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
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
            // 상단: 시간 및 예약 변경 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.clock, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${schedule.startTime} - ${schedule.endTime}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // 예약 수정 버튼
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
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.calendarSearch, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          '예약 수정',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 중단: 회원 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(schedule.memberName[0], style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${schedule.memberName} 회원님',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        schedule.notes.isNotEmpty ? schedule.notes : '특이사항 없음',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onMemberInfoTap(schedule.memberId),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: const [
                        Icon(LucideIcons.clipboardList, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "정보",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // 하단: 세션 시작 버튼
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
                icon: const Icon(LucideIcons.play, size: 20, color: Colors.blue),
                label: const Text('세션 시작하기', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
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