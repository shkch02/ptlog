import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
//import '../data/mock_data.dart';
import '../models/index.dart';
import '../repositories/schedule_repository.dart';

// ------------------------------------------------------------------------
// 1. 월간 달력 다이얼로그
// ------------------------------------------------------------------------
class MonthlyCalendarDialog extends StatefulWidget {
  final DateTime focusedDay;
  final Function(DateTime) onDaySelected;

  const MonthlyCalendarDialog({
    super.key,
    required this.focusedDay,
    required this.onDaySelected,
  });

  @override
  State<MonthlyCalendarDialog> createState() => _MonthlyCalendarDialogState();
}

class _MonthlyCalendarDialogState extends State<MonthlyCalendarDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _selectedDay = widget.focusedDay;
  }

  @override
  Widget build(BuildContext context) {
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
              focusedDay: _focusedDay,
              currentDay: DateTime.now(), // 오늘 날짜 표시
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                  color: Colors.blue.withAlpha(77), // withOpacity(0.3)
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // 달력 페이지 유지를 위해 필요
                });
                widget.onDaySelected(selectedDay);
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
  }
}

// 2. 주간 시간표 다이얼로그
class WeeklyTimetableDialog extends StatefulWidget {
  final DateTime selectedDate;

  const WeeklyTimetableDialog({super.key, required this.selectedDate});

  @override
  State<WeeklyTimetableDialog> createState() => _WeeklyTimetableDialogState();
}

class _WeeklyTimetableDialogState extends State<WeeklyTimetableDialog> {
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  List<Schedule> _weeklySchedules = [];
  bool _isLoading = true;

  late DateTime _sunday;

  @override
  void initState() {
    super.initState();
    // 선택된 날짜가 속한 주의 일요일 구하기
    _sunday = widget.selectedDate.subtract(Duration(days: widget.selectedDate.weekday % 7));
    _fetchWeeklyData();
  }

  Future<void> _fetchWeeklyData() async {
    final saturday = _sunday.add(const Duration(days: 6));
    
    // Repository를 통해 데이터 가져오기
    final schedules = await _scheduleRepo.getWeeklySchedules(_sunday, saturday);

    if (mounted) {
      setState(() {
        _weeklySchedules = schedules;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const startHour = 9;
    const endHour = 22;

    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.maxFinite,
        height: 600,
        child: Column(
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('주간 시간표', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 10),
            
            // 로딩 중일 때 표시
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else ...[
              // 요일 헤더
              Row(
                children: [
                  const SizedBox(width: 40),
                  ...List.generate(7, (index) {
                    final day = _sunday.add(Duration(days: index));
                    final isToday = isSameDay(day, DateTime.now());
                    return Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isToday ? Colors.blue[50] : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
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

              // 시간표 바디
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(endHour - startHour + 1, (hourIndex) {
                      final currentHour = startHour + hourIndex;
                      
                      return Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: Row(
                          children: [
                            // 시간
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$currentHour:00',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // 셀
                            ...List.generate(7, (dayIndex) {
                              final cellDate = _sunday.add(Duration(days: dayIndex));
                              final cellDateStr = DateFormat('yyyy-MM-dd').format(cellDate);
                              
                              // [수정] _weeklySchedules 리스트에서 매칭 (mock 데이터 직접 접근 X)
                              final schedule = _weeklySchedules.firstWhere(
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
          ],
        ),
      ),
    );
  }
}