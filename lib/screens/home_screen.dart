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

  // ------------------------------------------------------------------------
  // 기능: 수동 수업 시작 다이얼로그 (회원 선택 -> 시작)
  // ------------------------------------------------------------------------
  void _showManualSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수동 수업 시작'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('수업을 진행할 회원을 선택해주세요.', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              // 간단한 회원 리스트 (실제로는 검색 기능이 있으면 좋음)
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: mockMembers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final member = mockMembers[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(member.profileImage ?? ''),
                        onBackgroundImageError: (_, __) {},
                        child: member.profileImage == null ? Text(member.name[0]) : null,
                      ),
                      title: Text(member.name),
                      trailing: const Icon(LucideIcons.chevronRight, size: 16),
                      onTap: () {
                        Navigator.pop(context); // 팝업 닫기
                        // TODO: 여기서 선택된 회원(member) 정보를 가지고 운동 일지 작성 화면으로 이동
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${member.name} 회원님과 수동 수업을 시작합니다.')),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
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
          // 상단 제목
          const Text('곧 시작하는 수업 🔥', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // ---------------------------------------------------------------
          // 상황별 카드 표시
          // 1. 예약된 수업이 없을 때 -> 수동 시작 카드 (요청하신 기능)
          // 2. 예약된 수업이 있을 때 -> 해당 수업 정보 카드
          // ---------------------------------------------------------------
          if (upcomingSchedules.isEmpty)
            _buildManualStartCard() // 여기가 변경된 부분입니다.
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

  // ------------------------------------------------------------------------
  // 위젯: 수동 수업 시작 카드 (예약 없을 때 표시)
  // ------------------------------------------------------------------------
  Widget _buildManualStartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!), // 옅은 파란 테두리
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)
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
              onPressed: _showManualSessionDialog, // 회원 선택 팝업 호출
              icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
              label: const Text('수동으로 수업 시작하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, // 강조색 (남색)
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 기존의 스케줄 확인 버튼은 보조 버튼으로 유지
          TextButton(
            onPressed: widget.onGoToSchedule,
            child: const Text('전체 스케줄 확인하러 가기', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // 위젯: 예약된 세션 카드 (기존 유지)
  // ------------------------------------------------------------------------
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('세션을 시작합니다! 운동 일지로 이동합니다.')),
                  );
                },
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