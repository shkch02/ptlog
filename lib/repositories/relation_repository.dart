import 'package:ptlog/data/mock_data.dart';
import 'package:ptlog/models/trainer_member_relation.dart';

class RelationRepository {
  RelationRepository();

  // 특정 트레이너의 모든 활성 관계(계약) 목록 가져오기
  Future<List<TrainerMemberRelation>> getActiveRelationsForTrainer(String trainerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockTrainerMemberRelations
        .where((r) => r.trainerId == trainerId && r.isActive)
        .toList();
  }

  // (예시) 새로운 관계 생성
  Future<TrainerMemberRelation> createRelation(String trainerId, String memberId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newRelation = TrainerMemberRelation(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      trainerId: trainerId,
      memberId: memberId,
      startDate: DateTime.now(),
      isActive: true,
      // JOIN된 데이터는 실제 백엔드에서 채워줘야 함
      memberName: mockMembers.firstWhere((m) => m.id == memberId).name,
      trainerName: '트레이너', // 예시
    );
    mockTrainerMemberRelations.add(newRelation);
    return newRelation;
  }

  // (예시) 관계 비활성화
  Future<void> deactivateRelation(String relationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = mockTrainerMemberRelations.indexWhere((r) => r.id == relationId);
    if (index != -1) {
      final original = mockTrainerMemberRelations[index];
      mockTrainerMemberRelations[index] = original.copyWith(
        isActive: false,
        endDate: DateTime.now(),
      );
    }
  }

  // [신규] 특정 트레이너와 회원 사이의 활성 관계를 찾는 메서드
  Future<TrainerMemberRelation?> getActiveRelation({
    required String trainerId,
    required String memberId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return mockTrainerMemberRelations.firstWhere(
        (r) => r.trainerId == trainerId && r.memberId == memberId && r.isActive,
      );
    } catch (e) {
      return null; // 활성 관계가 없으면 null 반환
    }
  }
}
