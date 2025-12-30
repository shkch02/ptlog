import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_strings.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import '../models/index.dart';
import '../repositories/schedule_repository.dart'; 
import '../repositories/member_repository.dart'; 

class MemberDetailDialog extends StatefulWidget {
  final Member member;

  const MemberDetailDialog({super.key, required this.member});

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> with SingleTickerProviderStateMixin {
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
                  backgroundImage: NetworkImage(widget.member.profileImage ?? ''),
                  onBackgroundImageError: (_, __) {},
                  child: widget.member.profileImage == null ? Text(widget.member.name[0]) : null,
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
                          _buildSessionBadge(widget.member.remainingSessions, widget.member.totalSessions),
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
                        _buildPTSessionsTab(),
                        _buildBasicInfoTab(),
                        _buildDetailedMemoTab(),
                        _buildPaymentTab(),
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

  Widget _buildPTSessionsTab() {
    if (_memberSchedules.isEmpty) {
      return const Center(child: Text('예약된 스케줄이 없습니다.'));
    }
    final now = DateTime.now();
    return ListView.builder(
      itemCount: _memberSchedules.length,
      itemBuilder: (context, index) {
        final schedule = _memberSchedules[index];
        DateTime scheduleTime;
        try {
          scheduleTime = DateFormat(AppStrings.dateFormatYmdHm).parse('${schedule.date} ${schedule.startTime}');
        } catch (e) {
          scheduleTime = now;
        }
        final isPast = scheduleTime.isBefore(now);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isPast ? AppColors.background : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isPast ? AppColors.disabled : AppColors.primaryLight, width: isPast ? 1 : 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${schedule.date} ${schedule.startTime}',
                      style: AppTextStyles.subtitle1.copyWith(
                        color: isPast ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPast ? '완료' : (schedule.notes.isNotEmpty ? schedule.notes : '예약됨'),
                      style: AppTextStyles.caption.copyWith(
                        color: isPast ? AppColors.textLight : AppColors.primary,
                        fontWeight: isPast ? FontWeight.normal : FontWeight.w600
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('보고서 기능 준비중')));
                },
                icon: Icon(LucideIcons.fileText, size: 14, color: isPast ? AppColors.textSecondary : AppColors.primary),
                label: Text('운동기록', style: AppTextStyles.caption.copyWith(color: isPast ? AppColors.textSecondary : AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  side: BorderSide(color: isPast ? AppColors.disabledText : AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('인적사항'),
          Card(
            elevation: 0,
            color: AppColors.background,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildInfoRow(LucideIcons.user, '이름', widget.member.name),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.phone, '전화번호', widget.member.phone),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.mail, '이메일', widget.member.email),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.cake, '나이', '28세'), // 더미
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.calendar, '등록일', widget.member.registrationDate),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('신체 정보'),
              FilledButton.tonalIcon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('InBody 데이터 연동 중...')));
                },
                icon: const Icon(LucideIcons.link, size: 14),
                label: const Text('InBody', style: TextStyle(fontSize: 12)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          Card(
            elevation: 0,
            color: AppColors.background,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildInfoRow(LucideIcons.ruler, '키', '175 cm'), 
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.dumbbell, '현재 체중', '72 kg'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.target, '목표 체중', '68 kg'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.percent, '현재 체지방', '18 %'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.zap, '현재 골격근량', '35 kg'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.trendingUp, '목표 골격근량', '38 kg'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.activity, '활동량', '보통'),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.moon, '수면 시간', '7시간'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(title, style: AppTextStyles.subtitle1),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        SizedBox(
          width: 90, 
          child: Text(label, style: AppTextStyles.subtitle2),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildSessionBadge(int remaining, int total) {
    final ratio = remaining / total;
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

  Widget _buildDetailedMemoTab() {
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
                const Icon(LucideIcons.info, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(child: Text('회원의 특이사항, 부상 이력 등을 기록하세요.', style: AppTextStyles.caption.copyWith(color: AppColors.warning))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메모가 저장되었습니다.'))
                );
              },
              icon: const Icon(LucideIcons.save, size: 16),
              label: const Text('메모 저장'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    if (_memberPayments.isEmpty) {
      return const Center(child: Text('결제/연동 이력이 없습니다.'));
    }
    return ListView.builder(
      itemCount: _memberPayments.length,
      itemBuilder: (context, index) {
        final log = _memberPayments[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: log.type == 'CRM연동' ? AppColors.successLight : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              log.type == 'CRM연동' ? LucideIcons.link : LucideIcons.creditCard,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
          title: Text(log.type, style: AppTextStyles.button),
          subtitle: Text('${log.date} | ${log.content}'),
          trailing: Text(log.amount, style: AppTextStyles.button),
        );
      },
    );
  }
}
