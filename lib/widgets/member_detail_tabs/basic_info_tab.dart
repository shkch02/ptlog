import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/index.dart';

class BasicInfoTab extends StatelessWidget {
  final Member member;

  const BasicInfoTab({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
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
                  _buildInfoRow(LucideIcons.user, '이름', member.name),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.phone, '전화번호', member.phone),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.mail, '이메일', member.email),
                  const Divider(height: 16),
                  _buildInfoRow(LucideIcons.cake, '나이', '28세'), // 더미
                  const Divider(height: 16),
                  _buildInfoRow(
                      LucideIcons.calendar, '등록일', member.registrationDate),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('InBody 데이터 연동 중...')));
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
          child: Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
