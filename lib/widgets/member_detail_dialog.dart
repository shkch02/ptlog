import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/widgets/member_detail_tabs/basic_info_tab.dart';
import 'package:ptlog/widgets/member_detail_tabs/detailed_memo_tab.dart';
import 'package:ptlog/widgets/member_detail_tabs/payment_tab.dart';
import 'package:ptlog/widgets/member_detail_tabs/pt_sessions_tab.dart';
import '../models/index.dart';
import '../repositories/schedule_repository.dart';
import '../repositories/member_repository.dart';

class MemberDetailDialog extends StatefulWidget {
  final Member member;

  const MemberDetailDialog({super.key, required this.member});

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _notesController;

  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  final MemberRepository _memberRepo = MemberRepository();

  List<Schedule> _memberSchedules = [];
  List<PaymentLog> _memberPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notesController = TextEditingController(text: widget.member.notes);

    _loadAsyncData();
  }

  Future<void> _loadAsyncData() async {
    final results = await Future.wait([
      _scheduleRepo.getSchedulesByMember(widget.member.id),
      _memberRepo.getPaymentHistory(widget.member.id),
    ]);

    if (mounted) {
      setState(() {
        _memberSchedules = results[0] as List<Schedule>;
        _memberPayments = results[1] as List<PaymentLog>;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Tab(text: '결제'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        PtSessionsTab(memberSchedules: _memberSchedules),
                        BasicInfoTab(member: widget.member),
                        DetailedMemoTab(
                          notesController: _notesController,
                          memberRepo: _memberRepo,
                          member: widget.member,
                        ),
                        PaymentTab(memberPayments: _memberPayments),
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

  Widget _buildSessionBadge(int remaining, int total) {
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