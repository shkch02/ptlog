import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_strings.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/providers/repository_providers.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/index.dart';

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
              locale: AppStrings.localeKo,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              currentDay: DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(77),
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
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

class WeeklyTimetableDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const WeeklyTimetableDialog({super.key, required this.selectedDate});

  @override
  ConsumerState<WeeklyTimetableDialog> createState() =>
      _WeeklyTimetableDialogState();
}

class _WeeklyTimetableDialogState extends ConsumerState<WeeklyTimetableDialog> {
  List<Schedule> _weeklySchedules = [];
  bool _isLoading = true;

  late DateTime _sunday;

  @override
  void initState() {
    super.initState();
    _sunday = widget.selectedDate
        .subtract(Duration(days: widget.selectedDate.weekday % 7));
    _fetchWeeklyData();
  }

  Future<void> _fetchWeeklyData() async {
    // [수정] getWeeklySchedules 메서드가 삭제되었으므로, 로직을 비활성화하고 항상 빈 리스트를 반환하도록 임시 수정
    // final scheduleRepo = ref.read(scheduleRepositoryProvider);
    // final saturday = _sunday.add(const Duration(days: 6));
    // final schedules = await scheduleRepo.getWeeklySchedules(_sunday, saturday);

    if (mounted) {
      setState(() {
        _weeklySchedules = []; // 항상 빈 리스트
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('주간 시간표', style: AppTextStyles.h3),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else ...[
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
                          color: isToday ? AppColors.primaryLight : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text(
                                DateFormat(AppStrings.dateFormatE,
                                        AppStrings.localeKo)
                                    .format(day),
                                style: AppTextStyles.button.copyWith(
                                    fontSize: 12,
                                    color: index == 0
                                        ? AppColors.danger
                                        : AppColors.black)),
                            Text(
                                DateFormat(AppStrings.dateFormatd).format(day),
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        List.generate(endHour - startHour + 1, (hourIndex) {
                      final currentHour = startHour + hourIndex;

                      return Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AppColors.disabled)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$currentHour:00',
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ...List.generate(7, (dayIndex) {
                              final cellDate =
                                  _sunday.add(Duration(days: dayIndex));
                              final cellDateStr =
                                  DateFormat(AppStrings.dateFormatYmd)
                                      .format(cellDate);

                              final schedule = _weeklySchedules.firstWhere(
                                (s) {
                                  final sHour =
                                      int.tryParse(s.startTime.split(':')[0]) ??
                                          -1;
                                  return s.date == cellDateStr &&
                                      sHour == currentHour;
                                },
                                orElse: () => Schedule(
                                    id: '',
                                    relationId: '',
                                    date: '',
                                    startTime: '',
                                    endTime: '',
                                    notes: '',
                                    reminder: ''),
                              );

                              final hasSchedule = schedule.id.isNotEmpty;

                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: hasSchedule
                                        ? AppColors.primaryLight
                                        : null,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: hasSchedule
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              schedule.memberName ?? '', // [수정] Null 처리
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              schedule.startTime,
                                              style: AppTextStyles.caption
                                                  .copyWith(fontSize: 9),
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