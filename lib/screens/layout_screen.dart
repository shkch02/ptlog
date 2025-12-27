import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'member_list_screen.dart';
import 'schedule_view_screen.dart';
import 'workout_log_screen.dart';

class LayoutScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const LayoutScreen({super.key, required this.onLogout});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int _selectedIndex = 0;

  // React의 children 렌더링 방식 대신 위젯 리스트 사용
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // 실제로는 여기서 데이터를 넘겨줘야 합니다.
    _screens = [
      MemberListScreen(),
      ScheduleViewScreen(),
      WorkoutLogScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PT Trainer'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.users), label: '회원'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.calendar), label: '스케줄'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.fileText), label: '운동일지'),
        ],
      ),
    );
  }
}