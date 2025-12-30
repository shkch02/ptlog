import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/models/index.dart';
import 'package:ptlog/providers/repository_providers.dart';

final upcomingSchedulesProvider = FutureProvider<List<Schedule>>((ref) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  return scheduleRepo.getUpcomingSchedules();
});

final renewalMembersProvider = FutureProvider<List<Member>>((ref) async {
  final memberRepo = ref.watch(memberRepositoryProvider);
  return memberRepo.getRenewalNeededMembers();
});

final allMembersProvider = FutureProvider<List<Member>>((ref) async {
  final memberRepo = ref.watch(memberRepositoryProvider);
  return memberRepo.getAllMembers();
});

final nextSessionMessageProvider = FutureProvider<String?>((ref) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  return scheduleRepo.getNextSessionHint();
});
