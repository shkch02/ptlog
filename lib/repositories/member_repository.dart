import 'package:ptlog/repositories/relation_repository.dart';

import '../models/index.dart';
import '../data/mock_data.dart';

class MemberRepository {
  final RelationRepository _relationRepository;
  MemberRepository(this._relationRepository);

  // [신규] 특정 트레이너에게 소속된 활성 회원 목록을 가져오는 메서드
  Future<List<Member>> getMembersForTrainer(String trainerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 1. 트레이너에게 속한 활성 관계(relation)들을 찾음
    final relations = await _relationRepository.getActiveRelationsForTrainer(trainerId);
    final memberIds = relations.map((r) => r.memberId).toSet();

    // 2. 해당 ID를 가진 회원 정보들을 반환
    return mockMembers.where((m) => memberIds.contains(m.id)).toList();
  }

  // [의미 변경] 이제 시스템의 '모든' 회원을 가져옴 (회원 검색 등에서 사용)
  Future<List<Member>> getAllMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(mockMembers);
  }

  // [로직 변경 필요] 이제 특정 트레이너의 회원들 중에서 만료 임박 회원을 찾아야 함
  Future<List<Member>> getRenewalNeededMembersForTrainer(String trainerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final myMembers = await getMembersForTrainer(trainerId);
    return myMembers.where((m) => m.remainingSessions <= 3).toList();
  }

  // [삭제 또는 변경] memberId 대신 relationId를 사용해야 하므로 이 메서드는 유효하지 않음
  // Future<List<PaymentLog>> getPaymentHistory(String memberId) async { ... }
  // -> PaymentLogRepository 또는 RelationRepository에서 처리하는 것이 적합

  // 회원 메모 업데이트 (이 기능은 Member 객체 자체를 수정하므로 변경 없음)
  Future<void> updateMemberNotes(String memberId, String newNotes) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final index = mockMembers.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final updatedMember = mockMembers[index].copyWith(notes: newNotes);
      mockMembers[index] = updatedMember;
      // 데이터 변경 후, 이 데이터와 관련된 Provider를 무효화!
      // ref.invalidate(...); // Provider 단에서 처리
    }
  }

  // 회원 추가 (이 기능은 순수 Member를 추가하므로 변경 없음)
  Future<void> addMember(Member member) async {
    await Future.delayed(const Duration(milliseconds: 500));
    mockMembers.add(member);
  }
}
