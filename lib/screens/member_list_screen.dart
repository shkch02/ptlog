import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_data.dart'; // 더미 데이터
import '../models/index.dart'; // 모델

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  // 데이터 연동
  List<Member> members = mockMembers;
  String searchQuery = '';

  // ------------------------------------------------------------------------
  // 기능: 회원 상세 팝업 띄우기 (Source 2의 기능)
  // ------------------------------------------------------------------------
  void _showMemberDetail(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => MemberDetailDialog(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 검색 필터링
    final filteredMembers = members.where((member) =>
      member.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
      member.phone.contains(searchQuery) ||
      member.email.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. 헤더 (Source 1의 스타일 유지)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('회원 관리', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('총 ${members.length}명', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
              FilledButton.icon(
                onPressed: () {
                  // TODO: 회원 추가 다이얼로그
                },
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('추가'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 2. 검색 바 (Source 1 & 2 공통)
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: '이름, 전화번호 검색...',
              prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. 회원 목록 (Source 1의 상세한 디자인 + Source 2의 클릭 이벤트)
          Expanded(
            child: ListView.builder(
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];
                return _buildRichMemberCard(member);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Source 1의 상세한 카드 디자인을 위젯으로 분리
  Widget _buildRichMemberCard(Member member) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: InkWell(
        // 핵심: 여기서 팝업 호출 함수를 연결
        onTap: () => _showMemberDetail(context, member), 
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 프로필 + 이름 + 뱃지
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(member.profileImage ?? ''),
                    onBackgroundImageError: (_, __) {},
                    child: member.profileImage == null ? Text(member.name[0]) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        _buildSessionBadge(member.remainingSessions, member.totalSessions),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              
              // 정보 행들
              _buildInfoRow(LucideIcons.phone, member.phone),
              const SizedBox(height: 4),
              _buildInfoRow(LucideIcons.mail, member.email),
              const SizedBox(height: 4),
              _buildInfoRow(LucideIcons.calendar, '등록일: ${member.registrationDate}'),
              
              // 메모 경고창
              if (member.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertCircle, size: 16, color: Colors.amber[900]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(member.notes, style: TextStyle(fontSize: 12, color: Colors.amber[900]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 헬퍼 위젯: 아이콘 + 텍스트
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  // 헬퍼 위젯: 남은 횟수 뱃지
  Widget _buildSessionBadge(int remaining, int total) {
    final ratio = remaining / total;
    Color color = Colors.grey;
    Color bgColor = Colors.grey[100]!;
    
    if (ratio <= 0.2) {
      color = Colors.red;
      bgColor = Colors.red[50]!;
    } else if (ratio <= 0.5) {
      color = Colors.black;
      bgColor = Colors.grey[200]!;
    } else {
      color = Colors.blue[900]!;
      bgColor = Colors.blue[50]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$remaining/$total 회 남음',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// 팝업 다이얼로그 (Source 2의 상세 기능 전체 포함)
// ------------------------------------------------------------------------
class MemberDetailDialog extends StatefulWidget {
  final Member member;

  const MemberDetailDialog({super.key, required this.member});

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> {
  late TextEditingController _notesController;
  late List<Schedule> _memberSchedules;
  late List<PaymentLog> _memberPayments;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.member.notes);
    _memberSchedules = mockSchedules.where((s) => s.memberId == widget.member.id).toList();
    _memberPayments = mockPaymentLogs.where((p) => p.memberId == widget.member.id).toList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _editScheduleTime(Schedule schedule) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      setState(() {
        // UI 갱신 (실제 DB 연동 필요)
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${picked.format(context)}로 시간이 변경되었습니다 (더미)'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 600, // 팝업 높이 고정
        padding: const EdgeInsets.all(16),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // 팝업 헤더
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(widget.member.profileImage ?? ''),
                    onBackgroundImageError: (_, __) {},
                    child: widget.member.profileImage == null ? Text(widget.member.name[0]) : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.member.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(widget.member.phone, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 탭 바
              const TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: '정보/메모'),
                  Tab(text: '예약 관리'),
                  Tab(text: '결제/연동'),
                ],
              ),
              const SizedBox(height: 16),

              // 탭 내용물
              Expanded(
                child: TabBarView(
                  children: [
                    _buildInfoTab(),
                    _buildScheduleTab(),
                    _buildHistoryTab(),
                  ],
                ),
              ),
              
              // 닫기 버튼
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 탭 1: 메모 수정
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('특이사항 (메모)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: '회원의 특이사항을 입력하세요.',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메모가 저장되었습니다.'))
                );
              },
              child: const Text('메모 저장'),
            ),
          ),
        ],
      ),
    );
  }

  // 탭 2: 예약 목록
  Widget _buildScheduleTab() {
    if (_memberSchedules.isEmpty) {
      return const Center(child: Text('예약된 스케줄이 없습니다.'));
    }
    return ListView.builder(
      itemCount: _memberSchedules.length,
      itemBuilder: (context, index) {
        final schedule = _memberSchedules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: Colors.grey[50],
          child: ListTile(
            title: Text('${schedule.date} ${schedule.startTime}'),
            subtitle: Text(schedule.notes),
            trailing: IconButton(
              icon: const Icon(LucideIcons.edit2, size: 18),
              onPressed: () => _editScheduleTime(schedule),
            ),
          ),
        );
      },
    );
  }

  // 탭 3: 결제 이력
  Widget _buildHistoryTab() {
    if (_memberPayments.isEmpty) {
      return const Center(child: Text('결제/연동 이력이 없습니다.'));
    }
    return ListView.builder(
      itemCount: _memberPayments.length,
      itemBuilder: (context, index) {
        final log = _memberPayments[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: log.type == 'CRM연동' ? Colors.green[100] : Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              log.type == 'CRM연동' ? LucideIcons.link : LucideIcons.creditCard,
              size: 16,
              color: Colors.black87,
            ),
          ),
          title: Text(log.type, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${log.date} | ${log.content}'),
          trailing: Text(log.amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}