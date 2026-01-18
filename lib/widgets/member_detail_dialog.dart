// 회원 상세 정보를 보여주는 다이얼로그 위젯
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/providers/home_providers.dart';
import 'package:ptlog/providers/repository_providers.dart';
import 'package:ptlog/widgets/member_detail_tabs/basic_info_tab.dart';
import 'package:ptlog/widgets/member_detail_tabs/detailed_memo_tab.dart';
import 'package:ptlog/widgets/member_detail_tabs/settings_tab.dart';
import 'package:ptlog/widgets/member_detail_tabs/pt_sessions_tab.dart';
import 'package:ptlog/models/index.dart';

class MemberDetailDialog extends ConsumerStatefulWidget {
  final Member member;
  final VoidCallback? onMemberUpdated;

  const MemberDetailDialog({
    super.key,
    required this.member,
    this.onMemberUpdated,
  });

  @override
  ConsumerState<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends ConsumerState<MemberDetailDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notesController = TextEditingController(text: widget.member.notes);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memberRepo = ref.read(memberRepositoryProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 700,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      NetworkImage(widget.member.profileImage ?? ''),
                  onBackgroundImageError: (_, __) {},
                  child: widget.member.profileImage == null
                      ? Text(widget.member.name[0])
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.member.name, style: AppTextStyles.h2),
                          const SizedBox(width: 8),
                          _buildSessionBadge(widget.member.remainingSessions,
                              widget.member.totalSessions),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(widget.member.phone, style: AppTextStyles.subtitle2),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primary,
              labelStyle: AppTextStyles.button.copyWith(fontSize: 13),
              tabs: const [
                Tab(text: 'PT세션'),
                Tab(text: '기본정보'),
                Tab(text: '상세메모'),
                Tab(text: '설정'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PtSessionsTab(member: widget.member),
                  BasicInfoTab(member: widget.member),
                  DetailedMemoTab(
                    notesController: _notesController,
                    memberRepo: memberRepo,
                    member: widget.member,
                  ),
                  SettingsTab(
                    member: widget.member,
                    memberRepo: memberRepo,
                    onMemberUpdated: () {
                      // Provider 무효화하여 회원 목록 새로고침
                      ref.invalidate(membersForTrainerProvider);
                      widget.onMemberUpdated?.call();
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... ( _buildSessionBadge 메서드는 기존과 동일 )
  Widget _buildSessionBadge(int remaining, int total) {
    // 기존 코드 유지
    final ratio = total > 0 ? remaining / total : 0.0;
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
        '$remaining/$total 회',
        style: AppTextStyles.button.copyWith(fontSize: 12, color: color),
      ),
    );
  }
}