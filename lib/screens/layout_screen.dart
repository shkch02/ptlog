import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'member_list_screen.dart';
import 'schedule_view_screen.dart';
import 'workout_log_screen.dart';

class LayoutScreen extends StatefulWidget { //statefulwidget : 몇번 탭을 보고 있는지 상태 기억하는 위젯
  final VoidCallback onLogout;

  const LayoutScreen({super.key, required this.onLogout});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int _selectedIndex = 0; //현재 보고있는 탭 번호

  //탭별로 보여줄 화면 목록
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
      appBar: AppBar( //상단바
        title: const Text('피티로그'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: _screens[_selectedIndex], //중앙 화면 : 선택된 탭에 맞는 화면 보여줌
      bottomNavigationBar: BottomNavigationBar( //하단 네비게이션 바
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