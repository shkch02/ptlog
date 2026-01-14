// 세션 추가 다이얼로그 위젯
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/index.dart';
import 'package:ptlog/providers/home_providers.dart';
import 'package:ptlog/providers/repository_providers.dart';
import 'package:ptlog/providers/schedule_providers.dart';

class SessionAddDialog extends ConsumerStatefulWidget {
  final Member member;

  const SessionAddDialog({super.key, required this.member});

  @override
  ConsumerState<SessionAddDialog> createState() => _SessionAddDialogState();
}

class _SessionAddDialogState extends ConsumerState<SessionAddDialog> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  final int _durationMinutes = 50;

  bool _isChecking = false;

  // 30분 간격 시간 슬롯 생성 (06:00 ~ 23:00)
  List<TimeOfDay> get _timeSlots {
    final slots = <TimeOfDay>[];
    for (int hour = 6; hour <= 23; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
      if (hour < 23) {
        slots.add(TimeOfDay(hour: hour, minute: 30));
      }
    }
    return slots;
  }

  // 날짜 이동
  void _changeDate(int days) {
    final newDate = _selectedDate.add(Duration(days: days));
    final now = DateTime.now();
    final minDate = now.subtract(const Duration(days: 1));
    final maxDate = now.add(const Duration(days: 90));

    if (newDate.isAfter(minDate) && newDate.isBefore(maxDate)) {
      setState(() => _selectedDate = newDate);
    }
  }

  // 날짜 선택 (DatePicker)
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // 저장 로직 (기존 유지)
  Future<void> _save() async {
    setState(() => _isChecking = true);

    final repo = ref.read(scheduleRepositoryProvider);

    // 시작 시간 포맷팅 (HH:mm)
    final startHour = _startTime.hour.toString().padLeft(2, '0');
    final startMin = _startTime.minute.toString().padLeft(2, '0');
    final startTimeStr = '$startHour:$startMin';

    // 종료 시간 계산
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = startDateTime.add(Duration(minutes: _durationMinutes));
    final endHour = endDateTime.hour.toString().padLeft(2, '0');
    final endMin = endDateTime.minute.toString().padLeft(2, '0');
    final endTimeStr = '$endHour:$endMin';

    // 1. 현재 트레이너와 회원 사이의 활성 관계(relation) 찾기
    final trainerId = ref.read(currentTrainerIdProvider);
    final relation = await ref.read(relationRepositoryProvider).getActiveRelation(
      trainerId: trainerId,
      memberId: widget.member.id,
    );

    if (relation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오류: 회원과의 활성 계약 관계를 찾을 수 없습니다.')),
        );
      }
      setState(() => _isChecking = false);
      return;
    }

    // 2. 중복 체크 (트레이너 ID와 함께)
    final hasConflict = await repo.checkConflictForTrainer(
      trainerId,
      _selectedDate,
      startTimeStr,
      endTimeStr,
    );

    setState(() => _isChecking = false);

    if (hasConflict) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('해당 시간에 이미 다른 일정이 있습니다!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. 일정 객체 생성 (relationId 사용)
    final newSchedule = Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      relationId: relation.id,
      date: _selectedDate,
      startTime: startTimeStr,
      endTime: endTimeStr,
      notes: 'PT 수업',
      reminder: '1시간 전',
      memberName: widget.member.name,
    );

    // 4. 저장 및 갱신
    await repo.addSchedule(newSchedule);

    ref.invalidate(memberSchedulesHistoryProvider(widget.member.id));

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('새로운 PT 일정이 등록되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('M월 d일 (E)', 'ko_KR').format(_selectedDate);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 580),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('새 PT 세션 예약', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.member.name} 회원',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 날짜 선택
            Text(
              '날짜',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _buildDateSelector(dateStr),
            const SizedBox(height: 20),

            // 시간 선택
            Text(
              '시작 시간',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // 시간 그리드
            Expanded(
              child: _buildTimeGrid(),
            ),

            const SizedBox(height: 12),
            Text(
              '기본 수업 시간: $_durationMinutes분',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),

            // 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isChecking ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('예약하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(String dateStr) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _changeDate(-1),
            icon: const Icon(LucideIcons.chevronLeft, size: 20),
          ),
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: AppTextStyles.subtitle1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeDate(1),
            icon: const Icon(LucideIcons.chevronRight, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _timeSlots.map((time) {
          final isSelected =
              time.hour == _startTime.hour && time.minute == _startTime.minute;
          final timeStr =
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

          return GestureDetector(
            onTap: () => setState(() => _startTime = time),
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.disabled,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  timeStr,
                  style: AppTextStyles.button.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
