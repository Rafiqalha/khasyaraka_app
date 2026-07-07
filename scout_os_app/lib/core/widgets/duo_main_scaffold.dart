import 'package:flutter/material.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scout_os_app/core/widgets/duo_top_stats_bar.dart';

// Import the main tab pages
import 'package:scout_os_app/features/home/presentation/pages/training_path_page.dart';
import 'package:scout_os_app/features/mission/presentation/mission_dashboard_page.dart';
import 'package:scout_os_app/features/leaderboard/presentation/pages/rank_page.dart';
import 'package:scout_os_app/features/profile/presentation/pages/profile_page.dart';
import 'package:scout_os_app/features/group_chat/presentation/pages/group_chat_home_page.dart'; // [NEW]

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
    const GroupChatHomePage(), // Tab 3: Group Chat
    const ProfilePage(), // Tab 4: Profile
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
              iconWidget: const FaIcon(
                FontAwesomeIcons.campground,
                size: 26,
                color: Colors.white,
              ),
              index: 0,
              color: AppColors.primary,
            ),
            _buildNavItem(
              iconWidget: const FaIcon(
                FontAwesomeIcons.personHiking,
                size: 28,
                color: Colors.white,
              ),
              index: 1,
              color: AppColors.warning,
            ),
            _buildNavItem(
              iconWidget: const FaIcon(
                FontAwesomeIcons.trophy,
                size: 26,
                color: Colors.white,
              ),
              index: 2,
              color: AppColors.accent,
            ),
            _buildNavItem(
              iconWidget: const FaIcon(
                FontAwesomeIcons.solidMessage,
                size: 26,
                color: Colors.white,
              ),
              index: 3,
              color: Colors.blue, // Chat color
            ),
            _buildNavItem(
              iconWidget: const FaIcon(
                FontAwesomeIcons.solidUser,
                size: 26,
                color: Colors.white,
              ),
              index: 4,
              color: AppColors.info,
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
    // Duolingo cyan active styling
    const Color activeBorderColor = Color(0xFF84D8FF);
    const Color activeBgColor = Color(0xFFDDF4FF);

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        height: 50,
        alignment: Alignment.center,
        decoration: isSelected
            ? BoxDecoration(
                color: activeBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: activeBorderColor, width: 2),
              )
            : null,
        child: isSelected 
          ? _buildGradientIconWrapper(iconWidget, color)
              .animate(key: ValueKey('active_$index'))
              .scale(
                begin: const Offset(0.8, 0.8), 
                end: const Offset(1.1, 1.1),
                duration: 200.ms,
                curve: Curves.easeOutBack,
              )
              .then()
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1.0, 1.0), 
                duration: 150.ms,
                curve: Curves.easeInOut,
              )
          : _buildGradientIconWrapper(iconWidget, color), // Inactive keeps color
      ),
    );
  }

  // Wrapper to apply vibrant gradient to the active icon
  Widget _buildGradientIconWrapper(Widget icon, Color baseColor) {
    // Generate a slightly lighter/warmer color for the top of the gradient
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final Color lightColor = hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
    
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightColor, baseColor],
        ).createShader(bounds);
      },
      child: icon,
    );
  }
}
