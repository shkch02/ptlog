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
