import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import '../models/index.dart';

class RenewalNeededSection extends StatefulWidget {
  final List<Member> members;

  const RenewalNeededSection({
    super.key,
    required this.members,
  });

  @override
  State<RenewalNeededSection> createState() => _RenewalNeededSectionState();
}

class _RenewalNeededSectionState extends State<RenewalNeededSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final Map<int, int> sessionCounts = {};
    for (var m in widget.members) {
      sessionCounts[m.remainingSessions] = (sessionCounts[m.remainingSessions] ?? 0) + 1;
    }

    final sortedKeys = sessionCounts.keys.toList()
      ..sort((a, b) {
        if (a == 0) return 1;
        if (b == 0) return -1;
        return a.compareTo(b);
      });

    final activeMembers = widget.members.where((m) => m.remainingSessions > 0).toList()
      ..sort((a, b) => a.remainingSessions.compareTo(b.remainingSessions));
    
    final expiredMembers = widget.members.where((m) => m.remainingSessions == 0).toList();
    
    final sortedMembers = [...activeMembers, ...expiredMembers];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('만료 임박', style: AppTextStyles.h2),
            const SizedBox(width: 12),
            
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  children: sortedKeys.map((count) {
                    final people = sessionCounts[count]!;
                    final isExpired = count == 0;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Chip(
                        label: Text(
                          '$count회 $people명', 
                          style: AppTextStyles.button.copyWith(
                            fontSize: 12,
                            color: isExpired ? AppColors.white : AppColors.danger,
                          ),
                        ),
                        backgroundColor: isExpired ? AppColors.disabledText : AppColors.dangerLight,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            IconButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),

        if (_isExpanded) ...[
          const SizedBox(height: 8),
          if (sortedMembers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('재등록 대상이 없습니다! 🎉', style: AppTextStyles.caption)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedMembers.length,
              itemBuilder: (context, index) {
                final member = sortedMembers[index];
                final isExpired = member.remainingSessions == 0;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.disabled),
                  ),
                  color: isExpired ? AppColors.background : AppColors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isExpired ? AppColors.disabled : AppColors.dangerLight,
                      child: Text(
                        member.name[0], 
                        style: TextStyle(color: isExpired ? AppColors.textLight : AppColors.danger),
                      ),
                    ),
                    title: Text(
                      member.name, 
                      style: AppTextStyles.button.copyWith(
                        color: isExpired ? AppColors.textLight : AppColors.black,
                      ),
                    ),
                    subtitle: Text(
                      isExpired ? '세션 만료됨' : '남은 횟수: ${member.remainingSessions}회',
                      style: AppTextStyles.caption.copyWith(color: isExpired ? AppColors.danger : AppColors.textSecondary),
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 32),
                        backgroundColor: isExpired ? AppColors.disabled : null,
                      ),
                      child: Text('연락', style: TextStyle(color: isExpired ? AppColors.textSecondary : null)),
                    ),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}
