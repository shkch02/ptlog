// 보관된 회원 목록을 보여주는 다이얼로그 위젯입니다.
// 보관된 회원 목록을 보여주는 다이얼로그 위젯
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/member.dart';
import 'package:ptlog/providers/home_providers.dart';
import 'package:ptlog/providers/repository_providers.dart';

class ArchivedMembersDialog extends ConsumerStatefulWidget {
  const ArchivedMembersDialog({super.key});

  @override
  ConsumerState<ArchivedMembersDialog> createState() =>
      _ArchivedMembersDialogState();
}

class _ArchivedMembersDialogState extends ConsumerState<ArchivedMembersDialog> {
  List<Member> _archivedMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchivedMembers();
  }

  Future<void> _loadArchivedMembers() async {
    final trainerId = ref.read(currentTrainerIdProvider);
    final memberRepo = ref.read(memberRepositoryProvider);
    final members = await memberRepo.getArchivedMembersForTrainer(trainerId);

    if (mounted) {
      setState(() {
        _archivedMembers = members;
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreMember(Member member) async {
    final memberRepo = ref.read(memberRepositoryProvider);

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 복원'),
        content: Text(
          '${member.name} 회원을 복원하시겠습니까?\n\n'
          '복원된 회원은 회원 목록에 다시 표시됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('복원'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await memberRepo.unarchiveMember(member.id);

      // Provider 무효화
      ref.invalidate(membersForTrainerProvider);

      // 보관 목록 새로고침
      await _loadArchivedMembers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.name} 회원이 복원되었습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.archive,
                    size: 20,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('보관된 회원', style: AppTextStyles.h3),
                      Text(
                        '${_archivedMembers.length}명',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // 리스트
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _archivedMembers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _archivedMembers.length,
                          itemBuilder: (context, index) {
                            final member = _archivedMembers[index];
                            return _buildArchivedMemberCard(member);
                          },
                        ),
            ),

            // 하단 닫기 버튼
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.archiveRestore,
            size: 48,
            color: AppColors.disabled,
          ),
          const SizedBox(height: 16),
          Text(
            '보관된 회원이 없습니다',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '회원 상세 > 설정에서\n회원을 보관할 수 있습니다',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedMemberCard(Member member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.disabled),
      ),
      child: Row(
        children: [
          // 프로필 아바타
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.disabled,
            backgroundImage: member.profileImage != null
                ? NetworkImage(member.profileImage!)
                : null,
            child: member.profileImage == null
                ? Text(
                    member.name[0],
                    style: AppTextStyles.subtitle1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // 회원 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.subtitle1,
                ),
                const SizedBox(height: 2),
                Text(
                  member.phone,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${member.remainingSessions}/${member.totalSessions}회 남음',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 복원 버튼
          FilledButton.icon(
            onPressed: () => _restoreMember(member),
            icon: const Icon(LucideIcons.archiveRestore, size: 16),
            label: const Text('복원'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
