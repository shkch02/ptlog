import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/index.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoToSchedule; // 스케줄 탭으로 이동하기 위한 콜백

  const HomeScreen({super.key, required this.onGoToSchedule});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 현재 시간 (데모용)
  final DateTime now = DateTime.now();

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
          // 상단: 곧 시작하는 세션
          const Text('곧 시작하는 수업 🔥', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          if (upcomingSchedules.isEmpty)
            _buildEmptyStateCard()
          else
            ...upcomingSchedules.map((schedule) => _buildSessionCard(schedule)),

          const SizedBox(height: 32),

          // 하단: 재등록 요망 회원
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('재등록 관심 필요 🤔', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Chip(
                label: Text('${renewalMembers.length}명', style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.red[400],
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              )
            ],
          ),
          const SizedBox(height: 12),
          
          if (renewalMembers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('모든 회원의 세션이 넉넉합니다! 🎉', style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: renewalMembers.length,
              itemBuilder: (context, index) {
                final member = renewalMembers[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red[50],
                      child: Text(member.name[0], style: TextStyle(color: Colors.red[800])),
                    ),
                    title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('남은 횟수: ${member.remainingSessions}회'),
                    trailing: FilledButton.tonal(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 32)
                      ),
                      child: const Text('연락'),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.coffee, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('2시간 이내 예정된 수업이 없습니다.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: widget.onGoToSchedule, 
            child: const Text('전체 스케줄 확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Schedule schedule) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                const Icon(LucideIcons.moreHorizontal, color: Colors.white70),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(schedule.memberName[0], style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${schedule.memberName} 회원님',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      schedule.notes.isNotEmpty ? schedule.notes : '특이사항 없음',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.play, size: 18, color: Colors.blue),
                label: const Text('세션 시작하기', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}