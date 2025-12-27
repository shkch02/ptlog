import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
  }

  String get _formattedHeaderDate {
    return DateFormat('MM/dd(E)', 'ko_KR').format(_selectedDate);
  }

  String get _selectedDateString {
    return DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  // ------------------------------------------------------------------------
  // 1. 월간 달력 팝업 (기존 기능)
  // ------------------------------------------------------------------------
  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
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
                    Navigator.pop(context);
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

  // ------------------------------------------------------------------------
  // 2. 주간 일정표 팝업 (새로 추가된 기능)
  // ------------------------------------------------------------------------
  void _showWeeklyTimetableDialog() {
    // 선택된 날짜가 속한 주의 일요일 구하기
    // weekday: Mon(1) ... Sun(7). Sunday Start 기준이므로 % 7 사용.
    final sunday = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
    
    // 표시할 시간 범위 (예: 09시 ~ 22시)
    final startHour = 9;
    final endHour = 22;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10), // 화면 꽉 차게
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.maxFinite,
            height: 600,
            child: Column(
              children: [
                // 팝업 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('주간 시간표', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 10),
                
                // 시간표 헤더 (요일 표시)
                Row(
                  children: [
                    const SizedBox(width: 40), // 시간축 공간 확보
                    ...List.generate(7, (index) {
                      final day = sunday.add(Duration(days: index));
                      final isToday = isSameDay(day, DateTime.now());
                      return Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: isToday ? Colors.blue[50] : null,
                          child: Column(
                            children: [
                              Text(DateFormat('E', 'ko_KR').format(day), 
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: index == 0 ? Colors.red : Colors.black)),
                              Text(DateFormat('dd').format(day), 
                                style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const Divider(height: 1),

                // 시간표 바디 (스크롤 가능)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(endHour - startHour + 1, (hourIndex) {
                        final currentHour = startHour + hourIndex; // 9, 10, 11...
                        
                        return Container(
                          height: 60, // 각 시간 슬롯 높이
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                          ),
                          child: Row(
                            children: [
                              // 시간 표시 열
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '$currentHour:00',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // 7일치 그리드 셀
                              ...List.generate(7, (dayIndex) {
                                final cellDate = sunday.add(Duration(days: dayIndex));
                                final cellDateStr = DateFormat('yyyy-MM-dd').format(cellDate);
                                
                                // 해당 날짜 & 해당 시간에 일치하는 스케줄 찾기
                                // mockData의 startTime은 "10:00" 형식이므로 앞 2자리 파싱
                                final schedule = mockSchedules.firstWhere(
                                  (s) {
                                    final sHour = int.tryParse(s.startTime.split(':')[0]) ?? -1;
                                    return s.date == cellDateStr && sHour == currentHour;
                                  },
                                  orElse: () => Schedule(id: '', memberId: '', memberName: '', date: '', startTime: '', endTime: '', notes: '', reminder: ''),
                                );

                                final hasSchedule = schedule.id.isNotEmpty;

                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: hasSchedule ? Colors.blue[100] : null,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: hasSchedule
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                schedule.memberName,
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                schedule.startTime,
                                                style: const TextStyle(fontSize: 9),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
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
    final dailySchedules = mockSchedules
        .where((schedule) => schedule.date == _selectedDateString)
        .toList();

    dailySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      children: [
        // 상단 날짜 네비게이션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // 1. 왼쪽: 주간 시간표 팝업 버튼 (New)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(LucideIcons.layoutGrid, size: 24), // 그리드 아이콘 사용
                    color: Colors.black54,
                    tooltip: '주간 시간표 보기',
                    onPressed: _showWeeklyTimetableDialog,
                  ),
                ),
              ),

              // 2. 가운데: 날짜 이동 컨트롤러
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

              // 3. 오른쪽: 달력 팝업 버튼 (Existing)
              Expanded(
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

        // 스케줄 리스트 바디
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