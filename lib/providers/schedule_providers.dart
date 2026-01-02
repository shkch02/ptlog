import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ptlog/models/index.dart';
import 'package:ptlog/providers/home_providers.dart';
import 'package:ptlog/providers/repository_providers.dart';

// [수정] Family의 파라미터로 trainerId와 date를 함께 받기 위해 Record 사용
final schedulesByDateProvider =
    FutureProvider.family<List<Schedule>, ({String trainerId, DateTime date})>((ref, params) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  final dateStr = DateFormat('yyyy-MM-dd').format(params.date);
  return scheduleRepo.getSchedulesForTrainerByDate(params.trainerId, dateStr);
});

// [의미 명확화] 특정 회원의 모든 스케줄 이력을 가져옴 (여러 트레이너에게 받은 수업 포함)
final memberSchedulesHistoryProvider = FutureProvider.family<List<Schedule>, String>((ref, memberId) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  return scheduleRepo.getSchedulesByMember(memberId);
});
