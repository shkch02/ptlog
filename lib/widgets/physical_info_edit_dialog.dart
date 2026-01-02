import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ptlog/constants/app_colors.dart';
import 'package:ptlog/constants/app_text_styles.dart';
import 'package:ptlog/models/index.dart'; // Member 모델이 있는 경로

class PhysicalInfoEditDialog extends StatefulWidget {
  final Member member;

  const PhysicalInfoEditDialog({super.key, required this.member});

  @override
  State<PhysicalInfoEditDialog> createState() => _PhysicalInfoEditDialogState();
}

class _PhysicalInfoEditDialogState extends State<PhysicalInfoEditDialog> {
  final _formKey = GlobalKey<FormState>();

  // 컨트롤러 선언
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _bodyFatController;
  late TextEditingController _skeletalMuscleController;
  late TextEditingController _targetMuscleController;
  late TextEditingController _activityLevelController;
  late TextEditingController _sleepTimeController;
  late TextEditingController _ageController; // age 컨트롤러 추가

  @override
  void initState() {
    super.initState();
    // 기존 데이터로 초기화 (타입 변환)
    _heightController = TextEditingController(text: widget.member.height?.toString() ?? '');
    _weightController = TextEditingController(text: widget.member.weight?.toString() ?? '');
    _targetWeightController = TextEditingController(text: widget.member.targetWeight?.toString() ?? '');
    _bodyFatController = TextEditingController(text: widget.member.bodyFat?.toString() ?? '');
    _skeletalMuscleController = TextEditingController(text: widget.member.skeletalMuscle?.toString() ?? '');
    _targetMuscleController = TextEditingController(text: widget.member.targetMuscle?.toString() ?? '');
    _activityLevelController = TextEditingController(text: widget.member.activityLevel ?? '');
    _sleepTimeController = TextEditingController(text: widget.member.sleepTime ?? '');
    _ageController = TextEditingController(text: widget.member.age?.toString() ?? ''); // age 초기화
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _bodyFatController.dispose();
    _skeletalMuscleController.dispose();
    _targetMuscleController.dispose();
    _activityLevelController.dispose();
    _sleepTimeController.dispose();
    _ageController.dispose(); // age 컨트롤러 dispose
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // 기존 객체 복사본 생성 (타입 파싱)
      final updatedMember = widget.member.copyWith(
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        targetWeight: double.tryParse(_targetWeightController.text),
        age: int.tryParse(_ageController.text),
        bodyFat: double.tryParse(_bodyFatController.text),
        skeletalMuscle: double.tryParse(_skeletalMuscleController.text),
        targetMuscle: double.tryParse(_targetMuscleController.text),
        activityLevel: _activityLevelController.text,
        sleepTime: _sleepTimeController.text,
      );

      // 수정된 객체를 반환하며 팝업 닫기
      Navigator.pop(context, updatedMember);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('신체 정보 수정', style: AppTextStyles.h3),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 입력 필드들
                _buildRowInput('나이', _ageController), // age 필드 추가
                const SizedBox(height: 12),
                _buildRowInput('키 (cm)', _heightController),
                const SizedBox(height: 12),
                _buildRowInput('현재 체중 (kg)', _weightController),
                const SizedBox(height: 12),
                _buildRowInput('목표 체중 (kg)', _targetWeightController),
                const SizedBox(height: 12),
                _buildRowInput('체지방률 (%)', _bodyFatController),
                const SizedBox(height: 12),
                _buildRowInput('골격근량 (kg)', _skeletalMuscleController),
                const SizedBox(height: 12),
                _buildRowInput('목표 골격근량', _targetMuscleController),
                const SizedBox(height: 12),
                _buildTextField('활동량', _activityLevelController, icon: LucideIcons.activity),
                const SizedBox(height: 12),
                _buildTextField('수면 시간', _sleepTimeController, icon: LucideIcons.moon),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('저장하기', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 짧은 숫자 입력용 행 디자인
  Widget _buildRowInput(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: SizedBox(
            height: 40,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }
}