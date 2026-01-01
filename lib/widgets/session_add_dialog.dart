import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/index.dart';
import 'package:ptlog/providers/repository_providers.dart';
import 'package:ptlog/providers/schedule_providers.dart'; // invalidate용

class SessionAddDialog extends ConsumerStatefulWidget {
  final Member member; // 대상 회원

  const SessionAddDialog({super.key, required this.member});

  @override
  ConsumerState<SessionAddDialog> createState() => _SessionAddDialogState();
}

class _SessionAddDialogState extends ConsumerState<SessionAddDialog> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  final int _durationMinutes = 50; // 기본 수업 시간 50분

  bool _isChecking = false; // 중복 체크 로딩 상태

  // 날짜 선택
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // 시간 선택
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  // 저장 로직
  Future<void> _save() async {
    setState(() => _isChecking = true);

    final repo = ref.read(scheduleRepositoryProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // 시작 시간 포맷팅 (HH:mm)
    final startHour = _startTime.hour.toString().padLeft(2, '0');
    final startMin = _startTime.minute.toString().padLeft(2, '0');
    final startTimeStr = '$startHour:$startMin';

    // 종료 시간 계산
    final startDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day, 
      _startTime.hour, _startTime.minute
    );
    final endDateTime = startDateTime.add(Duration(minutes: _durationMinutes));
    final endHour = endDateTime.hour.toString().padLeft(2, '0');
    final endMin = endDateTime.minute.toString().padLeft(2, '0');
    final endTimeStr = '$endHour:$endMin';

    // 1. 중복 체크
    final hasConflict = await repo.checkConflict(dateStr, startTimeStr, endTimeStr);

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

    // 2. 일정 객체 생성
    final newSchedule = Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: widget.member.id,
      memberName: widget.member.name,
      date: dateStr,
      startTime: startTimeStr,
      endTime: endTimeStr,
      notes: 'PT 수업',
      reminder: '1시간 전',
    );

    // 3. 저장 및 갱신
    await repo.addSchedule(newSchedule);
    
    // 해당 회원의 스케줄 목록 갱신 (PtSessionsTab이 다시 빌드됨)
    ref.invalidate(memberSchedulesProvider(widget.member.id));

    if (!mounted) return;
    Navigator.pop(context); // 다이얼로그 닫기
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('새로운 PT 일정이 등록되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate);
    final timeStr = _startTime.format(context);

    return AlertDialog(
      title: const Text('새 PT 세션 예약', style: AppTextStyles.h3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('날짜'),
            subtitle: Text(dateStr, style: AppTextStyles.body),
            trailing: const Icon(Icons.calendar_today, size: 20),
            onTap: _pickDate,
            tileColor: AppColors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('시작 시간'),
            subtitle: Text(timeStr, style: AppTextStyles.body),
            trailing: const Icon(Icons.access_time, size: 20),
            onTap: _pickTime,
            tileColor: AppColors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(height: 12),
          const Text('기본 수업 시간은 50분입니다.', style: AppTextStyles.caption),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: AppColors.textLight)),
        ),
        ElevatedButton(
          onPressed: _isChecking ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isChecking 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('예약하기'),
        ),
      ],
    );
  }
}