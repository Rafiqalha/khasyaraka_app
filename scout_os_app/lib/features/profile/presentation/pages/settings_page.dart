import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/profile/logic/profile_controller.dart';
import 'package:scout_os_app/shared/theme/theme_controller.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.fredoka(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. UMUM (Notifications) - BLUE
          _sectionHeader('Umum'),
          _Settings3DCard(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            faceColor: const Color(0xFF2CB0FA), // Blue
            lipColor: const Color(0xFF0277BD),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // 2. TAMPILAN (Dark Mode) - PURPLE
          _sectionHeader('Tampilan'),
          Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return _Settings3DCard(
                context,
                icon: themeController.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
                title: 'Mode Gelap',
                subtitle: themeController.isDarkMode ? 'Nyala' : 'Mati',
                faceColor: const Color(0xFF9C27B0), // Purple
                lipColor: const Color(0xFF7B1FA2),
                onTap: () {
                  themeController.toggleTheme(!themeController.isDarkMode);
                },
                trailing: Switch(
                  value: themeController.isDarkMode,
                  onChanged: (value) => themeController.toggleTheme(value),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.purple.shade200,
                  inactiveThumbColor: Colors.purple,
                  inactiveTrackColor: Colors.purple.shade50,
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // 3. AKUN (Edit Profile) - GREEN
          _sectionHeader('Akun'),
          _Settings3DCard(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profil',
            faceColor: const Color(0xFF58CC02), // Green
            lipColor: const Color(0xFF46A302),
            onTap: () {
              final controller = context.read<ProfileController>();
              _showEditNameDialog(context, controller);
            },
          ),
          // Logout - RED
          _Settings3DCard(
            context,
            icon: Icons.logout,
            title: 'Keluar',
            faceColor: const Color(0xFFFF4B4B), // Red
            lipColor: const Color(0xFFEA2B2B),
            onTap: () => _handleLogout(context),
            isDestructive: true,
          ),

          const SizedBox(height: 24),

          // 4. TENTANG (Info) - BLUE GREY
          _sectionHeader('Tentang'),
          _Settings3DCard(
            context,
            icon: Icons.info_outline,
            title: 'Versi Aplikasi',
            subtitle: '1.1.0',
            faceColor: const Color(0xFF607D8B), // Blue Grey
            lipColor: const Color(0xFF455A64),
            onTap: () {},
          ),
          _Settings3DCard(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Kebijakan Privasi',
            faceColor: const Color(0xFF607D8B), // Blue Grey
            lipColor: const Color(0xFF455A64),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.fredoka(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // REPLACED _settingTile with _Settings3DCard
  Widget _Settings3DCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    Widget? trailing,
    required Color faceColor,
    required Color lipColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lipColor, // The 3D Depth color (Lip)
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Very subtle shadow
            offset: const Offset(0, 2), // Reduced offset
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 4), // Lip Height
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ), // Comfortable touch target
            decoration: BoxDecoration(
              color: faceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.1,
                    ), // Subtle darkening behind icon
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.fredoka(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white70,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    debugPrint('🚪 Logout initiated from Settings');

    try {
      // 1. Clear training and profile controller states
      final trainingController = context.read<TrainingController>();
      final profileController = context.read<ProfileController>();

      trainingController.clearState();
      profileController.clearState();

      // 2. Perform complete logout via AuthController
      final authController = context.read<AuthController>();
      await authController.logout();

      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('⚠️ Error during logout: $e');
      final authController = context.read<AuthController>();
      await authController.logout();
    }

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
  }

  void _showEditNameDialog(BuildContext context, ProfileController controller) {
    final TextEditingController nameController = TextEditingController(
      text: controller.displayName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ganti Nama'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Nama Lengkap',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateName(nameController.text);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
