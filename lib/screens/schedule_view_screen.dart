import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_strings.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/providers/home_providers.dart';
import 'package:ptlog/providers/schedule_providers.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/index.dart';
import '../widgets/schedule_dialogs.dart';

class ScheduleViewScreen extends ConsumerStatefulWidget {
  const ScheduleViewScreen({super.key});

  @override
  ConsumerState<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends ConsumerState<ScheduleViewScreen> {
  late DateTime _weekStart; // 현재 주의 일요일

  static const int _startHour = 6;
  static const int _endHour = 23;

  @override
  void initState() {
    super.initState();
    _weekStart = _getSundayOfWeek(DateTime.now());
  }

  // 주어진 날짜가 속한 주의 일요일을 반환
  DateTime _getSundayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  // 주 단위 이동
  void _changeWeek(int weeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: weeks * 7));
    });
  }

  // 특정 날짜로 이동 (월간 캘린더에서 선택 시)
  void _goToDate(DateTime date) {
    setState(() {
      _weekStart = _getSundayOfWeek(date);
    });
  }

  String get _formattedWeekRange {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final startStr = DateFormat('M/d', AppStrings.localeKo).format(_weekStart);
    final endStr = DateFormat('M/d', AppStrings.localeKo).format(weekEnd);
    return '$startStr - $endStr';
  }

  // 스케줄 리스트를 Map<날짜, Map<시간, Schedule>>로 변환하여 O(1) 조회 가능하게 함
  Map<String, Map<int, Schedule>> _preprocessSchedules(List<Schedule> schedules) {
    final Map<String, Map<int, Schedule>> scheduleMap = {};

    for (final schedule in schedules) {
      final dateStr = DateFormat('yyyy-MM-dd').format(schedule.date);
      final hour = int.tryParse(schedule.startTime.split(':')[0]) ?? -1;

      if (hour >= 0) {
        scheduleMap.putIfAbsent(dateStr, () => {});
        scheduleMap[dateStr]![hour] = schedule;
      }
    }

    return scheduleMap;
  }

  @override
  Widget build(BuildContext context) {
    final trainerId = ref.watch(currentTrainerIdProvider);
    final asyncSchedules = ref.watch(
      weeklySchedulesProvider((trainerId: trainerId, weekStart: _weekStart)),
    );

    return Column(
      children: [
        // 상단 네비게이션 바
        _buildHeader(context),
        const Divider(height: 1),
        // 주간 그리드
        Expanded(
          child: asyncSchedules.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (schedules) => _buildWeeklyGrid(schedules),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // 오늘 버튼
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _weekStart = _getSundayOfWeek(DateTime.now());
                  });
                },
                icon: const Icon(LucideIcons.calendarCheck, size: 18),
                label: const Text('오늘'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ),
          // 주 네비게이션
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft, size: 20),
                  onPressed: () => _changeWeek(-1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    _formattedWeekRange,
                    style: AppTextStyles.h3,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight, size: 20),
                  onPressed: () => _changeWeek(1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),
          ),
          // 월간 캘린더 버튼
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => MonthlyCalendarDialog(
                      focusedDay: _weekStart,
                      onDaySelected: (newDate) {
                        _goToDate(newDate);
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
                      const Icon(LucideIcons.calendar, size: 24, color: AppColors.primary),
                      const SizedBox(height: 2),
                      Text(
                        '월간',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGrid(List<Schedule> schedules) {
    final today = DateTime.now();
    final scheduleMap = _preprocessSchedules(schedules);

    return Column(
      children: [
        // 요일 헤더
        _buildDayHeader(today),
        const Divider(height: 1),
        // 시간표 그리드
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 시간 열
                _buildTimeColumn(),
                // 7일 열
                ...List.generate(7, (dayIndex) {
                  final cellDate = _weekStart.add(Duration(days: dayIndex));
                  final isToday = isSameDay(cellDate, today);
                  return Expanded(
                    child: _buildDayColumn(cellDate, scheduleMap, isToday),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayHeader(DateTime today) {
    return Row(
      children: [
        const SizedBox(width: 44), // 시간 열 공간
        ...List.generate(7, (index) {
          final day = _weekStart.add(Duration(days: index));
          final isToday = isSameDay(day, today);
          final isSunday = index == 0;
          final isSaturday = index == 6;

          Color textColor = AppColors.textPrimary;
          if (isSunday) textColor = AppColors.danger;
          if (isSaturday) textColor = AppColors.primary;

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isToday ? AppColors.primaryLight : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat(AppStrings.dateFormatE, AppStrings.localeKo).format(day),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.primary : textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat('d').format(day),
                      style: AppTextStyles.subtitle2.copyWith(
                        color: isToday ? AppColors.white : textColor,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: 44,
      child: Column(
        children: List.generate(_endHour - _startHour + 1, (index) {
          final hour = _startHour + index;
          return Container(
            height: 60,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$hour',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(DateTime cellDate, Map<String, Map<int, Schedule>> scheduleMap, bool isToday) {
    final cellDateStr = DateFormat('yyyy-MM-dd').format(cellDate);
    final daySchedules = scheduleMap[cellDateStr];

    return Container(
      decoration: BoxDecoration(
        color: isToday ? AppColors.primaryLight.withOpacity(0.3) : null,
        border: Border(
          left: BorderSide(color: AppColors.disabled.withOpacity(0.5), width: 0.5),
        ),
      ),
      child: Column(
        children: List.generate(_endHour - _startHour + 1, (hourIndex) {
          final currentHour = _startHour + hourIndex;

          // O(1) 맵 조회로 해당 시간의 스케줄 확인
          final schedule = daySchedules?[currentHour];
          final hasSchedule = schedule != null;

          return GestureDetector(
            onTap: () {
              if (hasSchedule) {
                _showEditSessionDialog(schedule);
              } else {
                _showAddSessionDialog(cellDate, currentHour);
              }
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.disabled.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
              ),
              child: hasSchedule
                  ? _buildScheduleCell(schedule)
                  : _buildEmptyCell(isToday),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildScheduleCell(Schedule schedule) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            schedule.memberName ?? '',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            '${schedule.startTime} - ${schedule.endTime}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCell(bool isToday) {
    return Container(
      color: isToday ? Colors.transparent : null,
    );
  }

  void _showAddSessionDialog(DateTime date, int hour) {
    final timeStr = '${hour.toString().padLeft(2, '0')}:00';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('세션 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '날짜: ${DateFormat('yyyy년 M월 d일 (E)', AppStrings.localeKo).format(date)}',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 8),
            Text(
              '시간: $timeStr',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 16),
            const Text(
              '이 시간에 새 세션을 추가하시겠습니까?',
              style: AppTextStyles.body,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 실제 세션 추가 로직 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('세션 추가 기능은 추후 구현 예정입니다.')),
              );
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showEditSessionDialog(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('세션 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '회원: ${schedule.memberName ?? "이름 없음"}',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 8),
            Text(
              '날짜: ${DateFormat('yyyy년 M월 d일 (E)', AppStrings.localeKo).format(schedule.date)}',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 4),
            Text(
              '시간: ${schedule.startTime} - ${schedule.endTime}',
              style: AppTextStyles.body,
            ),
            if (schedule.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '메모: ${schedule.notes}',
                style: AppTextStyles.body,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 실제 세션 삭제 로직 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('세션 삭제 기능은 추후 구현 예정입니다.')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('삭제'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 실제 세션 수정 로직 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('세션 수정 기능은 추후 구현 예정입니다.')),
              );
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }
}
