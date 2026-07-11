import 'package:scout_os_app/core/widgets/terminal_loading.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/profile/logic/profile_controller.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:scout_os_app/features/profile/presentation/pages/settings_page.dart';
import 'package:scout_os_app/routes/app_routes.dart';
import 'package:scout_os_app/features/profile/models/public_profile_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.publicProfile, this.isReadOnly = false});

  final PublicProfileModel? publicProfile;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: isReadOnly
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            )
          : null,
      body: SafeArea(
        child: isReadOnly && publicProfile != null
            ? _buildReadOnlyProfile(context, publicProfile!)
            : Consumer<ProfileController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const Center(child: TerminalLoading(fontSize: 20));
                  }
                  return _buildInteractiveProfile(context, controller);
                },
              ),
      ),
    );
  }

  Widget _buildReadOnlyProfile(
    BuildContext context,
    PublicProfileModel profile,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Section (Duolingo Style)
          _ProfileHeader(
            displayName: profile.fullName ?? 'Pengguna',
            rankTitle: _rankFromXp(profile.totalXp).title,
            photoUrl: profile.pictureUrl,
            isReadOnly: true,
            onEditName: () {},
            onEditPhoto: () {},
          ),

          const SizedBox(height: 24),

          // 2. Statistics 3D Cards
          _StatsRow(
            streak: profile.streak,
            totalXp: profile.totalXp,
            rankBadge: _rankFromXp(profile.totalXp).badge,
          ),

          const SizedBox(height: 24),

          // 3. Premium Card (Scout Elite - Disabled in Read-Only)
          _ScoutEliteCard(isPro: false, isReadOnly: true, onAction: () {}),

          const SizedBox(height: 24),

          // 4. Heatmap Section
          _HeatmapSection(streak: profile.streak, activityLog: const []),

          // No Menu Section for Read-Only
        ],
      ),
    );
  }

  Widget _buildInteractiveProfile(
    BuildContext context,
    ProfileController controller,
  ) {
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
            isReadOnly: false,
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
            isReadOnly: false,
            onAction: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.subscription,
              );
              if (result == true) {
                controller.loadProfile(); // Refresh if upgrade success
              }
            },
          ),

          const SizedBox(height: 24),

          // 4. Heatmap Section (Wrapped)
          _HeatmapSection(
            streak: controller.streak,
            activityLog: controller.activityLog,
          ),

          const SizedBox(height: 24),

          // 5. Menu / Settings
          const _MenuSection(),
        ],
      ),
    );
  }

  // Utility to calculate rank for read-only view
  ({String title, String badge}) _rankFromXp(int xp) {
    if (xp >= 2000) return (title: 'Penegak Garuda', badge: 'Level 6');
    if (xp >= 1000) return (title: 'Penegak Laksana', badge: 'Level 5');
    if (xp >= 600) return (title: 'Penegak Bantara', badge: 'Level 4');
    if (xp >= 300) return (title: 'Siaga Tata', badge: 'Level 3');
    if (xp >= 100) return (title: 'Siaga Bantu', badge: 'Level 2');
    return (title: 'Siaga Mula', badge: 'Level 1');
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.rankTitle,
    required this.photoUrl,
    this.localPhotoPath,
    required this.isReadOnly,
    required this.onEditName,
    required this.onEditPhoto,
  });

  final String displayName;
  final String rankTitle;
  final String? photoUrl;
  final String? localPhotoPath;
  final bool isReadOnly;
  final VoidCallback onEditName;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    // Resolve the avatar URL
    String? resolvedUrl;
    if (localPhotoPath == null && photoUrl != null && photoUrl!.isNotEmpty) {
      final url = Environment.resolveUrl(photoUrl!);
      if (url.startsWith('http') || url.startsWith('data:image')) {
        resolvedUrl = url;
      }
    }

    // Build the avatar widget with proper error fallback
    Widget avatarContent;
    if (localPhotoPath != null) {
      avatarContent = Image.file(
        File(localPhotoPath!),
        fit: BoxFit.cover,
        width: 92,
        height: 92,
        errorBuilder: (_, __, ___) => _defaultAvatarIcon(),
      );
    } else if (resolvedUrl != null) {
      if (resolvedUrl.startsWith('data:image')) {
        try {
          final base64String = resolvedUrl.split(',').last;
          avatarContent = Image.memory(
            base64Decode(base64String),
            fit: BoxFit.cover,
            width: 92,
            height: 92,
            errorBuilder: (_, __, ___) => _defaultAvatarIcon(),
          );
        } catch (e) {
          avatarContent = _defaultAvatarIcon();
        }
      } else {
        avatarContent = Image.network(
          resolvedUrl,
          fit: BoxFit.cover,
          width: 92,
          height: 92,
          errorBuilder: (_, error, ___) {
            debugPrint('⚠️ [PROFILE] Avatar load failed: $error');
            return _defaultAvatarIcon();
          },
        );
      }
    } else {
      avatarContent = _defaultAvatarIcon();
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
                      displayName.isNotEmpty ? displayName : 'Pengguna',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.displayLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isReadOnly) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onEditName,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ],
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
              child: ClipOval(child: avatarContent),
            ),
            if (!isReadOnly)
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
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _defaultAvatarIcon() {
    return Container(
      width: 92,
      height: 92,
      color: AppColors.primary.withOpacity(0.2),
      child: const Icon(Icons.person, size: 50, color: AppColors.primary),
    );
  }
}

