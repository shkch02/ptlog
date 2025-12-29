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

  Future<String?> getNextSessionHint() async {
    // 나중엔 DB 쿼리로 '오늘 날짜 & 현재 시간 이후' 중 가장 빠른 1개 조회로 변경
    await Future.delayed(const Duration(milliseconds: 100)); // 모의 지연
    
    final now = DateTime.now();
    final todayStr = now.toString().split(' ')[0];

    // 오늘 날짜의 미래 스케줄 필터링
    final futureSchedules = mockSchedules.where((s) {
      if (s.date != todayStr) return false;
      try {
        final timeParts = s.startTime.split(':');
        final scheduleDate = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
        return scheduleDate.isAfter(now);
      } catch (e) {
        return false;
      }
    }).toList();

    if (futureSchedules.isNotEmpty) {
      futureSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      final next = futureSchedules.first;
      final hour = int.parse(next.startTime.split(':')[0]);
      return '$hour시에 수업이 있어요 ⏳';
    }
    
    return null; // 오늘 남은 수업 없음
  }

  Future<String?> getNextSessionTime() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 전체 스케줄 중에서 미래 수업 하나 찾기
    // (여기서는 mockSchedules를 쓰지만 나중엔 DB 쿼리로 변경됨)
    final futureSchedules = mockSchedules.where((s) {
       // ... 날짜/시간 비교 로직 ...
       return true; 
    }).toList();

    if (futureSchedules.isNotEmpty) {
      futureSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      final next = futureSchedules.first;
      final hour = int.parse(next.startTime.split(':')[0]);
      return '$hour시에 수업이 있어요 ⏳';
    }
    
    return null; // 미래 수업도 없음
  }

  Future<List<Schedule>> getSchedulesByMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final memberSchedules = mockSchedules.where((s) => s.memberId == memberId).toList();
    
    // 과거 -> 미래 순으로 정렬
    memberSchedules.sort((a, b) {
      String dtA = '${a.date} ${a.startTime}';
      String dtB = '${b.date} ${b.startTime}';
      return dtA.compareTo(dtB); 
    });
    
    return memberSchedules;
  }

  Future<List<Schedule>> getWeeklySchedules(DateTime startDay, DateTime endDay) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 날짜 문자열 변환
    final startStr = startDay.toString().split(' ')[0];
    final endStr = endDay.toString().split(' ')[0];

    return mockSchedules.where((s) {
      // 문자열 비교 (yyyy-MM-dd는 사전순 비교 가능)
      return s.date.compareTo(startStr) >= 0 && s.date.compareTo(endStr) <= 0;
    }).toList();
  }
}