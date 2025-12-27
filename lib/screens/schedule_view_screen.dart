import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // 한국어 포맷 지원용
import 'package:table_calendar/table_calendar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/index.dart';
import '../data/mock_data.dart';

class ScheduleViewScreen extends StatefulWidget {
  const ScheduleViewScreen({super.key});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> {
  DateTime _selectedDate = DateTime.now(); //보고있는 날짜 지정 변수, 초기값은 오늘 날짜

  @override
  void initState() {
    super.initState();
    // 한국어 날짜 포맷 초기화 (앱 시작시 한 번만 해도 되지만 여기서 안전하게 호출)
    initializeDateFormatting('ko_KR', null);
  }

  // 날짜 포맷 (예: 12/11(목))을 보여주기위한 getter
  String get _formattedHeaderDate { 
    return DateFormat('MM/dd(E)', 'ko_KR').format(_selectedDate);
  }

  // DB에 저장된 날짜 포맷과 비교하기 위한 문자열 (yyyy-MM-dd)
  String get _selectedDateString {
    return DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  // 날짜 이동 함수
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  // 달력 팝업 띄우기
  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
              children: [
                TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false, // 2주/주간 버튼 숨김
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                    Navigator.pop(context); // 선택 후 팝업 닫기
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜에 해당하는 스케줄 필터링
    final dailySchedules = mockSchedules
        .where((schedule) => schedule.date == _selectedDateString)
        .toList();

    // 시간순 정렬
    dailySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      children: [
        // 1. 상단 날짜 네비게이션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Expanded(child: SizedBox()), //왼쪽 공간 확보

              // 날짜 이동 컨트롤러
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
              Expanded(
              // 달력 팝업 버튼
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(LucideIcons.calendar, size: 28),
                    color: Colors.blue,
                    onPressed: _showCalendarDialog,
                  ),
                ),
              ),
            ],  
          ),
        ),
        const Divider(height: 1),

        // 2. 스케줄 리스트 바디
        Expanded(
          child: dailySchedules.isEmpty
              ? _buildEmptyView()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dailySchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = dailySchedules[index];
                    return _buildScheduleCard(schedule);
                  },
                ),
        ),
      ],
    );
  }

  // 스케줄 없음 뷰
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
            onPressed: () {
              // TODO: 스케줄 추가 기능 연결
            },
            icon: const Icon(LucideIcons.plus),
            label: const Text('일정 추가하기'),
          ),
        ],
      ),
    );
  }

  // 스케줄 카드 위젯
  Widget _buildScheduleCard(Schedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          // TODO: 일정 상세 보기
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 시간 표시
              Column(
                children: [
                  Text(
                    schedule.startTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    schedule.endTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // 구분선
              Container(
                height: 40,
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.memberName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.notes,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 상태 아이콘 (예: 완료 여부 등)
              const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}