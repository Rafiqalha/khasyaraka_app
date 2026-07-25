// FROZEN: Legacy scaffold — replaced by AcademyHomePage (linear flow).
// This file is kept for compilation safety. Not used by main.dart.
import 'package:flutter/material.dart';
import '../../features/mission/presentation/pages/mission_control_page.dart';
import '../../features/capability/presentation/pages/capability_page.dart';
import '../../features/profile/presentation/pages/profile_dossier_page.dart';
import '../theme/design_tokens.dart';

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MissionControlPage(),
    const SizedBox.shrink(),
    const CapabilityPage(),
    const SizedBox.shrink(),
    const ProfileDossierPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, _pages.length - 1),
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColorTokens.card,
        indicatorColor: AppColorTokens.primaryLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar),
            label: 'Mission',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            selectedIcon: Icon(Icons.auto_graph),
            label: 'Capability',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
