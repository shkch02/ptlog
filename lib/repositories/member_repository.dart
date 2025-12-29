import '../models/index.dart';
import '../data/mock_data.dart';

class MemberRepository {
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
}