import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // 아이콘 사용
import '../models/index.dart';

class RenewalNeededSection extends StatefulWidget {
  final List<Member> members;

  const RenewalNeededSection({
    super.key,
    required this.members,
  });

  @override
  State<RenewalNeededSection> createState() => _RenewalNeededSectionState();
}

class _RenewalNeededSectionState extends State<RenewalNeededSection> {
  bool _isExpanded = false; // 리스트 펼침/접힘 상태 관리

  @override
  Widget build(BuildContext context) {
    // 1. 데이터 정렬 및 그룹화 로직
    
    // (1) 통계 칩 생성을 위한 데이터 집계 (남은 횟수별 인원 수)
    final Map<int, int> sessionCounts = {};
    for (var m in widget.members) {
      sessionCounts[m.remainingSessions] = (sessionCounts[m.remainingSessions] ?? 0) + 1;
    }

    // (2) 칩 표시 순서 정렬: 1회 -> 2회 -> 3회 ... -> 맨 마지막에 0회
    final sortedKeys = sessionCounts.keys.toList()
      ..sort((a, b) {
        if (a == 0) return 1; // 0은 무조건 뒤로
        if (b == 0) return -1;
        return a.compareTo(b); // 나머지는 오름차순 (1, 2, 3...)
      });

    // (3) 실제 리스트 보여줄 때 정렬: 1회~오름차순 먼저, 0회(만료)는 맨 아래
    final activeMembers = widget.members.where((m) => m.remainingSessions > 0).toList()
      ..sort((a, b) => a.remainingSessions.compareTo(b.remainingSessions));
    
    final expiredMembers = widget.members.where((m) => m.remainingSessions == 0).toList();
    
    // 최종 정렬된 리스트 합치기
    final sortedMembers = [...activeMembers, ...expiredMembers];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 헤더 영역 (제목 + 요약 칩 + 토글 버튼)
        Row(
          children: [
            const Text('만료 임박', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            
            // 오른쪽 정렬된 요약 칩들 (공간이 부족하면 스크롤 되도록)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true, // 오른쪽부터 채워지는 느낌을 주기 위해
                child: Row(
                  children: sortedKeys.map((count) {
                    final people = sessionCounts[count]!;
                    final isExpired = count == 0;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Chip(
                        label: Text(
                          '$count회 ${people}명', 
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: isExpired ? Colors.white : Colors.red[800],
                          ),
                        ),
                        backgroundColor: isExpired ? Colors.grey[500] : Colors.red[50],
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 토글 버튼
            IconButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        // 리스트 출력 (토글 상태에 따라 표시)
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          if (sortedMembers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('재등록 대상이 없습니다! 🎉', style: TextStyle(color: Colors.grey))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedMembers.length,
              itemBuilder: (context, index) {
                final member = sortedMembers[index];
                final isExpired = member.remainingSessions == 0;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  // 만료된 회원은 배경색을 약간 어둡게 처리하여 구분
                  color: isExpired ? Colors.grey[50] : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isExpired ? Colors.grey[200] : Colors.red[50],
                      child: Text(
                        member.name[0], 
                        style: TextStyle(color: isExpired ? Colors.grey : Colors.red[800]),
                      ),
                    ),
                    title: Text(
                      member.name, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExpired ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      isExpired ? '세션 만료됨' : '남은 횟수: ${member.remainingSessions}회',
                      style: TextStyle(color: isExpired ? Colors.red : Colors.grey[600]),
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () {
                        // TODO: 연락 기능 연결
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 32),
                        backgroundColor: isExpired ? Colors.grey[200] : null,
                      ),
                      child: Text('연락', style: TextStyle(color: isExpired ? Colors.grey[600] : null)),
                    ),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}