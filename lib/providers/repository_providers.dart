import 'package:ptlog/repositories/relation_repository.dart';
import 'package:ptlog/repositories/auth_repository.dart';
import 'package:ptlog/repositories/member_repository.dart';
import 'package:ptlog/repositories/schedule_repository.dart';
import '../repositories/workout_log_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref);
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref);
});

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  return WorkoutLogRepository();
});

// [신규] RelationRepository 프로바이더 추가
final relationRepositoryProvider = Provider<RelationRepository>((ref) {
  return RelationRepository(ref);
});
