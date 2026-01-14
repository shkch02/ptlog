// 홈 화면의 상태(예: 선택된 날짜)를 관리하는 프로바이더를 정의합니다.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/data/mock_data.dart';
import 'package:ptlog/models/index.dart';
import 'package:ptlog/providers/repository_providers.dart';
import 'package:intl/intl.dart'; 

// 가정: 현재 로그인한 트레이너의 ID를 제공하는 Provider.
// 실제 앱에서는 로그인 상태를 관리하는 Provider가 이 역할을 대신해야 합니다.
final currentTrainerIdProvider = Provider<String>((ref) {
  return currentTrainerId; // mock_data.dart에 정의된 상수
});

// [수정] 특정 트레이너의 다음 스케줄
final upcomingSchedulesProvider = FutureProvider<List<Schedule>>((ref) async {
  final trainerId = ref.watch(currentTrainerIdProvider);
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  return scheduleRepo.getUpcomingSchedulesForTrainer(trainerId);
});

// [수정] 특정 트레이너의 만료 임박 회원
final renewalMembersProvider = FutureProvider<List<Member>>((ref) async {
  final trainerId = ref.watch(currentTrainerIdProvider);
  final memberRepo = ref.watch(memberRepositoryProvider);
  return memberRepo.getRenewalNeededMembersForTrainer(trainerId);
});

// [수정] 특정 트레이너의 전체 회원 목록
final membersForTrainerProvider = FutureProvider<List<Member>>((ref) async {
  final trainerId = ref.watch(currentTrainerIdProvider);
  final memberRepo = ref.watch(memberRepositoryProvider);
  return memberRepo.getMembersForTrainer(trainerId);
});

// [수정] 특정 트레이너의 다음 세션 힌트
final nextSessionMessageProvider = FutureProvider<String?>((ref) async {
  final trainerId = ref.watch(currentTrainerIdProvider);
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  return scheduleRepo.getNextSessionHintForTrainer(trainerId);
});

//오늘 날짜의 전체 스케줄을 가져오는 Provider
final todaySchedulesProvider = FutureProvider<List<Schedule>>((ref) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  
  // 1. 오늘 날짜 구하기 (yyyy-MM-dd)
  final now = DateTime.now();
  final todayStr = DateFormat('yyyy-MM-dd').format(now); 
  
  // 2. 트레이너 ID 가져오기
  final trainerId = ref.watch(currentTrainerIdProvider); 

  // 3. 만들어둔 메서드 호출 (이것이 에러를 해결하고 로직을 통합하는 핵심입니다)
  return await scheduleRepo.getSchedulesForTrainerByDate(trainerId, todayStr);
});
