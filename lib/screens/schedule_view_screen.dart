import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/index.dart';
import '../repositories/schedule_repository.dart'; // [수정] Repository import
import '../widgets/schedule_dialogs.dart';

class ScheduleViewScreen extends StatefulWidget {
  const ScheduleViewScreen({super.key});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> {
  // [수정] Repository 인스턴스 생성
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  
  DateTime _selectedDate = DateTime.now();
  
  // [수정] 상태 관리 변수 추가
  List<Schedule> _dailySchedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _fetchSchedules(); // [수정] 데이터 로드 시작
  }

  // [수정] 비동기로 데이터 가져오기
  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true); // 로딩 시작

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final schedules = await _scheduleRepo.getSchedulesByDate(dateStr);

    if (mounted) {
      setState(() {
        _dailySchedules = schedules;
        _isLoading = false; // 로딩 끝
      });
    }
  }

  String get _formattedHeaderDate {
    return DateFormat('MM/dd(E)', 'ko_KR').format(_selectedDate);
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _fetchSchedules(); // [수정] 날짜 변경 시 데이터 다시 조회
  }

  @override
  Widget build(BuildContext context) {
    // [삭제] 여기서 직접 mockSchedules 필터링하던 로직 제거됨

    return Column(
      children: [
        // -----------------------------------------------------------
        // 1. 상단 헤더
        // -----------------------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // (1) 주간 시간표 버튼
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => WeeklyTimetableDialog(selectedDate: _selectedDate),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.layoutGrid, size: 24, color: Colors.black54),
                          const SizedBox(height: 2),
                          Text('주간', style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // (2) 날짜 이동 컨트롤러
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, size: 20),
                      onPressed: () => _changeDate(-1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        _formattedHeaderDate,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.chevronRight, size: 20),
                      onPressed: () => _changeDate(1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
              ),

              // (3) 월간 달력 버튼
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => MonthlyCalendarDialog(
                          focusedDay: _selectedDate,
                          onDaySelected: (newDate) {
                            setState(() => _selectedDate = newDate);
                            _fetchSchedules(); // [수정] 달력에서 날짜 선택 시에도 다시 조회
                          },
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.calendar, size: 24, color: Colors.blue),
                          const SizedBox(height: 2),
                          const Text('월간', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // -----------------------------------------------------------
        // 2. 스케줄 리스트 바디
        // -----------------------------------------------------------
        Expanded(
          // [수정] 로딩 중일 때와 아닐 때 분기 처리
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _dailySchedules.isEmpty
                  ? _buildEmptyView()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _dailySchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _dailySchedules[index];
                        return _buildScheduleCard(schedule);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.calendarX, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '예약된 스케줄이 없습니다.',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus),
            label: const Text('일정 추가하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    // ... (기존 카드 위젯 코드 그대로 유지) ...
    // (아래 코드는 생략합니다. 기존 코드 그대로 쓰시면 됩니다.)
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    schedule.startTime,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    schedule.endTime,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                height: 40,
                width: 4,
                decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.memberName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.notes,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}