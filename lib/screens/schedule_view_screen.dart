import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/index.dart';
import '../data/mock_data.dart';
import '../widgets/schedule_dialogs.dart'; // ★ 분리한 위젯 import

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

  @override
  Widget build(BuildContext context) {
    // 데이터 필터링
    final dailySchedules = mockSchedules
        .where((schedule) => schedule.date == _selectedDateString)
        .toList();

    dailySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      children: [
        // -----------------------------------------------------------
        // 1. 상단 헤더 (버튼 디자인 변경됨)
        // -----------------------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // (1) 주간 시간표 버튼 (아이콘 + 텍스트)
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

              // (3) 월간 달력 버튼 (아이콘 + 텍스트)
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