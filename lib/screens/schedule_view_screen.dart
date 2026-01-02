import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_strings.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/providers/home_providers.dart'; // [추가]
import 'package:ptlog/providers/schedule_providers.dart';
import '../models/index.dart';
import '../widgets/schedule_dialogs.dart';

class ScheduleViewScreen extends ConsumerStatefulWidget {
  const ScheduleViewScreen({super.key});

  @override
  ConsumerState<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends ConsumerState<ScheduleViewScreen> {
  DateTime _selectedDate = DateTime.now();

  String get _formattedHeaderDate {
    return DateFormat(AppStrings.dateFormatMdE, AppStrings.localeKo)
        .format(_selectedDate);
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Normalize the date to avoid unnecessary rebuilds
    final normalizedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    // [수정] provider 호출 방식 변경
    final trainerId = ref.watch(currentTrainerIdProvider);
    final asyncSchedules = ref.watch(schedulesByDateProvider((trainerId: trainerId, date: normalizedDate)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            WeeklyTimetableDialog(selectedDate: _selectedDate),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.layoutGrid,
                              size: 24, color: AppColors.textPrimary),
                          const SizedBox(height: 2),
                          Text('주간',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, size: 20),
                      onPressed: () => _changeDate(-1),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        _formattedHeaderDate,
                        style: AppTextStyles.h3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.chevronRight, size: 20),
                      onPressed: () => _changeDate(1),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
              ),
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
                          const Icon(LucideIcons.calendar,
                              size: 24, color: AppColors.primary),
                          const SizedBox(height: 2),
                          Text('월간',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
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
        Expanded(
          child: asyncSchedules.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (schedules) {
              if (schedules.isEmpty) {
                return _buildEmptyView();
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return _buildScheduleCard(schedule);
                },
              );
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
          const Icon(LucideIcons.calendarX,
              size: 48, color: AppColors.disabled),
          const SizedBox(height: 16),
          Text(
            '예약된 스케줄이 없습니다.',
            style: AppTextStyles.subtitle1
                .copyWith(color: AppColors.disabledText),
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
        side: const BorderSide(color: AppColors.disabled),
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
                    style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                  ),
                  Text(
                    schedule.endTime,
                    style: AppTextStyles.subtitle2
                        .copyWith(color: AppColors.disabledText),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                height: 40,
                width: 4,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.memberName ?? '이름 없음', // [수정] Null 처리
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.notes,
                      style: AppTextStyles.subtitle2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight,
                  color: AppColors.textLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}