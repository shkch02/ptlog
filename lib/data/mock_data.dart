import 'package:intl/intl.dart';
import '../models/index.dart';

// 가정: 로그인한 트레이너의 ID는 'user1'
const String currentTrainerId = 'user1';

// 날짜 파싱을 위한 오늘 날짜 문자열
final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
final String tomorrow = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));


// ------------------------------------------------------------------------
// Mock Members (회원 정보는 이제 트레이너에게 종속되지 않음)
// ------------------------------------------------------------------------
List<Member> mockMembers = [
  Member(id: '1', name: '김민수', phone: '010-1234-5678', email: 'minsu.kim@example.com', remainingSessions: 8, totalSessions: 20, registrationDate: DateTime.parse('2024-11-01'), notes: '⚠️ [특이사항] 허리 디스크 병력 있음.', height: 178, weight: 78, targetWeight: 72, age: 32),
  Member(id: '2', name: '이영희', phone: '010-9876-5432', email: 'yh.lee@example.com', remainingSessions: 2, totalSessions: 30, registrationDate: DateTime.parse('2024-09-15'), notes: ' [목표] 3개월 내 체지방 5kg 감량 목표.', height: 165, weight: 58, targetWeight: 52, age: 29),
  Member(id: '3', name: '박지훈', phone: '010-5555-4444', email: 'jihoon.park@example.com', remainingSessions: 15, totalSessions: 20, registrationDate: DateTime.parse('2024-12-01'), notes: '운동 초보, 식단 관리 철저히 체크'),
  // ... 다른 회원 데이터
];

// ------------------------------------------------------------------------
// [신규] Mock Trainer-Member Relations (트레이너와 회원을 잇는 계약 관계)
// ------------------------------------------------------------------------
List<TrainerMemberRelation> mockTrainerMemberRelations = [
  // 'user1' 트레이너와 연결된 회원들
  TrainerMemberRelation(id: 'r1', trainerId: currentTrainerId, memberId: '1', startDate: DateTime.parse('2024-11-01'), isActive: true, memberName: '김민수', trainerName: '정교사'),
  TrainerMemberRelation(id: 'r2', trainerId: currentTrainerId, memberId: '2', startDate: DateTime.parse('2024-09-15'), isActive: true, memberName: '이영희', trainerName: '정교사'),
  TrainerMemberRelation(id: 'r3', trainerId: currentTrainerId, memberId: '3', startDate: DateTime.parse('2024-12-01'), isActive: true, memberName: '박지훈', trainerName: '정교사'),
  // (예시) 다른 트레이너('user2')와 연결된 회원
  TrainerMemberRelation(id: 'r4', trainerId: 'user2', memberId: '4', startDate: DateTime.parse('2024-10-20'), isActive: true, memberName: '최수진', trainerName: '김코치'),
];

// ------------------------------------------------------------------------
// Mock Schedules (이제 relationId를 통해 계약 관계에 종속됨)
// ------------------------------------------------------------------------
List<Schedule> mockSchedules = [
  Schedule(id: 's1', relationId: 'r1', memberId: '1', date: DateTime.parse(today), startTime: '09:00', endTime: '10:00', notes: '허리 디스크 병력 있음. 데드리프트 중량 치지 말 것', reminder: '10분 전 알림', memberName: '김민수'),
  Schedule(id: 's2', relationId: 'r2', memberId: '2', date: DateTime.parse(today), startTime: '15:00', endTime: '16:00', notes: '하체 비만 관리: 스쿼트 자세 교정 필요', reminder: '1시간 전 알림', memberName: '이영희'),
  Schedule(id: 's3', relationId: 'r1', memberId: '1', date: DateTime.parse(tomorrow), startTime: '10:00', endTime: '11:00', notes: '등 운동: 랫풀다운, 시티드 로우 (허리 조심)', reminder: '10분 전 알림', memberName: '김민수'),
];

// ------------------------------------------------------------------------
// Mock Payment Logs (마찬가지로 relationId 사용)
// ------------------------------------------------------------------------
List<PaymentLog> mockPaymentLogs = [
  PaymentLog(id: 'p1', relationId: 'r1', date: DateTime.parse('2024-12-01'), type: 'PT결제', content: 'PT 20회 재등록', amount: '1,200,000원'),
  PaymentLog(id: 'p2', relationId: 'r2', date: DateTime.parse('2024-12-10'), type: '회원권', content: '3개월 연장', amount: '270,000원'),
];

List<WorkoutLog> mockWorkoutLogs = [
  WorkoutLog(id: 'log_1', memberId: '1', memberName: '김민수', date: DateTime.parse(today), sessionNumber: 14, exercises: [], overallNotes: '전반적인 컨디션 양호. 다음 시간 데드리프트 예정.', reminderForNext: '스트랩 챙겨오기', photos: []),
];
