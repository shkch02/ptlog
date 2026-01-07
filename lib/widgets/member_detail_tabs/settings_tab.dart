import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/index.dart';
import 'package:ptlog/repositories/member_repository.dart';

class SettingsTab extends StatelessWidget {
  final Member member;
  final MemberRepository memberRepo;
  final VoidCallback onMemberUpdated;

  const SettingsTab({
    super.key,
    required this.member,
    required this.memberRepo,
    required this.onMemberUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            '회원 관리',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // 보관 상태에 따라 다른 UI 표시
          if (member.isArchived)
            _buildSettingItem(
              context,
              icon: LucideIcons.archiveRestore,
              iconColor: AppColors.success,
              bgColor: AppColors.successLight,
              title: '회원 복원',
              subtitle: '보관된 회원을 다시 활성화합니다',
              onTap: () => _showUnarchiveDialog(context),
            )
          else
            _buildSettingItem(
              context,
              icon: LucideIcons.archive,
              iconColor: AppColors.warning,
              bgColor: AppColors.warningLight,
              title: '회원 보관',
              subtitle: '회원을 보관 처리하여 목록에서 숨깁니다',
              onTap: () => _showArchiveDialog(context),
            ),

          const SizedBox(height: 12),

          _buildSettingItem(
            context,
            icon: LucideIcons.trash2,
            iconColor: AppColors.danger,
            bgColor: AppColors.dangerLight,
            title: '회원 삭제',
            subtitle: '회원 정보를 완전히 삭제합니다 (복구 불가)',
            onTap: () => _showDeleteDialog(context),
          ),

          const SizedBox(height: 32),

          // 상태 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '회원 상태',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: member.isArchived
                            ? AppColors.warning
                            : AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      member.isArchived ? '보관됨' : '활성',
                      style: AppTextStyles.body.copyWith(
                        color: member.isArchived
                            ? AppColors.warning
                            : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.disabled),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle1),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showArchiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 보관'),
        content: Text(
          '${member.name} 회원을 보관하시겠습니까?\n\n'
          '보관된 회원은 회원 목록에서 숨겨지며, 나중에 복원할 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              await memberRepo.archiveMember(member.id);
              if (context.mounted) {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // MemberDetailDialog 닫기
                onMemberUpdated();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${member.name} 회원이 보관되었습니다.'),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('보관'),
          ),
        ],
      ),
    );
  }

  void _showUnarchiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 복원'),
        content: Text(
          '${member.name} 회원을 복원하시겠습니까?\n\n'
          '복원된 회원은 회원 목록에 다시 표시됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              await memberRepo.unarchiveMember(member.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                onMemberUpdated();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${member.name} 회원이 복원되었습니다.'),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('복원'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 삭제'),
        content: Text(
          '${member.name} 회원을 완전히 삭제하시겠습니까?\n\n'
          '⚠️ 이 작업은 되돌릴 수 없습니다.\n'
          '모든 회원 정보와 세션 기록이 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              await memberRepo.deleteMember(member.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                onMemberUpdated();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${member.name} 회원이 삭제되었습니다.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
