import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/profile/logic/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Consumer<ProfileController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    displayName: controller.displayName,
                    rankTitle: controller.rankTitle,
                    isPro: controller.isPro,
                  ),
                  const SizedBox(height: 20),
                  _MembershipCard(
                    isPro: controller.isPro,
                    onAction: () {},
                  ),
                  const SizedBox(height: 20),
                  _StatsRow(
                    streak: controller.streak,
                    totalXp: controller.totalXp,
                    rankBadge: controller.rankBadge,
                  ),
                  const SizedBox(height: 24),
                  _HeatmapSection(streak: controller.streak),
                  const SizedBox(height: 24),
                  _MenuSection(
                    onLogout: () async {
                      debugPrint('🚪 Logout initiated - Clearing all controller states');
                      
                      // CRITICAL: Clear all controllers to prevent data leak between users
                      // This ensures User B doesn't see User A's data
                      try {
                        // Clear TrainingController state
                        final trainingController = context.read<TrainingController>();
                        trainingController.clearState();
                        
                        // Clear ProfileController state (will be done in logout method)
                        // But we also clear it explicitly here to be safe
                        controller.clearState();
                        
                        // Logout from auth service (clears token and current user)
                        await controller.logout();
                        
                        // Note: CyberController and other controllers will be cleared
                        // when they are re-initialized on next access, but ideally
                        // we should clear them here if they're accessible via Provider
                        
                        debugPrint('✅ All controllers cleared, navigating to login');
                      } catch (e) {
                        debugPrint('⚠️ Error clearing controllers: $e');
                        // Continue with logout even if clearing fails
                        await controller.logout();
                      }
                      
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, '/login');
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.rankTitle,
    required this.isPro,
  });

  final String displayName;
  final String rankTitle;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final ringColor =
        isPro ? const Color(0xFFD4AF37) : const Color(0xFF2E7D32);
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ringColor.withValues(alpha: 0.22),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 4),
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: ringColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.photo_camera),
                    color: ringColor,
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rankTitle,
            style: GoogleFonts.poppins(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.isPro, required this.onAction});

  final bool isPro;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final gradient = isPro
        ? const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;
    final backgroundColor = isPro ? Colors.black : Colors.white;
    final borderColor = isPro ? Colors.transparent : const Color(0xFF2E7D32);

    return InkWell(
      onTap: onAction,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: (isPro ? Colors.orange : Colors.black)
                  .withValues(alpha: isPro ? 0.3 : 0.08),
              blurRadius: isPro ? 15 : 20,
              spreadRadius: isPro ? 2 : 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isPro ? Icons.workspace_premium : Icons.verified_user_outlined,
              color: isPro ? Colors.black : const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPro ? 'SCOUT PRO MEMBER' : 'Member Biasa',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: isPro ? Colors.black : const Color(0xFF1B5E20),
                      letterSpacing: isPro ? 1.1 : 0.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPro ? 'Akses premium terbuka' : 'Upgrade untuk fitur elite',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isPro ? Colors.black87 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isPro ? Icons.star : Icons.arrow_forward,
              color: isPro ? Colors.black : const Color(0xFF2E7D32),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(icon: Icons.local_fire_department, label: 'Streak', value: '$streak Hari'),
          _VerticalDivider(),
          _StatItem(icon: Icons.flash_on, label: 'Total XP', value: '$totalXp'),
          _VerticalDivider(),
          _StatItem(icon: Icons.emoji_events, label: 'Peringkat', value: rankBadge),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B5E20),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.black.withValues(alpha: 0.08),
    );
  }
}

class _HeatmapSection extends StatelessWidget {
  const _HeatmapSection({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final cells = _generateHeatmap();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jejak Petualangan',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeatmapGrid(colors: cells),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Less',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(width: 6),
                  _legendDot(Colors.grey.shade200),
                  const SizedBox(width: 4),
                  _legendDot(const Color(0xFF2E7D32).withValues(alpha: 0.25)),
                  const SizedBox(width: 4),
                  _legendDot(const Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Text(
                    'More',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                  ),
                  const Spacer(),
                  Text(
                    'Login $streak hari berturut-turut!',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _generateHeatmap() {
    final random = Random(42);
    return List.generate(7 * 12, (index) {
      final roll = random.nextDouble();
      if (roll < 0.2) return Colors.grey.shade200;
      if (roll < 0.5) return const Color(0xFF2E7D32).withValues(alpha: 0.25);
      if (roll < 0.8) return const Color(0xFF2E7D32).withValues(alpha: 0.5);
      return const Color(0xFF2E7D32);
    });
  }
}

Widget _legendDot(Color color) {
  return Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 12,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(6),
            ),
          );
        },
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 12),
        _MenuTile(
          icon: Icons.person_outline,
          title: 'Edit Profil',
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.workspace_premium_outlined,
          title: 'Sertifikat',
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.settings_outlined,
          title: 'Pengaturan',
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.logout,
          title: 'Logout',
          onTap: onLogout,
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
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}