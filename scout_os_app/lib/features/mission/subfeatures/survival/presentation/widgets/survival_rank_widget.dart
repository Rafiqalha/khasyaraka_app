import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';
import 'package:scout_os_app/routes/app_routes.dart';

/// Compact widget to display user's survival mastery stats on the dashboard
class SurvivalRankWidget extends StatelessWidget {
  const SurvivalRankWidget({super.key});

  static const _surface = Color(0xFF121212);
  static const _neonGreen = Color(0xFF00E676);
  static const _gold = Color(0xFFFFD600);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SurvivalMasteryController>();
    
    if (controller.isLoading) {
      return _buildLoadingCard();
    }

    final highestTool = controller.highestLevelTool;
    final totalXp = controller.totalXp;
    final avgLevel = controller.averageLevel;

    if (highestTool == null) {
      return _buildEmptyCard(context);
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.survivalTools),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _neonGreen, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _neonGreen.withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.military_tech,
                  color: _gold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'SURVIVAL MASTERY',
                  style: GoogleFonts.cinzel(
                    color: _gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    label: 'Highest Level',
                    value: 'Lv. ${highestTool.currentLevel}',
                    subtitle: highestTool.rankTitle,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatColumn(
                    label: 'Total XP',
                    value: totalXp.toString(),
                    subtitle: 'Avg Lv ${avgLevel.toStringAsFixed(1)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Tools',
                  style: GoogleFonts.poppins(
                    color: _neonGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: _neonGreen,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            color: _neonGreen,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: _neonGreen,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.survivalTools),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.explore,
                  color: _gold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'SURVIVAL TOOLS',
                  style: GoogleFonts.cinzel(
                    color: _gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Start using survival tools to gain XP and level up!',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Get Started',
                  style: GoogleFonts.poppins(
                    color: _neonGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: _neonGreen,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
