import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'member_list_screen.dart';
import 'schedule_view_screen.dart';
import 'home_screen.dart';

class LayoutScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const LayoutScreen({super.key, required this.onLogout});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int _selectedIndex = 1;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const MemberListScreen(),
      HomeScreen(onGoToSchedule: () => _onItemTapped(2)),
      const ScheduleViewScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피티로그'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: _screens[_selectedIndex],

      // 1. 홈 버튼 설정
      floatingActionButton: SizedBox(
        width: 72, 
        height: 72,
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(1),
          backgroundColor: _selectedIndex == 1 ? Colors.blue[700] : Colors.blue,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(LucideIcons.home, size: 32, color: Colors.white),
        ),
      ),
      
      // 2. 위치 설정을 커스텀 클래스로 변경 (offsetY: 30 만큼 아래로 내림)
      floatingActionButtonLocation: const CustomFloatingActionButtonLocation(offsetY: 30),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 80,
        color: Colors.white,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: LucideIcons.users,
              label: '회원',
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            const SizedBox(width: 48), // FAB 공간 확보
            _buildNavItem(
              icon: LucideIcons.calendar,
              label: '스케줄',
              isSelected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 홈 버튼 위치를 커스텀하기 위한 클래스 (에러 수정된 버전)
// ----------------------------------------------------------------------
class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final double offsetY;

  const CustomFloatingActionButtonLocation({this.offsetY = 0});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // 1. 가로 위치: 화면 중앙
    final double x = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;

    // 2. 세로 위치 계산
    // 수정됨: contentBottom이 곧 하단 바(BottomAppBar)의 윗선 위치입니다.
    final double barTopY = scaffoldGeometry.contentBottom;

    // 최종 Y 좌표: 바의 윗선 - (버튼 절반 높이) + 오프셋
    final double y = barTopY - (scaffoldGeometry.floatingActionButtonSize.height / 2.0) + offsetY;

    return Offset(x, y);
  }
}