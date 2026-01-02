import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_strings.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import '../models/index.dart'; // Member 모델 import

class ManualSessionDialog extends StatefulWidget {
  final List<Member> members; 
  final Function(Schedule) onStart; //부모(home_screen)에게 전달할 콜백 함수

  const ManualSessionDialog({
    super.key,
    required this.members,
    required this.onStart,
  });

  @override
  State<ManualSessionDialog> createState() => _ManualSessionDialogState();
}

class _ManualSessionDialogState extends State<ManualSessionDialog> {
  // 검색어 상태 관리
  String _searchQuery = '';

  Schedule _createSchedule(String memberName, {String? memberId, String notes = ''}) {
    final now = DateTime.now();
    return Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID 생성
      relationId: 'temp_relation', // 임시 관계 ID
      memberId: memberId ?? 'guest',
      memberName: memberName,
      date: now,
      startTime: DateFormat(AppStrings.dateFormatHm).format(now),
      endTime: DateFormat(AppStrings.dateFormatHm).format(now.add(const Duration(minutes: 50))),
      notes: notes,
      reminder: '리마인더',
    );
  }

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
      title: const Text('수동 수업 시작', style: AppTextStyles.h3),
      content: SizedBox(
        width: double.maxFinite, // 가로 폭 꽉 채우기
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('수업을 진행할 회원을 선택하거나 검색하세요.', style: AppTextStyles.caption),
            const SizedBox(height: 16),

            // 1. 검색바 (Search Bar)
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: '이름, 전화번호 검색',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.disabledText),
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.textLight),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. 신규/체험 회원 세션 시작 버튼
            InkWell(
              onTap: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                final result = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (context) => const _NewMemberInputDialog(),
                );

                if (result == null || !mounted) return;

                navigator.pop(); 

                final name = result['name'] ?? '체험 회원';
                final info = "키: ${result['height']}cm, 나이: ${result['age']}세, 특이사항: ${result['note']}";

                final schedule = _createSchedule(name, notes: info);
                
                widget.onStart(schedule);

                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('$name님과 수업을 시작합니다.')),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withAlpha(77)),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary.withAlpha(13),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.userPlus, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('신규 / 체험 회원', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                          const Text('등록되지 않은 회원과 바로 수업 시작', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.primary),
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
                        style: AppTextStyles.caption.copyWith(color: AppColors.disabledText),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredMembers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.disabled,
                            backgroundImage: NetworkImage(member.profileImage ?? ''),
                            onBackgroundImageError: (_, __) {},
                            child: member.profileImage == null 
                                ? const Text("", style: AppTextStyles.caption) 
                                : null,
                          ),
                          title: Text(member.name, style: AppTextStyles.body.copyWith(fontSize: 15)),
                          subtitle: Text(member.phone, style: AppTextStyles.caption.copyWith(color: AppColors.disabledText)),
                          trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textLight),
                          onTap: () {
                            Navigator.pop(context);
                            final schedule = _createSchedule(member.name, memberId: member.id);
                            widget.onStart(schedule);
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
          style: TextButton.styleFrom(foregroundColor: AppColors.textLight),
          child: const Text('취소'),
        ),
      ],
    );
  }
}


class _NewMemberInputDialog extends StatefulWidget {
  const _NewMemberInputDialog();

  @override
  State<_NewMemberInputDialog> createState() => _NewMemberInputDialogState();
}

class _NewMemberInputDialogState extends State<_NewMemberInputDialog> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('체험 회원 정보 입력', style: AppTextStyles.h3),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름 (필수)', hintText: '홍길동'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '키 (cm)', hintText: '175'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '나이', hintText: '30'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: '특이사항', hintText: '운동 목적, 부상 부위 등'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: AppColors.textLight)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty) return;

            Navigator.pop(context, {
              'name': _nameController.text,
              'height': _heightController.text,
              'age': _ageController.text,
              'note': _noteController.text,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('시작하기'),
        ),
      ],
    );
  }
}
