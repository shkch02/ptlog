import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/repositories/auth_repository.dart';
import 'package:ptlog/repositories/member_repository.dart';
import 'package:ptlog/repositories/schedule_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository();
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});
