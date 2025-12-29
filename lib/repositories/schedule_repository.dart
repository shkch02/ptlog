import '../models/index.dart';
import '../data/mock_data.dart'; // 나중에는 이거 지우고 supabase import
import 'package:intl/intl.dart';

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
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // 1. 오늘 날짜의 '미래(혹은 현재 진행중)' 스케줄을 모두 가져옴
    final todaySchedules = mockSchedules.where((s) {
      if (s.date != todayStr) return false;
      
      final timeParts = s.startTime.split(':');
      final scheduleTime = DateTime(
        now.year, now.month, now.day, 
        int.parse(timeParts[0]), int.parse(timeParts[1])
      );
      
      // 수업 시작 시간이 현재 시간보다 이후이거나, 
      // 현재 시간과 같은 시(hour)인 경우 (즉, 14:10인데 14:00 수업이면 표시)
      // 단, 정확한 비즈니스 로직에 따라 '종료 시간'을 체크해야 할 수도 있음.
      // 여기서는 심플하게 '현재 시각 이후의 수업' + '같은 시간대 수업'을 포함
      
      // 더 정확히: "현재 시각 < 수업 시작 시간 + 1시간(수업시간)" 이면 진행 중으로 볼 수 있음.
      // 여기서는 요청하신 대로 "시간" 기준으로 판단.
      return true; 
    }).toList();

    // 시간순 정렬
    todaySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    // 유효한 스케줄 필터링 (현재 시간 기준)
    final filtered = todaySchedules.where((s) {
      final timeParts = s.startTime.split(':');
      final sHour = int.parse(timeParts[0]);
      final sMinute = int.parse(timeParts[1]);
      final sTime = DateTime(now.year, now.month, now.day, sHour, sMinute);

      // 이미 지나간 수업(1시간 이상 지남)은 제외 (예: 지금 15:00인데 13:00 수업)
      if (sTime.add(const Duration(hours: 1)).isBefore(now)) return false;

      return true;
    }).toList();

    if (filtered.isEmpty) return [];

    final firstSchedule = filtered.first;
    final timeParts = firstSchedule.startTime.split(':');
    final startHour = int.parse(timeParts[0]);

    // [핵심 조건 적용]
    // 1. 현재 시각(hour)과 수업 시작 시각(hour)이 같으면 -> 표시 (현재 세션)
    if (startHour == now.hour) {
      return [firstSchedule];
    }
    
    // 2. 현재 시각 바로 다음 시각(now.hour + 1)에 시작하는 수업이면 -> 표시 (다음 타임)
    if (startHour == now.hour + 1) {
      return [firstSchedule];
    }

    // 3. 그 외 (gap이 있는 경우) -> 빈 리스트 반환 (수동 시작 버튼 뜨게 함)
    return [];
  }

  // [수정] 빈 화면일 때 띄울 멘트 가져오기
  Future<String?> getNextSessionHint() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // 오늘 남은 수업 찾기
    final todayFutures = mockSchedules.where((s) {
      if (s.date != todayStr) return false;
      
      final timeParts = s.startTime.split(':');
      final sTime = DateTime(
        now.year, now.month, now.day, 
        int.parse(timeParts[0]), int.parse(timeParts[1])
      );
      
      return sTime.isAfter(now); // 진짜 미래 수업만
    }).toList();

    if (todayFutures.isEmpty) {
      return '오늘은 예약된 세션이 없습니다 🌙'; // [조건 4] 오늘 더 이상 없음
    }

    todayFutures.sort((a, b) => a.startTime.compareTo(b.startTime));
    final next = todayFutures.first;
    final hour = int.parse(next.startTime.split(':')[0]);

    // [조건 3] 오늘 수업은 있지만, 바로 다음 타임은 아님
    return '$hour시에 수업이 있어요 ⏳'; 
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