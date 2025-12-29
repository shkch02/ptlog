import 'package:flutter/material.dart';
import '../models/index.dart';
import '../repositories/schedule_repository.dart'; // Repository import
import '../repositories/member_repository.dart';   // Repository import
import '../widgets/manual_session_dialog.dart';
import '../widgets/upcoming_session_section.dart';
import '../widgets/renewal_needed_section.dart';
import '../widgets/member_detail_dialog.dart';
import 'session_log_screen.dart';


class HomeScreen extends StatefulWidget {
  final VoidCallback onGoToSchedule;
  const HomeScreen({super.key, required this.onGoToSchedule});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Repository 인스턴스 생성
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  final MemberRepository _memberRepo = MemberRepository();

  // 데이터 담을 변수 (FutureBuilder 써도 되지만, 직관적인 initState 방식 사용)
  List<Schedule> _upcomingSchedules = [];
  List<Member> _renewalMembers = [];
  List<Member> _allMembers = []; // 다이얼로그용
  bool _isLoading = true;
  String? _nextSessionMessage;

  @override
  void initState() {
    super.initState();
    _loadData(); // 데이터 로딩 시작
  }

  // 비동기로 데이터 가져오기
  Future<void> _loadData() async {
    // 여러 데이터를 동시에 요청 (병렬 처리)
    final results = await Future.wait([
      _scheduleRepo.getUpcomingSchedules(),
      _memberRepo.getRenewalNeededMembers(),
      _memberRepo.getAllMembers(),
      _scheduleRepo.getNextSessionHint(),
    ]);

    if (mounted) {
      setState(() {
        _upcomingSchedules = results[0] as List<Schedule>;
        _renewalMembers = results[1] as List<Member>;
        _allMembers = results[2] as List<Member>;
        _nextSessionMessage = results[3] as String?;
        _isLoading = false;
      });
    }
  }

  void _showManualSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => ManualSessionDialog(
        members: _allMembers, // Repository에서 가져온 데이터 전달
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); // 로딩 중 표시
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UpcomingSessionSection(
            schedules: _upcomingSchedules,
            onManualStart: _showManualSessionDialog,
            emptyMessage: _nextSessionMessage,

            onMemberInfoTap: (memberId) {
              try {
                // 이미 로딩된 _allMembers 리스트에서 찾음 (Repository 안 써도 됨)
                final member = _allMembers.firstWhere((m) => m.id == memberId);
                
                showDialog(
                  context: context,
                  builder: (context) => MemberDetailDialog(member: member),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('회원 정보를 찾을 수 없습니다.')),
                );
              }
            },
          ),
          Center(
            child: TextButton(
              onPressed: widget.onGoToSchedule,
              child: const Text('전체 스케줄 확인하러 가기', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 24),
          RenewalNeededSection(members: _renewalMembers),
        ],
      ),
    );
  }
}