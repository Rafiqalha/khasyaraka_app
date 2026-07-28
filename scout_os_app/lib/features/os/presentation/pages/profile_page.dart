import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import '../providers/os_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(osProfileProvider);

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
              children: profileAsync.when(
                data: (data) => [
                  _buildSectionTitle("Identity"),
                  ...data.identity.map((i) => _buildListTile(i.icon, i.title, i.subtitle)),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle("Cognitive & Learning Preferences"),
                  ...data.preferences.map((p) => _buildListTile(p.icon, p.title, p.subtitle)),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle("System Settings"),
                  ...data.settings.map((s) => _buildListTile(s.icon, s.title, s.subtitle)),
                ],
                loading: () => _defaultItems(),
                error: (e, st) => _defaultItems(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _defaultItems() {
    return [
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
    ];
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: PradigiColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: PradigiColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: PradigiColors.textSecondary, size: 20),
        title: Text(title, style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: PradigiTypography.caption),
        onTap: () {},
      ),
    );
  }
}
