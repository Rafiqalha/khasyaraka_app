import 'package:flutter/material.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PradigiColors.surface,
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profile & Identity",
            style: PradigiTypography.h1,
          ),
          const SizedBox(height: 8),
          Text(
            "Manage your personal learning identity and cognitive preferences.",
            style: PradigiTypography.bodySecondary,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildSectionTitle("Identity"),
                _buildListTile(Icons.person, "Rafiq Alha", "Learner Identity"),
                _buildListTile(Icons.email, "rafiq@example.com", "Primary Account Email"),
                
                const SizedBox(height: 32),
                _buildSectionTitle("Cognitive & Learning Preferences"),
                _buildListTile(Icons.psychology, "Visual & Hands-on Learner", "Prefers code sandboxes and interactive flowcharts"),
                _buildListTile(Icons.speed, "Balanced Pace", "Paced adaptive missions"),
                _buildListTile(Icons.tune, "AI Mentor Rigor", "High precision & technical feedback"),
                
                const SizedBox(height: 32),
                _buildSectionTitle("System Settings"),
                _buildListTile(Icons.dark_mode_outlined, "Theme & Display", "System Default (Light)"),
                _buildListTile(Icons.notifications_none, "Director Notifications", "Actionable briefings enabled"),
                _buildListTile(Icons.shield_outlined, "Data Privacy & Memory", "Persistent learner memory active"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: PradigiTypography.h3.copyWith(color: PradigiColors.primary),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: PradigiColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PradigiColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PradigiColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: PradigiColors.border),
          ),
          child: Icon(icon, color: PradigiColors.textPrimary, size: 20),
        ),
        title: Text(title, style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: PradigiTypography.caption),
        onTap: () {},
      ),
    );
  }
}
