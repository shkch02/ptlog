// 회원 상세 정보의 상세 메모 탭 위젯
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/member.dart';
import 'package:ptlog/repositories/member_repository.dart';

class DetailedMemoTab extends StatelessWidget {
  final TextEditingController notesController;
  final MemberRepository memberRepo;
  final Member member;

  const DetailedMemoTab({
    super.key,
    required this.notesController,
    required this.memberRepo,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warningLight),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.info,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('회원의 특이사항, 부상 이력 등을 기록하세요.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.warning))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            maxLines: 12,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: '내용을 입력하세요...',
              filled: true,
              fillColor: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await memberRepo.updateMemberNotes(
                    member.id, notesController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('메모가 저장되었습니다.')));
                }
              },
              icon: const Icon(LucideIcons.save, size: 16),
              label: const Text('메모 저장'),
            ),
          ),
        ],
      ),
    );
  }
}