class _ScoutEliteCard extends StatelessWidget {
  const _ScoutEliteCard({
    required this.isPro,
    required this.isReadOnly,
    required this.onAction,
  });

  final bool isPro;
  final bool isReadOnly;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    // 3D FLAT STYLE - Elite (Black/Gold)
    const Color faceColor = Color(0xFF212121); // Dark Charcoal/Black
    const Color lipColor = Colors.black; // Pure Black for depth
    const Color shadowColor = Colors.black12; // Much softer shadow

    return Container(
      decoration: BoxDecoration(
        color: lipColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            offset: Offset(0, 4), // Reduced offset
            blurRadius: 8, // Reduced blur
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 6), // Lip Height
      child: Container(
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          ),
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
                            const Icon(
                              Icons.verified,
                              color: Color(0xFFFFD700),
                              size: 20,
                            ),
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
                  if (!isPro && !isReadOnly)
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
                      child: const Text(
                        'UPGRADE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (!isPro && isReadOnly)
                    Text(
                      'Free Account',
                      style: GoogleFonts.fredoka(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
        // Streak - ORANGE
        Expanded(
          child: _Profile3DCard(
            label: 'Streak',
            value: streak.toString(),
            customIcon: const FaIcon(FontAwesomeIcons.fire, color: Colors.white, size: 28),
            faceColor: const Color(0xFFFF9600), // Orange
            lipColor: const Color(0xFFE65100), // Dark Orange
          ),
        ),
        const SizedBox(width: 12),
        // XP - BLUE (Contrast)
        Expanded(
          child: _Profile3DCard(
            label: 'Total XP',
            value: totalXp.toString(),
            customIcon: const FaIcon(FontAwesomeIcons.solidStar, color: Colors.white, size: 28),
            faceColor: const Color(0xFF2CB0FA), // Blue
            lipColor: const Color(0xFF0277BD), // Dark Blue
          ),
        ),
        const SizedBox(width: 12),
        // Rank - PURPLE
        Expanded(
          child: _Profile3DCard(
            label: 'Peringkat',
            value: rankBadge,
            customIcon: const FaIcon(FontAwesomeIcons.trophy, color: Colors.white, size: 28),
            faceColor: const Color(0xFF9C27B0), // Purple
            lipColor: const Color(0xFF7B1FA2), // Dark Purple
          ),
        ),
      ],
    );
  }
}

class _Profile3DCard extends StatelessWidget {
  const _Profile3DCard({
    this.icon,
    this.customIcon,
    required this.label,
    required this.value,
    required this.faceColor,
    required this.lipColor,
  });

  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final String value;
  final Color faceColor;
  final Color lipColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: faceColor, // Main Face Color
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            icon != null
                ? Icon(icon, color: Colors.white, size: 28)
                : (customIcon ?? const SizedBox.shrink()),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.fredoka(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapSection extends StatelessWidget {
  const _HeatmapSection({required this.streak, required this.activityLog});

  final int streak;
  final List<String> activityLog;

  @override
  Widget build(BuildContext context) {
    // GREEN THEME (Nature/Jejak)
    const Color faceColor = Color(0xFF58CC02); // Scout Green
    const Color lipColor = Color(0xFF46A302); // Dark Green

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: lipColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Very subtle shadow
            offset: const Offset(0, 2), // Reduced offset
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Jejak Petualangan',
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const Spacer(),
                const FaIcon(FontAwesomeIcons.clockRotateLeft, color: Colors.white70, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            // Real-time horizontal calendar timeline
            _TimelineCalendar(activityLog: activityLog),
            const SizedBox(height: 16),
            Text(
              '🔥 Login $streak hari berturut-turut!',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _TimelineCalendar extends StatelessWidget {
  final List<String> activityLog;
  const _TimelineCalendar({required this.activityLog});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final today = DateTime.parse(todayStr);

    // Get last 14 days (including today)
    final List<DateTime> days = List.generate(14, (index) {
      return today.subtract(Duration(days: 13 - index));
    });

    final monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month & Year header
        Text(
          '${monthNames[now.month]} ${now.year}',
          style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            // Start scrolled to the right (today)
            controller: ScrollController(initialScrollOffset: 14 * 60.0),
            itemBuilder: (context, index) {
              final date = days[index];
              final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
              final isActive = activityLog.contains(dateStr);
              final isToday = index == 13;

              return Container(
                width: 52,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: isToday ? Border.all(color: Colors.white, width: 2) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayNames[date.weekday - 1],
                      style: TextStyle(
                        color: isActive ? const Color(0xFF58CC02) : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isActive)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(FontAwesomeIcons.fire, color: Color(0xFFFF9600), size: 12),
                          const SizedBox(width: 2),
                          const Text(
                            '1',
                            style: TextStyle(
                              color: Color(0xFFFF9600),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${date.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuTile(
          icon: Icons.settings_outlined,
          title: 'Pengaturan',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
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
    // BLUE GREY THEME for Settings
    final Color faceColor = isDestructive
        ? const Color(0xFFFF4B4B)
        : const Color(0xFF607D8B); // Red id destructive, else BlueGrey
    final Color lipColor = isDestructive
        ? const Color(0xFFEA2B2B)
        : const Color(0xFF455A64);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lipColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Very subtle shadow
            offset: const Offset(0, 2), // Reduced offset
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 4), // Lip
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ), // Inner padding
            decoration: BoxDecoration(
              color: faceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
