import 'package:flutter/material.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Import the main tab pages
import 'package:scout_os_app/features/home/presentation/pages/training_path_page.dart';
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

  const DuoMainScaffold({super.key, this.initialIndex = 0});

  @override
  State<DuoMainScaffold> createState() => _DuoMainScaffoldState();
}

class _DuoMainScaffoldState extends State<DuoMainScaffold> {
  late int _currentIndex;

  // List of pages (corresponds to bottom nav items)
  final List<Widget> _pages = [
    const TrainingPathPage(), // Tab 0: Learning Path (Duolingo Layout)
    const MissionDashboardPage(), // Tab 1: Mission Dashboard
    const RankPage(), // Tab 2: Leaderboard
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
      backgroundColor: AppColors.backgroundColor(context),

      // Use IndexedStack to preserve state when switching tabs
      body: IndexedStack(index: _currentIndex, children: _pages),

      // Bottom Navigation Bar (Duolingo Style)
      bottomNavigationBar: _buildDuoBottomNav(),
    );
  }

  // Helper method to build a gradient icon
  Widget _buildGradientIcon(IconData icon, List<Color> colors) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(bounds);
      },
      child: Icon(
        icon,
        size: 32,
        color: Colors.white, // Color must be white for ShaderMask to work
      ),
    );
  }

  // Helper method to build a gradient SVG
  Widget _buildGradientSvg(String assetPath, List<Color> colors) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(bounds);
      },
      child: SvgPicture.asset(
        assetPath,
        width: 32,
        height: 32,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ), // Apply white base for shader
      ),
    );
  }

  Widget _buildDuoBottomNav() {
    return Container(
      height: 90, // Taller matching Duolingo
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              iconWidget: Image.asset(
                'assets/icons/navbar/camping-tent.png',
                width: 32,
                height: 32,
              ),
              index: 0,
              color: AppColors.primary, // Selection color
            ),
            _buildNavItem(
              iconWidget: _buildGradientIcon(
                Icons.hiking_rounded, // Changed to Hiking Icon
                [
                  const Color(0xFFE91E63),
                  const Color(0xFF9C27B0),
                  const Color(0xFFFF9800),
                ], // Pink, Purple, Orange
              ),
              index: 1,
              color: AppColors.warning, // Selection color
            ),
            _buildNavItem(
              iconWidget: _buildGradientIcon(
                Icons.emoji_events_rounded,
                [
                  const Color(0xFFFFC107),
                  const Color(0xFFFF9800),
                  const Color(0xFFF44336),
                ], // Gold, Orange, Red
              ),
              index: 2,
              color: AppColors.accent, // Selection color
            ),
            _buildNavItem(
              iconWidget: Image.asset(
                'assets/icons/navbar/girl.png',
                width: 32,
                height: 32,
              ),
              index: 3,
              color: AppColors.info, // Selection color
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required Widget iconWidget,
    required int index,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70, // Fixed width for touch target and box
        height: 50, // Fixed height for the box
        alignment: Alignment.center,
        decoration: isSelected
            ? BoxDecoration(
                color: color.withOpacity(0.15), // Light background
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color, width: 2),
              )
            : null, // No decoration when inactive
        child: iconWidget,
      ),
    );
  }
}
