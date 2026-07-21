import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/profile/logic/profile_controller.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scout_os_app/features/profile/presentation/pages/settings_page.dart';
import 'package:scout_os_app/routes/app_routes.dart';
import 'package:scout_os_app/features/profile/models/public_profile_model.dart';

import 'package:scout_os_app/core/widgets/terminal_loading.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.publicProfile, this.isReadOnly = false});

  final PublicProfileModel? publicProfile;
  final bool isReadOnly;

  static const _bg = Color(0xFF0D1117);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: isReadOnly
          ? AppBar(backgroundColor: Colors.transparent, elevation: 0)
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

  Widget _buildReadOnlyProfile(BuildContext context, PublicProfileModel p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(children: [
        _ProfileHeader(displayName: p.fullName ?? 'Operator', rankTitle: _rankFromXp(p.totalXp).title, photoUrl: p.pictureUrl, isReadOnly: true, onEditName: () {}, onEditPhoto: () {}),
        const SizedBox(height: 24),
        _StatsRow(streak: p.streak, totalXp: p.totalXp, rankBadge: _rankFromXp(p.totalXp).badge),
        const SizedBox(height: 24),
        _ProCard(isPro: false, isReadOnly: true, onAction: () {}),
        const SizedBox(height: 24),
        _SystemLogsSection(streak: p.streak, activityLog: const []),
      ]),
    );
  }

  Widget _buildInteractiveProfile(BuildContext context, ProfileController ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(children: [
        _ProfileHeader(displayName: ctrl.displayName, rankTitle: ctrl.rankTitle, photoUrl: ctrl.photoUrl, localPhotoPath: ctrl.localPhotoPath, isReadOnly: false, onEditName: () => _showEditNameDialog(context, ctrl), onEditPhoto: () => ctrl.updatePhoto()),
        const SizedBox(height: 24),
        _StatsRow(streak: ctrl.streak, totalXp: ctrl.totalXp, rankBadge: ctrl.rankBadge),
        const SizedBox(height: 24),
        _ProCard(isPro: ctrl.isPro, isReadOnly: false, onAction: () async {
          final r = await Navigator.pushNamed(context, AppRoutes.subscription);
          if (r == true) ctrl.loadProfile();
        }),
        const SizedBox(height: 24),
        _SystemLogsSection(streak: ctrl.streak, activityLog: ctrl.activityLog),
        const SizedBox(height: 24),
        const _MenuSection(),
      ]),
    );
  }

  ({String title, String badge}) _rankFromXp(int xp) {
    if (xp >= 2000) return (title: 'Lead Threat Hunter', badge: 'Tier 6');
    if (xp >= 1000) return (title: 'Senior Security Analyst', badge: 'Tier 5');
    if (xp >= 600) return (title: 'Incident Responder', badge: 'Tier 4');
    if (xp >= 300) return (title: 'Junior SOC Analyst', badge: 'Tier 3');
    if (xp >= 100) return (title: 'Security Operator', badge: 'Tier 2');
    return (title: 'Cyber Candidate', badge: 'Tier 1');
  }

  void _showEditNameDialog(BuildContext context, ProfileController ctrl) {
    final tc = TextEditingController(text: ctrl.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Alias'),
        content: TextField(controller: tc, decoration: const InputDecoration(hintText: 'Operator Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { ctrl.updateName(tc.text); Navigator.pop(ctx); }, child: const Text('Save')),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.streak, required this.totalXp, required this.rankBadge});
  final int streak;
  final int totalXp;
  final String rankBadge;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _Card(icon: FontAwesomeIcons.fire, value: '$streak', label: 'STREAK', color: const Color(0xFFFF9600))),
      const SizedBox(width: 10),
      Expanded(child: _Card(icon: FontAwesomeIcons.solidStar, value: '$totalXp', label: 'TOTAL XP', color: const Color(0xFF2CB0FA))),
      const SizedBox(width: 10),
      Expanded(child: _Card(icon: FontAwesomeIcons.trophy, value: rankBadge, label: 'TIER LEVEL', color: const Color(0xFFD29922))),
    ]);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.value, required this.label, required this.color});
  final FaIconData icon;
  final String value;
  final String label;
  final Color color;

  static const _card = Color(0xFF161B22);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Column(children: [
        FaIcon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color.withAlpha(180), letterSpacing: 1)),
      ]),
    );
  }
}

