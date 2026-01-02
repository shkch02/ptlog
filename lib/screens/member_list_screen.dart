import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/member.dart';
import 'package:ptlog/providers/home_providers.dart';
import 'package:ptlog/providers/repository_providers.dart';
import 'package:ptlog/widgets/member_add_dialog.dart';
import 'package:ptlog/widgets/member_detail_dialog.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  String _searchQuery = '';

  void _showMemberDetail(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => MemberDetailDialog(member: member),
    );
  }

  //회원추가창 다이얼로그 호출 함수
  void _showAddMemberDialog() async {
    final Member? newMember = await showDialog<Member>(
      context: context,
      builder: (context) => const MemberAddDialog(),
    );

    if (newMember != null) {
      // 1. MemberRepository를 통해 순수 Member 정보 추가
      await ref.read(memberRepositoryProvider).addMember(newMember);
      
      // 2. [신규] RelationRepository를 통해 현재 트레이너와 새 회원을 연결
      final trainerId = ref.read(currentTrainerIdProvider);
      await ref.read(relationRepositoryProvider).createRelation(trainerId, newMember.id);

      // 3. 회원 목록 새로고침
      ref.invalidate(membersForTrainerProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${newMember.name} 회원님이 등록 및 연결되었습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // [수정] allMembersProvider -> membersForTrainerProvider
    final asyncMembers = ref.watch(membersForTrainerProvider);

    return asyncMembers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (members) {
        final filteredMembers = members
            .where((member) =>
                member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                member.phone.contains(_searchQuery) ||
                member.email.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('회원 관리', style: AppTextStyles.h2),
                      Text('총 ${members.length}명',
                          style: AppTextStyles.subtitle2),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: _showAddMemberDialog,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('추가'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: '이름, 전화번호 검색...',
                  prefixIcon:
                      const Icon(LucideIcons.search, color: AppColors.textLight),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.disabled),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.disabled),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    return _buildRichMemberCard(member);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRichMemberCard(Member member) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.disabled),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.white,
      child: InkWell(
        onTap: () => _showMemberDetail(context, member),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(member.profileImage ?? ''),
                    onBackgroundImageError: (_, __) {},
                    child: member.profileImage == null
                        ? Text(member.name[0])
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name, style: AppTextStyles.subtitle1),
                        const SizedBox(height: 4),
                        _buildSessionBadge(
                            member.remainingSessions, member.totalSessions),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight,
                      color: AppColors.textLight),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(LucideIcons.phone, member.phone),
              const SizedBox(height: 4),
              _buildInfoRow(LucideIcons.mail, member.email),
              const SizedBox(height: 4),
              _buildInfoRow(
                  LucideIcons.calendar, '등록일: ${member.registrationDate}'),
              if (member.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(member.notes,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.warning),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.subtitle2),
      ],
    );
  }

  Widget _buildSessionBadge(int remaining, int total) {
    final ratio = total == 0 ? 0 : remaining / total;
    Color color = AppColors.textLight;
    Color bgColor = AppColors.background;

    if (ratio <= 0.2) {
      color = AppColors.danger;
      bgColor = AppColors.dangerLight;
    } else if (ratio <= 0.5) {
      color = AppColors.black;
      bgColor = AppColors.disabled;
    } else {
      color = AppColors.primary;
      bgColor = AppColors.primaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$remaining/$total 회 남음',
        style: AppTextStyles.button.copyWith(fontSize: 12, color: color),
      ),
    );
  }
}
