import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/index.dart';

class PaymentTab extends StatelessWidget {
  final List<PaymentLog> memberPayments;

  const PaymentTab({super.key, required this.memberPayments});

  @override
  Widget build(BuildContext context) {
    if (memberPayments.isEmpty) {
      return const Center(child: Text('결제/연동 이력이 없습니다.'));
    }
    return ListView.builder(
      itemCount: memberPayments.length,
      itemBuilder: (context, index) {
        final log = memberPayments[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: log.type == 'CRM연동'
                  ? AppColors.successLight
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              log.type == 'CRM연동'
                  ? LucideIcons.link
                  : LucideIcons.creditCard,
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
