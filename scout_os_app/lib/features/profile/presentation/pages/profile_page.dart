import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/profile/logic/profile_controller.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Consumer<ProfileController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // 1. Header Section (Duolingo Style)
                  _ProfileHeader(
                    displayName: controller.displayName,
                    rankTitle: controller.rankTitle,
                    photoUrl: controller.photoUrl,
                    localPhotoPath: controller.localPhotoPath,
                    onEditName: () => _showEditNameDialog(context, controller),
                    onEditPhoto: () => controller.updatePhoto(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 2. Statistics 3D Cards
                  _StatsRow(
                    streak: controller.streak,
                    totalXp: controller.totalXp,
                    rankBadge: controller.rankBadge,
                  ),
                  
                  const SizedBox(height: 24),

                  // 3. Premium Card (Scout Elite)
                  _ScoutEliteCard(
                    isPro: controller.isPro,
                    onAction: () {},
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 4. Heatmap Section (Wrapped)
                  _HeatmapSection(streak: controller.streak),
                  
                  const SizedBox(height: 24),
                  
                  // 5. Menu / Settings
                  _MenuSection(
                    onLogout: () async {
                      _handleLogout(context, controller);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, ProfileController controller) async {
    debugPrint('🚪 Logout initiated - Clearing all controller states');
    try {
      final trainingController = context.read<TrainingController>();
      trainingController.clearState();
      controller.clearState();
      await controller.logout();
      debugPrint('✅ All controllers cleared, navigating to login');
    } catch (e) {
      debugPrint('⚠️ Error clearing controllers: $e');
      await controller.logout();
    }
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showEditNameDialog(BuildContext context, ProfileController controller) {
    final TextEditingController nameController = TextEditingController(text: controller.displayName);
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.rankTitle,
    required this.photoUrl,
    this.localPhotoPath,
    required this.onEditName,
    required this.onEditPhoto,
  });

  final String displayName;
  final String rankTitle;
  final String? photoUrl;
  final String? localPhotoPath;
  final VoidCallback onEditName;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (localPhotoPath != null) {
      imageProvider = FileImage(File(localPhotoPath!));
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      // Simple check to identify URL vs username/placeholder
      if (photoUrl!.startsWith('http')) {
        imageProvider = NetworkImage(photoUrl!);
      }
    }

    return Row(
      children: [
        // Avatar Section (Right aligned in requirements, but typical UI puts it left. 
        // Prompt said "Layout: Nama User di kiri... Avatar: Di sisi kanan atau tengah".
        // Let's put Avatar Right as requested for "Eksklusif" look).
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      displayName,
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEditName,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 16, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                rankTitle,
                style: AppTextStyles.h3.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Avatar with Edit Button
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                   BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                    : null,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onEditPhoto,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.camera_alt, size: 18, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScoutEliteCard extends StatelessWidget {
  const _ScoutEliteCard({required this.isPro, required this.onAction});

  final bool isPro;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Dark Luxury Gradient
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B4E), Color(0xFF000000)], // Deep Purple to Black
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4A3B69), width: 1), // Subtle lighter border
         boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D1B4E).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.stars,
              size: 150,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SCOUT ELITE',
                            style: GoogleFonts.fredoka(
                              color: const Color(0xFFFFD700), // Gold
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, color: Color(0xFFFFD700), size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPro 
                          ? 'Keanggotaan Aktif\nNikmati akses tanpa batas.'
                          : 'Upgrade Sekarang\nDapatkan fitur eksklusif & lencana khusus.',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isPro)
                  ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('UPGRADE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.streak,
    required this.totalXp,
    required this.rankBadge,
  });

  final int streak;
  final int totalXp;
  final String rankBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Stat3DCard(icon: Icons.local_fire_department_rounded, label: 'Streak', value: streak.toString(), color: const Color(0xFFFF9600))),
        const SizedBox(width: 12),
        Expanded(child: _Stat3DCard(icon: Icons.flash_on_rounded, label: 'Total XP', value: totalXp.toString(), color: const Color(0xFFFFC800))),
        const SizedBox(width: 12),
        Expanded(child: _Stat3DCard(icon: Icons.emoji_events_rounded, label: 'Peringkat', value: rankBadge, color: const Color(0xFF2CB0FA))), // Shorten label for layout
      ],
    );
  }
}

class _Stat3DCard extends StatelessWidget {
  const _Stat3DCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 4), // 3D Bottom effect
            spreadRadius: 0,
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(fontSize: 18, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.grey.shade500, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _HeatmapSection extends StatelessWidget {
  const _HeatmapSection({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 4), // 3D Bottom effect
            spreadRadius: 0,
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Jejak Petualangan',
                style: AppTextStyles.h3.copyWith(color: Colors.black87),
              ),
              const Spacer(),
              const Icon(Icons.history, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          // Use existing logic for grid drawing
          _HeatmapGrid(colors: _generateHeatmap()),
          const SizedBox(height: 12),
          Text(
            '🔥 Login $streak hari berturut-turut!',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Color> _generateHeatmap() {
    // Keeping simple mock logic for visual representation
    final random = DateTime.now().millisecond; // Seed for some variance if needed, or constant
    return List.generate(7 * 10, (index) {
      if (index % 5 == 0 || index % 3 == 0) return AppColors.primary;
      if (index % 2 == 0) return AppColors.primary.withOpacity(0.4);
      return Colors.grey.shade100;
    });
  }
}

class _HeatmapGrid extends StatelessWidget {
  final List<Color> colors;
  const _HeatmapGrid({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 14, // Denser grid
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: colors[index],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         _MenuTile(
          icon: Icons.person_outline,
          title: 'Edit Profil',
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.shield_outlined,
          title: 'Keamanan Akun',
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.logout,
          title: 'Keluar',
          onTap: onLogout,
          isDestructive: true,
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        // No 3D shadow for list items to keep it cleaner
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.primary),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}