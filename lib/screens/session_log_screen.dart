// lib/screens/session_log_screen.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/index.dart'; // Schedule
import '../widgets/session_log_widgets.dart'; // 분리한 위젯 import

class SessionLogScreen extends StatefulWidget {
  final Schedule schedule;

  const SessionLogScreen({super.key, required this.schedule});

  @override
  State<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _SessionLogScreenState extends State<SessionLogScreen> {
  final List<ExerciseForm> _exercises = [ExerciseForm()];
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 일지 작성'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('임시 저장되었습니다.')));
            },
            child: const Text('임시저장', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. 헤더
            SessionLogHeader(schedule: widget.schedule),
            const SizedBox(height: 24),

            // 2. 운동 목록
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _exercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                return ExerciseCard(
                  index: index,
                  exercise: _exercises[index],
                  showRemoveButton: _exercises.length > 1,
                  onRemove: () => setState(() => _exercises.removeAt(index)),
                  onAddSet: () => setState(() => _exercises[index].sets.add(SetForm())),
                  onRemoveSet: (setIndex) => setState(() => _exercises[index].sets.removeAt(setIndex)),
                );
              },
            ),
            const SizedBox(height: 24),

            // 3. 운동 추가 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _exercises.add(ExerciseForm())),
                icon: const Icon(LucideIcons.plusCircle),
                label: const Text('운동 종목 추가하기'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const Divider(height: 48, thickness: 1),

            // 4. 입력 섹션
            SessionTextInput(
              title: '오늘의 피드백',
              icon: LucideIcons.messageSquare,
              hintText: '피드백을 입력하세요.',
              controller: _feedbackController,
            ),
            const SizedBox(height: 24),
            SessionTextInput(
              title: '메모 / 과제',
              icon: LucideIcons.stickyNote,
              hintText: '회원님에게 전달할 내용을 입력하세요.',
              controller: _memoController,
              maxLines: 2,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE500),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Icon(LucideIcons.share2, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('작성 완료', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}