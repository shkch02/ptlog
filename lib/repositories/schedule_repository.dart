import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/constants/app_strings.dart';
import '../models/index.dart';
import '../data/mock_data.dart';
import 'package:intl/intl.dart';

class ScheduleRepository {
  final Ref ref;
  ScheduleRepository(this.ref);

  Future<List<Schedule>> getSchedulesByDate(String dateStr) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = mockSchedules.where((s) => s.date == dateStr).toList();
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  Future<List<Schedule>> getUpcomingSchedules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    final todayStr = DateFormat(AppStrings.dateFormatYmd).format(now);

    final todaySchedules = mockSchedules.where((s) {
      if (s.date != todayStr) return false;
      
      final timeParts = s.startTime.split(':');
      DateTime(
        now.year, now.month, now.day, 
        int.parse(timeParts[0]), int.parse(timeParts[1])
      );
      
      return true; 
    }).toList();

    todaySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    final filtered = todaySchedules.where((s) {
      final timeParts = s.startTime.split(':');
      final sHour = int.parse(timeParts[0]);
      final sMinute = int.parse(timeParts[1]);
      final sTime = DateTime(now.year, now.month, now.day, sHour, sMinute);

      if (sTime.add(const Duration(hours: 1)).isBefore(now)) return false;

      return true;
    }).toList();

    if (filtered.isEmpty) return [];

    final firstSchedule = filtered.first;
    final timeParts = firstSchedule.startTime.split(':');
    final startHour = int.parse(timeParts[0]);

    if (startHour == now.hour) {
      return [firstSchedule];
    }
    
    if (startHour == now.hour + 1) {
      return [firstSchedule];
    }

    return [];
  }

  Future<String?> getNextSessionHint() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    final todayStr = DateFormat(AppStrings.dateFormatYmd).format(now);

    final todayFutures = mockSchedules.where((s) {
      if (s.date != todayStr) return false;
      
      final timeParts = s.startTime.split(':');
      final sTime = DateTime(
        now.year, now.month, now.day, 
        int.parse(timeParts[0]), int.parse(timeParts[1])
      );
      
      return sTime.isAfter(now);
    }).toList();

    if (todayFutures.isEmpty) {
      return '오늘은 예약된 세션이 없습니다 🌙';
    }

    todayFutures.sort((a, b) => a.startTime.compareTo(b.startTime));
    final next = todayFutures.first;
    final hour = int.parse(next.startTime.split(':')[0]);

    return '$hour시에 수업이 있어요 ⏳'; 
  }

  Future<String?> getNextSessionTime() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final futureSchedules = mockSchedules.where((s) {
       return true; 
    }).toList();

    if (futureSchedules.isNotEmpty) {
      futureSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      final next = futureSchedules.first;
      final hour = int.parse(next.startTime.split(':')[0]);
      return '$hour시에 수업이 있어요 ⏳';
    }
    
    return null;
  }

  Future<List<Schedule>> getSchedulesByMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final memberSchedules = mockSchedules.where((s) => s.memberId == memberId).toList();
    
    memberSchedules.sort((a, b) {
      String dtA = '${a.date} ${a.startTime}';
      String dtB = '${b.date} ${b.startTime}';
      return dtA.compareTo(dtB); 
    });
    
    return memberSchedules;
  }

  Future<List<Schedule>> getWeeklySchedules(DateTime startDay, DateTime endDay) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final startStr = startDay.toString().split(' ')[0];
    final endStr = endDay.toString().split(' ')[0];

    return mockSchedules.where((s) {
      return s.date.compareTo(startStr) >= 0 && s.date.compareTo(endStr) <= 0;
    }).toList();
  }
}