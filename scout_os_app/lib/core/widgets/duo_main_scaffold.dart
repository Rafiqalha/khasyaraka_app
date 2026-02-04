import 'package:flutter/material.dart';
import 'package:scout_os_app/core/config/duo_theme.dart';

// Import the main tab pages
import 'package:scout_os_app/features/home/presentation/pages/training_map_page.dart';
import 'package:scout_os_app/features/mission/presentation/mission_dashboard_page.dart';
import 'package:scout_os_app/features/leaderboard/presentation/pages/rank_page.dart';
import 'package:scout_os_app/features/profile/presentation/pages/profile_page.dart';

/// DUOLINGO-STYLE MAIN SCAFFOLD
/// This is the skeleton that holds the entire app structure:
/// - Bottom navigation bar (existing widget, now styled with Duolingo theme)
/// - IndexedStack for state preservation between tabs
/// - Bright, playful design

class DuoMainScaffold extends StatefulWidget {
  final int initialIndex;
  
  const DuoMainScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<DuoMainScaffold> createState() => _DuoMainScaffoldState();
}

class _DuoMainScaffoldState extends State<DuoMainScaffold> {
  late int _currentIndex;

  // List of pages (corresponds to bottom nav items)
  final List<Widget> _pages = [
    const TrainingMapPage(),  // Tab 0: Learning Path (Scout-themed Duolingo style!)
    const MissionDashboardPage(),    // Tab 1: Mission Dashboard
    const RankPage(),               // Tab 2: Leaderboard
    const ProfilePage(), // Tab 3: Profile
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoTheme.duoSnow,
      
      // Use IndexedStack to preserve state when switching tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // Bottom Navigation Bar (Duolingo Style)
      bottomNavigationBar: _buildDuoBottomNav(),
    );
  }

  Widget _buildDuoBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: DuoTheme.duoWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DuoTheme.spaceL,
            vertical: DuoTheme.spaceS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Peta',
                index: 0,
                color: DuoTheme.duoGreen,
              ),
              _buildNavItem(
                icon: Icons.explore_rounded,
                label: 'Misi',
                index: 1,
                color: DuoTheme.duoOrange,
              ),
              _buildNavItem(
                icon: Icons.emoji_events_rounded,
                label: 'Rank',
                index: 2,
                color: DuoTheme.duoYellow,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                index: 3,
                color: DuoTheme.duoBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: DuoTheme.spaceS),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated scale
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..scaleByDouble(
                    isSelected ? 1.1 : 1.0,
                    isSelected ? 1.1 : 1.0,
                    1.0,
                    1.0,
                  ),
                child: Icon(
                  icon,
                  size: isSelected ? 30 : 26,
                  color: isSelected ? color : DuoTheme.duoGreyDark,
                ),
              ),
              const SizedBox(height: DuoTheme.spaceXS),
              
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? color : DuoTheme.duoGreyDark,
                ),
              ),
              
              // Active indicator dot
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
