import '../models/index.dart';
import '../data/mock_data.dart'; // 나중에는 이거 지우고 supabase import

class ScheduleRepository {
  // 특정 날짜의 스케줄 가져오기
  Future<List<Schedule>> getSchedulesByDate(String dateStr) async {
    // 백엔드 통신 흉내 (0.5초 딜레이)
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = mockSchedules.where((s) => s.date == dateStr).toList();
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  // 오늘 이후의 다가오는 스케줄 가져오기 (홈 화면용)
  Future<List<Schedule>> getUpcomingSchedules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    final todayStr = now.toString().split(' ')[0];

    // 오늘 날짜이면서 현재 시간 이후인 것 + 미래 날짜
    return mockSchedules.where((s) {
      if (s.date.compareTo(todayStr) < 0) return false; // 과거 날짜 제외
      if (s.date == todayStr) {
        // 시간 비교 로직 (간소화)
        final hour = int.parse(s.startTime.split(':')[0]);
        if (hour < now.hour) return false;
      }
      return true;
    }).toList();
  }
}