import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ptlog/models/index.dart';
import 'package:ptlog/providers/repository_providers.dart';

final schedulesByDateProvider =
    FutureProvider.family<List<Schedule>, DateTime>((ref, date) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  final dateStr = DateFormat('yyyy-MM-dd').format(date);
  return scheduleRepo.getSchedulesByDate(dateStr);
});

// 특정 회원의 스케줄 목록을 관리하는 Provider
// (일정 추가 시 ref.invalidate(memberSchedulesProvider(id))를 호출하여 목록을 갱신합니다)
final memberSchedulesProvider = FutureProvider.family<List<Schedule>, String>((ref, memberId) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  return scheduleRepo.getSchedulesByMember(memberId);
});