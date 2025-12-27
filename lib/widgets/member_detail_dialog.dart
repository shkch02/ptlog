import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/index.dart';

class MemberDetailDialog extends StatefulWidget {
  final Member member;

  const MemberDetailDialog({super.key, required this.member});

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _notesController;
  late List<Schedule> _memberSchedules;
  late List<PaymentLog> _memberPayments;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notesController = TextEditingController(text: widget.member.notes);
    
    // 데이터 로드 및 정렬 (최신순)
    _memberSchedules = mockSchedules.where((s) => s.memberId == widget.member.id).toList();
    _memberSchedules.sort((a, b) {
      String dtA = '${a.date} ${a.startTime}';
      String dtB = '${b.date} ${b.startTime}';
      return dtB.compareTo(dtA);
    });

    _memberPayments = mockPaymentLogs.where((p) => p.memberId == widget.member.id).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        height: 650,
        padding: const EdgeInsets.all(16),
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
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'PT세션'),
                Tab(text: '기본정보'),
                Tab(text: '상세메모'),
                Tab(text: '결제'),
              ],
            ),
            const SizedBox(height: 16),

            // 탭 내용물
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPTSessionsTab(),
                  _buildBasicInfoTab(),
                  _buildDetailedMemoTab(),
                  _buildPaymentTab(),
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
    );
  }

  // 탭 1: PT 세션
  Widget _buildPTSessionsTab() {
    if (_memberSchedules.isEmpty) {
      return const Center(child: Text('예약된 스케줄이 없습니다.'));
    }

    final now = DateTime.now();

    return ListView.builder(
      itemCount: _memberSchedules.length,
      itemBuilder: (context, index) {
        final schedule = _memberSchedules[index];
        
        DateTime scheduleTime;
        try {
          scheduleTime = DateFormat('yyyy-MM-dd HH:mm').parse('${schedule.date} ${schedule.startTime}');
        } catch (e) {
          scheduleTime = now;
        }

        final isPast = scheduleTime.isBefore(now);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isPast ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: isPast ? null : Border.all(color: Colors.blue[100]!),
            boxShadow: isPast ? null : [
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            dense: true,
            title: Text(
              '${schedule.date} ${schedule.startTime}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPast ? Colors.grey[600] : Colors.black87,
                decoration: isPast ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              isPast ? '완료된 세션' : (schedule.notes.isNotEmpty ? schedule.notes : '예약됨'),
              style: TextStyle(color: isPast ? Colors.grey : Colors.blue[800]),
            ),
            trailing: isPast 
              ? const Icon(LucideIcons.checkCircle, size: 18, color: Colors.grey)
              : IconButton(
                  icon: const Icon(LucideIcons.edit2, size: 18, color: Colors.blue),
                  onPressed: () => _editScheduleTime(schedule),
                ),
          ),
        );
      },
    );
  }

  // 탭 2: 기본 정보
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('인적사항'),
          Card(
            elevation: 0,
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildInfoRow(LucideIcons.user, '이름', widget.member.name),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.phone, '전화번호', widget.member.phone),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.mail, '이메일', widget.member.email),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.calendar, '등록일', widget.member.registrationDate),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSectionTitle('신체 정보'),
          Card(
            elevation: 0,
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildInfoRow(LucideIcons.ruler, '키', '175 cm'), 
                  const Divider(height: 16),
                  // 수정됨: LucideIcons.weight -> LucideIcons.dumbbell
                  _buildInfoRow(LucideIcons.dumbbell, '몸무게', '72 kg'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.activity, 'BMI', '23.5 (정상)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  // 탭 3: 상세 메모
  Widget _buildDetailedMemoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[100]!),
            ),
            // 수정됨: const 키워드 제거 (Colors.amber[900] 때문)
            child: Row(
              children: [
                Icon(LucideIcons.info, size: 16, color: Colors.amber[900]),
                const SizedBox(width: 8),
                Expanded(child: Text('회원의 특이사항, 부상 이력 등을 기록하세요.', style: TextStyle(fontSize: 12, color: Colors.amber[900]))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 12,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: '내용을 입력하세요...',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메모가 저장되었습니다.'))
                );
              },
              icon: const Icon(LucideIcons.save, size: 16),
              label: const Text('메모 저장'),
            ),
          ),
        ],
      ),
    );
  }

  // 탭 4: 결제
  Widget _buildPaymentTab() {
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