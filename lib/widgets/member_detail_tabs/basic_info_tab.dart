import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/member.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import 'package:ptlog/widgets/physical_info_edit_dialog.dart';

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow(LucideIcons.user, '이름', member.name),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.phone, '전화번호', member.phone),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.mail, '이메일', member.email),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.cake, '나이', member.age != null ? '${member.age}세' : '-'),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.calendar, '등록일', DateFormat('yyyy-MM-dd').format(member.registrationDate)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 신체 정보 헤더 + InBody 버튼,수정버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('신체 정보'),
              Row(
                children: [
                  // 1. 수정 버튼 (연필 아이콘)
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      // 다이얼로그 띄우기
                      final updatedMember = await showDialog<Member>(
                        context: context,
                        builder: (context) => PhysicalInfoEditDialog(member: member),
                      );

                      // 데이터가 수정되어 돌아왔을 때의 처리
                      if (updatedMember != null) {
                        // TODO: 상태 업데이트 로직 추가
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('신체 정보가 수정되었습니다.')),
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.pencil, size: 14),
                    label: const Text('수정', style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 32),
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // 2. 기존 InBody 버튼
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
            ],
          ),

          Card(
            elevation: 0,
            color: AppColors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ★ 실제 데이터 바인딩 ★
                  _buildInfoRow(LucideIcons.ruler, '키', _formatValue(member.height, 'cm')), 
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.dumbbell, '현재 체중', _formatValue(member.weight, 'kg')),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.target, '목표 체중', _formatValue(member.targetWeight, 'kg')),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.percent, '현재 체지방', _formatValue(member.bodyFat, '%')),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.zap, '현재 골격근량', _formatValue(member.skeletalMuscle, 'kg')),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.trendingUp, '목표 골격근량', _formatValue(member.targetMuscle, 'kg')),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.activity, '활동량', member.activityLevel ?? '-'),
                  const Divider(height: 24),
                  _buildInfoRow(LucideIcons.moon, '수면 시간', member.sleepTime ?? '-'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 값이 있으면 단위 붙여서 반환, 없으면 '-'
  String _formatValue(dynamic value, String unit) {
    if (value == null || value.toString().isEmpty) return '-';
    return '${value.toString()} $unit';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        SizedBox(
          width: 100, 
          child: Text(label, style: AppTextStyles.subtitle2.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.subtitle2, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}