import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/index.dart'; // Member 모델 import

class ManualSessionDialog extends StatefulWidget {
  final List<Member> members; 

  const ManualSessionDialog({super.key, required this.members});

  @override
  State<ManualSessionDialog> createState() => _ManualSessionDialogState();
}

class _ManualSessionDialogState extends State<ManualSessionDialog> {
  // 검색어 상태 관리
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // 검색어에 따라 회원 리스트 필터링 (이름 또는 전화번호 뒷자리)
    final filteredMembers = widget.members.where((member) {
      final query = _searchQuery.toLowerCase();
      return member.name.toLowerCase().contains(query) || 
             member.phone.contains(query);
    }).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('수동 수업 시작', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite, // 가로 폭 꽉 채우기
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('수업을 진행할 회원을 선택하거나 검색하세요.', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),

            // 1. 검색바 (Search Bar)
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: '이름, 전화번호 검색',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. 신규/체험 회원 세션 시작 버튼
            InkWell(
              onTap: () {
                Navigator.pop(context);
                // TODO: 체험 회원용 운동 일지 작성 페이지로 이동 (이름 없이 시작하거나 임시 이름 부여)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('신규/체험 회원님과 수업을 시작합니다.')),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.userPlus, size: 18, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('신규 / 체험 회원', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          Text('등록되지 않은 회원과 바로 수업 시작', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // 3. 기존 회원 리스트 (필터링 적용됨)
            Expanded(
              child: filteredMembers.isEmpty
                  ? Center(
                      child: Text(
                        '검색 결과가 없습니다.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredMembers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56), // 아이콘 공간만큼 들여쓰기
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(member.profileImage ?? ''),
                            onBackgroundImageError: (_, __) {},
                            child: member.profileImage == null 
                                ? Text(member.name[0], style: const TextStyle(color: Colors.grey)) 
                                : null,
                          ),
                          title: Text(member.name, style: const TextStyle(fontSize: 15)),
                          subtitle: Text(member.phone, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          trailing: const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: 선택된 회원 정보로 운동 일지 이동
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${member.name} 회원님과 수동 수업을 시작합니다.')),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text('취소'),
        ),
      ],
    );
  }
}