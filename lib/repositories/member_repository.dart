import 'package:ptlog/repositories/relation_repository.dart';

import '../models/index.dart';
import '../data/mock_data.dart';

class MemberRepository {
  final RelationRepository _relationRepository;
  MemberRepository(this._relationRepository);

  // [신규] 특정 트레이너에게 소속된 활성 회원 목록을 가져오는 메서드 (보관된 회원 제외)
  Future<List<Member>> getMembersForTrainer(String trainerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 1. 트레이너에게 속한 활성 관계(relation)들을 찾음
    final relations = await _relationRepository.getActiveRelationsForTrainer(trainerId);
    final memberIds = relations.map((r) => r.memberId).toSet();

    // 2. 해당 ID를 가진 활성(보관되지 않은) 회원 정보들을 반환
    return mockMembers
        .where((m) => memberIds.contains(m.id) && !m.isArchived)
        .toList();
  }

  // [의미 변경] 시스템의 '모든' 활성 회원을 가져옴 (보관된 회원 제외)
  Future<List<Member>> getAllMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockMembers.where((m) => !m.isArchived).toList();
  }

  // 보관된 회원 목록을 가져옴
  Future<List<Member>> getArchivedMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockMembers.where((m) => m.isArchived).toList();
  }

  // 특정 트레이너의 보관된 회원 목록을 가져옴
  Future<List<Member>> getArchivedMembersForTrainer(String trainerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final relations = await _relationRepository.getActiveRelationsForTrainer(trainerId);
    final memberIds = relations.map((r) => r.memberId).toSet();

    return mockMembers
        .where((m) => memberIds.contains(m.id) && m.isArchived)
        .toList();
  }

  // [로직 변경 필요] 이제 특정 트레이너의 회원들 중에서 만료 임박 회원을 찾아야 함
  Future<List<Member>> getRenewalNeededMembersForTrainer(String trainerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final myMembers = await getMembersForTrainer(trainerId);
    return myMembers.where((m) => m.remainingSessions <= 3).toList();
  }

  // 회원 메모 업데이트 (이 기능은 Member 객체 자체를 수정하므로 변경 없음)
  Future<void> updateMemberNotes(String memberId, String newNotes) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = mockMembers.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final updatedMember = mockMembers[index].copyWith(notes: newNotes);
      mockMembers[index] = updatedMember;
    }
  }

  // 회원 추가 (이 기능은 순수 Member를 추가하므로 변경 없음)
  Future<void> addMember(Member member) async {
    await Future.delayed(const Duration(milliseconds: 500));
    mockMembers.add(member);
  }

  // 회원 보관 (Archive) 처리
  Future<void> archiveMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = mockMembers.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final updatedMember = mockMembers[index].copyWith(isArchived: true);
      mockMembers[index] = updatedMember;
    }
  }

  // 회원 보관 해제 (Unarchive) 처리
  Future<void> unarchiveMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = mockMembers.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final updatedMember = mockMembers[index].copyWith(isArchived: false);
      mockMembers[index] = updatedMember;
    }
  }

  // 회원 완전 삭제 (Hard Delete)
  Future<void> deleteMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    mockMembers.removeWhere((m) => m.id == memberId);
  }
}
