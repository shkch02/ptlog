import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptlog/constants/app_dimensions.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/providers/home_providers.dart';
import '../models/index.dart';
import '../widgets/manual_session_dialog.dart';
import '../widgets/upcoming_session_section.dart';
import '../widgets/renewal_needed_section.dart';
import '../widgets/member_detail_dialog.dart';
import 'session_log_screen.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onGoToSchedule;
  const HomeScreen({super.key, required this.onGoToSchedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSchedules = ref.watch(upcomingSchedulesProvider);
    final asyncRenewals = ref.watch(renewalMembersProvider);
    final asyncAllMembers = ref.watch(membersForTrainerProvider); // [수정] allMembersProvider -> membersForTrainerProvider
    final asyncMessage = ref.watch(nextSessionMessageProvider);

    final isLoading = asyncSchedules.isLoading ||
        asyncRenewals.isLoading ||
        asyncAllMembers.isLoading ||
        asyncMessage.isLoading;
    
    final hasError = asyncSchedules.hasError ||
        asyncRenewals.hasError ||
        asyncAllMembers.hasError ||
        asyncMessage.hasError;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      // You can show a more specific error message if needed
      return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
    }

    final schedules = asyncSchedules.value!;
    final renewals = asyncRenewals.value!;
    final allMembers = asyncAllMembers.value!;
    final message = asyncMessage.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UpcomingSessionSection(
            schedules: schedules,
            onManualStart: () => _showManualSessionDialog(context, allMembers),
            emptyMessage: message,
            onMemberInfoTap: (memberId) {
              try {
                final member = allMembers.firstWhere((m) => m.id == memberId);
                showDialog(
                  context: context,
                  builder: (context) => MemberDetailDialog(member: member),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('회원 정보를 찾을 수 없습니다.')),
                );
              }
            },
          ),
          Center(
            child: TextButton(
              onPressed: onGoToSchedule,
              child: const Text('전체 스케줄 확인하러 가기', style: AppTextStyles.caption),
            ),
          ),
          const SizedBox(height: AppDimensions.gapLarge),
          RenewalNeededSection(members: renewals),
        ],
      ),
    );
  }

  void _showManualSessionDialog(BuildContext context, List<Member> allMembers) {
    showDialog(
      context: context,
      builder: (context) => ManualSessionDialog(
        members: allMembers,
        onStart: (schedule) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionLogScreen(schedule: schedule),
            ),
          );
        },
      ),
    );
  }
}
