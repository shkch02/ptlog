import 'package:ptlog/constants/app_strings.dart';
import 'package:ptlog/repositories/relation_repository.dart';
import '../models/index.dart';
import '../data/mock_data.dart';
import 'package:intl/intl.dart';

class ScheduleRepository {
  final RelationRepository _relationRepository;
  ScheduleRepository(this._relationRepository);

  // [시그니처 변경] 특정 트레이너의 하루 스케줄을 가져옴
  Future<List<Schedule>> getSchedulesForTrainerByDate(String trainerId, String dateStr) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final relations = await _relationRepository.getActiveRelationsForTrainer(trainerId);
    final relationIds = relations.map((r) => r.id).toSet();

    final filtered = mockSchedules.where((s) {
      // s.date (DateTime)를 'yyyy-MM-dd' 형식의 문자열로 변환하여 비교
      return DateFormat(AppStrings.dateFormatYmd).format(s.date) == dateStr && relationIds.contains(s.relationId);
    }).toList();
    
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  // [시그니처 변경] 특정 트레이너의 다음 스케줄을 가져옴
  Future<List<Schedule>> getUpcomingSchedulesForTrainer(String trainerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    
    final relations = await _relationRepository.getActiveRelationsForTrainer(trainerId);
    final relationIds = relations.map((r) => r.id).toSet();

    final todaySchedules = mockSchedules.where((s) {
      // DateTime 객체의 년/월/일이 같은지 직접 비교
      return s.date.year == now.year &&
             s.date.month == now.month &&
             s.date.day == now.day &&
             relationIds.contains(s.relationId);
    }).toList();

    todaySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    // ... (기존의 시간 필터링 로직은 대부분 재사용 가능)
    final filtered = todaySchedules.where((s) {
      final timeParts = s.startTime.split(':');
      final sHour = int.parse(timeParts[0]);
      final sMinute = int.parse(timeParts[1]);
      final sTime = DateTime(now.year, now.month, now.day, sHour, sMinute);
      return sTime.add(const Duration(hours: 1)).isAfter(now);
    }).toList();

    return filtered.take(1).toList(); // 1개만 반환
  }

  // [시그니처 변경] 특정 트레이너의 다음 세션 힌트를 가져옴
  Future<String?> getNextSessionHintForTrainer(String trainerId) async {
    final upcoming = await getUpcomingSchedulesForTrainer(trainerId);
    if (upcoming.isEmpty) {
      return '오늘은 예약된 세션이 없습니다 🌙';
    }
    final next = upcoming.first;
    final hour = int.parse(next.startTime.split(':')[0]);
    return '$hour시에 수업이 있어요 ⏳';
  }

  // [로직 변경] 특정 회원의 모든 스케줄을 가져옴 (여러 트레이너에게 받은 이력 포함)
  Future<List<Schedule>> getSchedulesByMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 1. 회원의 모든 관계(relation)를 찾음 (과거 이력 포함)
    final allRelations = mockTrainerMemberRelations.where((r) => r.memberId == memberId);
    final relationIds = allRelations.map((r) => r.id).toSet();

    // 2. 해당 관계 ID를 가진 모든 스케줄을 찾음
    final memberSchedules = mockSchedules.where((s) => relationIds.contains(s.relationId)).toList();
    
    memberSchedules.sort((a, b) {
      // DateTime과 시간(String)을 조합하여 비교
      final aTimeParts = a.startTime.split(':');
      final aDateTime = a.date.add(Duration(hours: int.parse(aTimeParts[0]), minutes: int.parse(aTimeParts[1])));

      final bTimeParts = b.startTime.split(':');
      final bDateTime = b.date.add(Duration(hours: int.parse(bTimeParts[0]), minutes: int.parse(bTimeParts[1])));
      
      return bDateTime.compareTo(aDateTime); 
    });
    
    return memberSchedules;
  }

  // [시그니처 변경] 특정 트레이너의 스케줄 충돌을 확인
  Future<bool> checkConflictForTrainer(String trainerId, DateTime date, String startTime, String endTime) async {
    final relations = await _relationRepository.getActiveRelationsForTrainer(trainerId);
    final relationIds = relations.map((r) => r.id).toSet();

    final daySchedules = mockSchedules.where((s) {
      return s.date.year == date.year &&
             s.date.month == date.month &&
             s.date.day == date.day &&
             relationIds.contains(s.relationId);
    }).toList();

    int toMinutes(String time) {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final newStart = toMinutes(startTime);
    final newEnd = toMinutes(endTime);

    for (var s in daySchedules) {
      final existingStart = toMinutes(s.startTime);
      final existingEnd = toMinutes(s.endTime);
      if (existingStart < newEnd && existingEnd > newStart) {
        return true;
      }
    }
    return false;
  }

  // [변경 없음] 추가하는 Schedule 객체에 이미 relationId가 있다고 가정
  Future<void> addSchedule(Schedule schedule) async {
    await Future.delayed(const Duration(milliseconds: 300));
    mockSchedules.add(schedule);
  }
}
