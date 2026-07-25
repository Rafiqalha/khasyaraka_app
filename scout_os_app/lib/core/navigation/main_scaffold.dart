import 'package:flutter/material.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/features/home/presentation/pages/training_map_page.dart';
import 'package:scout_os_app/features/mission/presentation/mission_dashboard_page.dart';
import 'package:scout_os_app/features/profile/presentation/pages/profile_page.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const TrainingMapPage(),
    const MissionDashboardPage(),
    const Scaffold(body: Center(child: Text('Arena'))),
    const Scaffold(body: Center(child: Text('Chat'))),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
            }
            return const TextStyle(color: Colors.white54, fontWeight: FontWeight.w500, fontSize: 12);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.deepCharcoal,
          indicatorColor: AppColors.wosmPurple.withOpacity(0.5),
          elevation: 0,
          destinations: [
          NavigationDestination(
            icon: Image.asset(
              'assets/icons/navbar/camping-tent.png',
              width: 24,
              height: 24,
              color: Colors.white54,
              colorBlendMode: BlendMode.srcIn,
            ),
            selectedIcon: Image.asset(
              'assets/icons/navbar/camping-tent.png',
              width: 26,
              height: 26,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
            label: 'Peta',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.explore, color: Colors.white),
            label: 'Misi',
          ),
          NavigationDestination(
            icon: Icon(Icons.stadium_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.stadium, color: Colors.white),
            label: 'Arena',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.forum, color: Colors.white),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Image.asset(
              'assets/icons/navbar/girl.png',
              width: 24,
              height: 24,
              color: Colors.white54,
              colorBlendMode: BlendMode.srcIn,
            ),
            selectedIcon: Image.asset(
              'assets/icons/navbar/girl.png',
              width: 26,
              height: 26,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
            label: 'Profil',
          ),
        ],
      ),
      ),
    );
  }
}
