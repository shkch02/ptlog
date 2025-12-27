import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_data.dart'; 
import '../models/index.dart'; 
import '../widgets/member_detail_dialog.dart'; // ★ 핵심: 새로 만든 파일 import

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  List<Member> members = mockMembers;
  String searchQuery = '';

  // 팝업 호출 함수
  void _showMemberDetail(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => MemberDetailDialog(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembers = members.where((member) =>
      member.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
      member.phone.contains(searchQuery) ||
      member.email.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();

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
                  const Text('회원 관리', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('총 ${members.length}명', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('추가'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: '이름, 전화번호 검색...',
              prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
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
  }

  Widget _buildRichMemberCard(Member member) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
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
                    child: member.profileImage == null ? Text(member.name[0]) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        _buildSessionBadge(member.remainingSessions, member.totalSessions),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(LucideIcons.phone, member.phone),
              const SizedBox(height: 4),
              _buildInfoRow(LucideIcons.mail, member.email),
              const SizedBox(height: 4),
              _buildInfoRow(LucideIcons.calendar, '등록일: ${member.registrationDate}'),
              
              if (member.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertCircle, size: 16, color: Colors.amber[900]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(member.notes, style: TextStyle(fontSize: 12, color: Colors.amber[900]), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSessionBadge(int remaining, int total) {
    final ratio = remaining / total;
    Color color = Colors.grey;
    Color bgColor = Colors.grey[100]!;
    
    if (ratio <= 0.2) {
      color = Colors.red;
      bgColor = Colors.red[50]!;
    } else if (ratio <= 0.5) {
      color = Colors.black;
      bgColor = Colors.grey[200]!;
    } else {
      color = Colors.blue[900]!;
      bgColor = Colors.blue[50]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text('$remaining/$total 회 남음', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }
}