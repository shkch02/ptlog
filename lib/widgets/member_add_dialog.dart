// 신규 회원을 추가하는 다이얼로그 위젯
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
//import 'package:uuid/uuid.dart'; // 고유 ID 생성을 위해 필요 (pubspec.yaml에 uuid 추가 권장, 없으면 임시 로직 사용)
import '../models/index.dart';

class MemberAddDialog extends StatefulWidget {
  const MemberAddDialog({super.key});

  @override
  State<MemberAddDialog> createState() => _MemberAddDialogState();
}

class _MemberAddDialogState extends State<MemberAddDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // 입력 컨트롤러
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _totalSessionController = TextEditingController(text: '10'); // 기본값 10
  final _notesController = TextEditingController();
  
  DateTime _registrationDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _totalSessionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // 저장 버튼 클릭 시
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 새로운 회원 객체 생성
      final newMember = Member(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        remainingSessions: int.tryParse(_totalSessionController.text) ?? 0,
        totalSessions: int.tryParse(_totalSessionController.text) ?? 0,
        registrationDate: DateTime.now(),
        notes: _notesController.text,
      );

      // 다이얼로그를 닫으면서 생성된 객체 반환
      Navigator.pop(context, newMember);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400, // 너비 고정 (태블릿 등 고려)
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('신규 회원 등록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. 기본 정보 섹션
                _buildSectionTitle('기본 정보'),
                _buildTextField(
                  controller: _nameController,
                  label: '이름',
                  icon: LucideIcons.user,
                  validator: (v) => v!.isEmpty ? '이름을 입력해주세요' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _phoneController,
                  label: '전화번호',
                  icon: LucideIcons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? '전화번호를 입력해주세요' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: '이메일 (선택)',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 24),

                // 2. PT 등록 정보 섹션
                _buildSectionTitle('PT 등록 정보'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _totalSessionController,
                        label: '등록 횟수',
                        icon: LucideIcons.dumbbell,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? '횟수 입력' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _registrationDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _registrationDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: '등록일',
                            prefixIcon: const Icon(LucideIcons.calendar, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          child: Text(DateFormat('yyyy-MM-dd').format(_registrationDate)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. 메모 섹션
                _buildSectionTitle('상세 메모'),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '특이사항, 운동 목적 등을 입력하세요.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),

                const SizedBox(height: 32),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(LucideIcons.check),
                    label: const Text('회원 등록하기', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}