import 'package:flutter/material.dart';
import '../core/extensions/context_theme.dart';
import 'home_screen.dart';
import 'records_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    RecordsScreen(),
    _PlaceholderScreen(
      icon: Icons.person_rounded,
      title: '준비 중이에요',
      subtitle: '내 정보와 설정 기능이\n곧 추가될 예정이에요',
    ),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: context.colorScheme.primary,
        unselectedItemColor: context.colorScheme.onSurfaceVariant,
        backgroundColor: context.colorScheme.surface,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: context.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: context.bodySmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_rounded),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: '마이',
          ),
        ],
      ),
    );
  }
}

// ─── Placeholder Screen ─────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: context.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: context.bodyMedium.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