class _ProCard extends StatelessWidget {
  const _ProCard({required this.isPro, required this.isReadOnly, required this.onAction});
  final bool isPro;
  final bool isReadOnly;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD29922).withAlpha(80)),
        ),
        child: Stack(children: [
          Positioned(right: -10, top: -10, child: Icon(Icons.shield, size: 100, color: Colors.white.withAlpha(8))),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Flexible(child: Text('PRADIGI CYBER ANALYST PRO', style: TextStyle(color: Color(0xFFD29922), fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'JetBrainsMono', letterSpacing: 0.3))),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Color(0xFFD29922), size: 16),
                  ]),
                  const SizedBox(height: 6),
                  Text(isPro ? 'Access Active — API keys provisioned.' : 'Unlock full API access & premium tools.', style: GoogleFonts.plusJakartaSans(color: Colors.white.withAlpha(180), fontSize: 11)),
                ]),
              ),
              const SizedBox(width: 8),
              if (!isPro && !isReadOnly)
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD29922), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  child: Text('[ UNLOCK ]', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w800, fontSize: 10)),
                ),
              if (!isPro && isReadOnly)
                Text('Free Tier', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 11)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _SystemLogsSection extends StatelessWidget {
  const _SystemLogsSection({required this.streak, required this.activityLog});
  final int streak;
  final List<String> activityLog;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = ['', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final today = DateTime(now.year, now.month, now.day);
    final dateList = List.generate(14, (i) => today.subtract(Duration(days: 13 - i)));

    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3FB950), width: 1.5),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.terminal, color: Color(0xFF3FB950), size: 16),
            const SizedBox(width: 8),
            Text('SYSTEM LOGS — ${months[now.month]} ${now.year}', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF3FB950), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF3FB950).withAlpha(30), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF3FB950).withAlpha(80))), child: Text('ONLINE', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF3FB950), fontSize: 9, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            height: 62,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dateList.length,
              itemBuilder: (_, i) {
                final d = dateList[i];
                final dStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                final active = activityLog.contains(dStr);
                final isToday = i == 13;
                return Container(
                  width: 48, margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF3FB950).withAlpha(25) : const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isToday ? const Color(0xFF3FB950) : const Color(0xFF30363D)),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(days[d.weekday - 1], style: TextStyle(color: active ? const Color(0xFF3FB950) : const Color(0xFF484F58), fontSize: 10, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    if (active) const FaIcon(FontAwesomeIcons.bolt, color: Color(0xFFD29922), size: 10)
                    else Text('${d.day}', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF8B949E), fontSize: 13, fontWeight: FontWeight.w800)),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text('> streak_active=${streak}d  |  sessions_today=1  |  status=operational', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF3FB950).withAlpha(150), fontSize: 10)),
        ]),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.displayName, required this.rankTitle, required this.photoUrl, this.localPhotoPath, required this.isReadOnly, required this.onEditName, required this.onEditPhoto});
  final String displayName;
  final String rankTitle;
  final String? photoUrl;
  final String? localPhotoPath;
  final bool isReadOnly;
  final VoidCallback onEditName;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    String? resolvedUrl;
    if (localPhotoPath == null && photoUrl != null && photoUrl!.isNotEmpty) {
      final url = Environment.resolveUrl(photoUrl!);
      if (url.startsWith('http') || url.startsWith('data:image')) resolvedUrl = url;
    }

    Widget avatar;
    if (localPhotoPath != null) {
      avatar = Image.file(File(localPhotoPath!), fit: BoxFit.cover, width: 84, height: 84, errorBuilder: (_, __, ___) => _defaultAvatar());
    } else if (resolvedUrl != null && resolvedUrl.startsWith('data:image')) {
      try {
        avatar = Image.memory(base64Decode(resolvedUrl.split(',').last), fit: BoxFit.cover, width: 84, height: 84, errorBuilder: (_, __, ___) => _defaultAvatar());
      } catch (_) { avatar = _defaultAvatar(); }
    } else if (resolvedUrl != null) {
      avatar = Image.network(resolvedUrl, fit: BoxFit.cover, width: 84, height: 84, errorBuilder: (_, __, ___) => _defaultAvatar());
    } else {
      avatar = _defaultAvatar();
    }

    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(displayName.isNotEmpty ? displayName : 'Operator', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFFC9D1D9)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (!isReadOnly) ...[
              const SizedBox(width: 8),
              GestureDetector(onTap: onEditName, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF30363D), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.edit, size: 14, color: Color(0xFF8B949E)))),
            ],
          ]),
          const SizedBox(height: 4),
          Text(rankTitle, style: GoogleFonts.jetBrainsMono(color: const Color(0xFF58A6FF), fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
      const SizedBox(width: 16),
      Stack(children: [
        Container(width: 92, height: 92, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF3FB950), width: 2)), child: ClipOval(child: avatar)),
        if (!isReadOnly) Positioned(right: 0, bottom: 0, child: GestureDetector(onTap: onEditPhoto, child: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: const Color(0xFF161B22), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF30363D))), child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF58A6FF))))),
      ]),
    ]);
  }

  Widget _defaultAvatar() {
    return Container(width: 84, height: 84, color: const Color(0xFF161B22), child: const Icon(Icons.shield, size: 40, color: Color(0xFF58A6FF)));
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF30363D))),
        child: const Row(children: [
          Icon(Icons.settings, color: Color(0xFF8B949E), size: 20),
          SizedBox(width: 14),
          Expanded(child: Text('Settings', style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 14, fontWeight: FontWeight.w600))),
          Icon(Icons.chevron_right, color: Color(0xFF484F58)),
        ]),
      ),
    );
  }
}
