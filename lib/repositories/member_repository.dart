import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/providers/home_providers.dart';
import '../models/index.dart';
import '../data/mock_data.dart';

class MemberRepository {
  final Ref ref;
  MemberRepository(this.ref);

  // 모든 회원 가져오기
  Future<List<Member>> getAllMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(mockMembers); // 리스트 복사해서 반환
  }

  // 재등록 필요 회원 가져오기 (3회 이하)
  Future<List<Member>> getRenewalNeededMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockMembers.where((m) => m.remainingSessions <= 3).toList();
  }

  //  특정 회원의 결제 내역 가져오기
  Future<List<PaymentLog>> getPaymentHistory(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // mockPaymentLogs는 mock_data.dart에 있다고 가정
    return mockPaymentLogs.where((p) => p.memberId == memberId).toList();
  }

  // 회원 메모 업데이트
  Future<void> updateMemberNotes(String memberId, String newNotes) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final index = mockMembers.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      // copyWith를 사용하여 새로운 객체 생성
      final updatedMember = mockMembers[index].copyWith(notes: newNotes);
      // 리스트에서 해당 멤버 교체
      mockMembers[index] = updatedMember;

      // 데이터 변경 후, 이 데이터와 관련된 Provider를 무효화!
      ref.invalidate(allMembersProvider);
      ref.invalidate(renewalMembersProvider);
    }
  }

  //회원 추가 메서드
  Future<void> addMember(Member member) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 저장하는 척 딜레이
    mockMembers.add(member); // 실제 목업 리스트에 추가
  }
}