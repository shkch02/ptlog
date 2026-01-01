// lib/repositories/workout_log_repository.dart
import '../models/index.dart';
import '../data/mock_data.dart'; // 데이터 소스는 Repository만 알고 있음

class WorkoutLogRepository {
  Future<List<WorkoutLog>> getWorkoutLogs() async {
    // 실제로는 API 호출
    await Future.delayed(const Duration(milliseconds: 300));
    return mockWorkoutLogs;
  }

  // 특정 스케줄(날짜+멤버)에 해당하는 로그 찾기
  Future<WorkoutLog?> getLogBySchedule(String memberId, String date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockWorkoutLogs.firstWhere(
        (log) => log.memberId == memberId && log.date == date,
      );
    } catch (e) {
      return null;
    }
  }
}