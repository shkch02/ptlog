import 'package:ptlog/repositories/relation_repository.dart';
import 'package:ptlog/repositories/auth_repository.dart';
import 'package:ptlog/repositories/member_repository.dart';
import 'package:ptlog/repositories/schedule_repository.dart';
import '../repositories/workout_log_repository.dart';
// 앱의 데이터 리포지토리를 제공하는 프로바이더를 정의합니다.
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  // MemberRepository에 RelationRepository를 주입합니다.
  return MemberRepository(ref.watch(relationRepositoryProvider));
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  // ScheduleRepository에 RelationRepository를 주입합니다.
  return ScheduleRepository(ref.watch(relationRepositoryProvider));
});

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  return WorkoutLogRepository();
});

// [신규] RelationRepository 프로바이더 추가
final relationRepositoryProvider = Provider<RelationRepository>((ref) {
  return RelationRepository();
});
