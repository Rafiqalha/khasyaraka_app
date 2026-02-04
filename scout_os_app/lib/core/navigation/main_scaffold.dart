import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/features/home/presentation/pages/training_map_page.dart';
import 'package:scout_os_app/features/mission/presentation/mission_dashboard_page.dart';
import 'package:scout_os_app/features/leaderboard/presentation/pages/rank_page.dart';
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
    const RankPage(),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.scoutBg,
        indicatorColor: AppColors.goldBadge.withValues(alpha: 0.3),
        elevation: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppColors.scoutBrown),
            label: 'Peta',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.scoutBrown),
            label: 'Misi',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: AppColors.scoutBrown),
            label: 'Rank',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.scoutBrown),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
