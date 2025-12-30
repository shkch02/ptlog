import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import '../repositories/member_repository.dart';
import '../models/index.dart'; 
import '../widgets/member_detail_dialog.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final MemberRepository _memberRepo = MemberRepository();
  
  List<Member> _members = []; 
  String _searchQuery = ''; 

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final members = await _memberRepo.getAllMembers();
    if (mounted) {
      setState(() {
        _members = members;
      });
    }
  }

  void _showMemberDetail(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => MemberDetailDialog(member: member),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredMembers = _members.where((member) =>
      member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      member.phone.contains(_searchQuery) ||
      member.email.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('회원 관리', style: AppTextStyles.h2),
                  Text('총 ${_members.length}명', style: AppTextStyles.subtitle2),
                ],
              ),
              FilledButton.icon(
                onPressed: () {
                  // TODO: 회원 추가 다이얼로그
                },
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('추가'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 2. 검색 바
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: '이름, 전화번호 검색...',
              prefixIcon: const Icon(LucideIcons.search, color: AppColors.textLight),
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

          // 3. 회원 목록
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
  }

  // 카드 위젯
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
              // 상단: 프로필 + 이름 + 뱃지
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(member.profileImage ?? ''),
                    onBackgroundImageError: (_, __) {},
                    child: member.profileImage == null ? Text(member.name[0]) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name, style: AppTextStyles.subtitle1),
                        const SizedBox(height: 4),
                        _buildSessionBadge(member.remainingSessions, member.totalSessions),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: AppColors.textLight),
                ],
              ),
              const SizedBox(height: 12),
              
              // 정보 행들
              _buildInfoRow(LucideIcons.phone, member.phone),
              const SizedBox(height: 4),
              _buildInfoRow(LucideIcons.mail, member.email),
              const SizedBox(height: 4),
              _buildInfoRow(LucideIcons.calendar, '등록일: ${member.registrationDate}'),
              
              // 메모 경고창
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
                      const Icon(LucideIcons.alertCircle, size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(child: Text(member.notes, style: AppTextStyles.caption.copyWith(color: AppColors.warning), maxLines: 1, overflow: TextOverflow.ellipsis)),
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