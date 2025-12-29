import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
//import '../data/mock_data.dart';
import '../models/index.dart';
import '../repositories/schedule_repository.dart'; 
import '../repositories/member_repository.dart'; 

class MemberDetailDialog extends StatefulWidget {
  final Member member;

  const MemberDetailDialog({super.key, required this.member});

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _notesController;
  
  // Repository 인스턴스
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  final MemberRepository _memberRepo = MemberRepository();

  // 데이터 담을 변수
  List<Schedule> _memberSchedules = [];
  List<PaymentLog> _memberPayments = [];
  bool _isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notesController = TextEditingController(text: widget.member.notes);
    
    // 데이터 로딩 시작
    _loadAsyncData();
  }

  Future<void> _loadAsyncData() async {
    final results = await Future.wait([
      _scheduleRepo.getSchedulesByMember(widget.member.id),
      _memberRepo.getPaymentHistory(widget.member.id),
    ]);

    if (mounted) {
      setState(() {
        _memberSchedules = results[0] as List<Schedule>;
        _memberPayments = results[1] as List<PaymentLog>;
        _isLoading = false; // 로딩 완료
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 700, 
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 팝업 헤더 (여기는 member 정보가 이미 있어서 바로 그림)
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(widget.member.profileImage ?? ''),
                  onBackgroundImageError: (_, __) {},
                  child: widget.member.profileImage == null ? Text(widget.member.name[0]) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.member.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          _buildSessionBadge(widget.member.remainingSessions, widget.member.totalSessions),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(widget.member.phone, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
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

            // 탭 내용물 (로딩 중이면 로딩 표시)
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : TabBarView(
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

  // ----------------------------------------------------------------------
  // 탭 1: PT 세션
  // ----------------------------------------------------------------------
  Widget _buildPTSessionsTab() {
    if (_memberSchedules.isEmpty) {
      return const Center(child: Text('예약된 스케줄이 없습니다.'));
    }
    // ... (기존과 동일)
    final now = DateTime.now();
    return ListView.builder(
      itemCount: _memberSchedules.length,
      itemBuilder: (context, index) {
        final schedule = _memberSchedules[index];
        // ... (나머지 동일)
        DateTime scheduleTime;
        try {
          scheduleTime = DateFormat('yyyy-MM-dd HH:mm').parse('${schedule.date} ${schedule.startTime}');
        } catch (e) {
          scheduleTime = now;
        }
        final isPast = scheduleTime.isBefore(now);
        // ... (UI 리턴 부분 동일)
        return Container(
          // ... (스타일)
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isPast ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isPast ? Border.all(color: Colors.grey[300]!) : Border.all(color: Colors.blue[100]!, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${schedule.date} ${schedule.startTime}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isPast ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPast ? '완료' : (schedule.notes.isNotEmpty ? schedule.notes : '예약됨'),
                      style: TextStyle(
                        fontSize: 12, 
                        color: isPast ? Colors.grey : Colors.blue[800],
                        fontWeight: isPast ? FontWeight.normal : FontWeight.w600
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('보고서 기능 준비중')));
                },
                icon: Icon(LucideIcons.fileText, size: 14, color: isPast ? Colors.grey[600] : Colors.blue),
                label: Text('운동기록', style: TextStyle(fontSize: 12, color: isPast ? Colors.grey[600] : Colors.blue)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  side: BorderSide(color: isPast ? Colors.grey[400]! : Colors.blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // 탭 2: 기본 정보
  // ----------------------------------------------------------------------
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
                  _buildInfoRow(LucideIcons.cake, '나이', '28세'), // 더미
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.calendar, '등록일', widget.member.registrationDate),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4),
                child: Text('신체 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('InBody 데이터 연동 중...')));
                },
                icon: const Icon(LucideIcons.link, size: 14),
                label: const Text('InBody', style: TextStyle(fontSize: 12)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[700],
                ),
              ),
            ],
          ),
          Card(
            elevation: 0,
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildInfoRow(LucideIcons.ruler, '키', '175 cm'), 
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.dumbbell, '현재 체중', '72 kg'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.target, '목표 체중', '68 kg'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.percent, '현재 체지방', '18 %'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.zap, '현재 골격근량', '35 kg'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.trendingUp, '목표 골격근량', '38 kg'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.activity, '활동량', '보통'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.moon, '수면 시간', '7시간'),
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
          width: 90, 
          child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.right),
        ),
      ],
    );
  }

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
        '$remaining/$total 회',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
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