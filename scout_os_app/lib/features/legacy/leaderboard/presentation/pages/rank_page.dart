import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/leaderboard/controllers/leaderboard_controller.dart';
import 'package:scout_os_app/features/leaderboard/models/leaderboard_model.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  static const _bg = Color(0xFF0D1117);
  static const _card = Color(0xFF161B22);
  static const _border = Color(0xFF30363D);
  static const _green = Color(0xFF3FB950);
  static const _blue = Color(0xFF58A6FF);
  static const _gold = Color(0xFFD29922);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardController>().loadLeaderboard(limit: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.leaderboard, color: _green, size: 22),
            SizedBox(width: 8),
            Text('RANKING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _green, letterSpacing: 1.5)),
          ],
        ),
      ),
      body: Consumer<LeaderboardController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading && ctrl.topUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: _green));
          }

          if (ctrl.errorMessage != null && ctrl.topUsers.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off, color: Colors.white24, size: 48),
                const SizedBox(height: 12),
                Text(ctrl.errorMessage!, style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => ctrl.loadLeaderboard(), style: ElevatedButton.styleFrom(backgroundColor: _green), child: const Text('Retry')),
              ]),
            );
          }

          return Column(children: [
            _buildScopeBar(ctrl),
            const SizedBox(height: 8),
            ctrl.topUsers.isEmpty
                ? const Expanded(child: Center(child: Text('No data', style: TextStyle(color: Colors.white24, fontSize: 14))))
                : Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ctrl.refresh(),
                      color: _green,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 120),
                        itemCount: ctrl.topUsers.length + (ctrl.myRank != null ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i < ctrl.topUsers.length) {
                            return _buildRow(ctrl.topUsers[i]);
                          }
                          return _buildMyRow(ctrl.myRank!);
                        },
                      ),
                    ),
                  ),
          ]);
        },
      ),
    );
  }

  Widget _buildScopeBar(LeaderboardController ctrl) {
    final scopes = [
      {'key': 'kecamatan', 'label': 'KEC'},
      {'key': 'kota', 'label': 'KAB'},
      {'key': 'provinsi', 'label': 'PROV'},
      {'key': 'country', 'label': 'NEGARA'},
      {'key': 'global', 'label': 'GLOBAL'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
      child: Row(
        children: scopes.map((s) {
          final sel = ctrl.activeScope == s['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => ctrl.loadLeaderboard(scope: s['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: sel ? BoxDecoration(color: const Color(0xFF1E3A5F), borderRadius: BorderRadius.circular(6)) : null,
                child: Text(s['label']!, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? _blue : Colors.white38, letterSpacing: 0.8)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(LeaderboardUser u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Row(children: [
        SizedBox(
          width: 36,
          child: Text('#${u.rank}', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w800, color: u.rank <= 3 ? _gold : _green, letterSpacing: 1)),
        ),
        _buildAvatar(u),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u.name, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFC9D1D9)), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (u.countryId.isNotEmpty) Text(u.countryId.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _blue.withAlpha(180))),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: _green.withAlpha(25), borderRadius: BorderRadius.circular(6), border: Border.all(color: _green.withAlpha(60))),
          child: Text('${u.xp} XP', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: _green)),
        ),
      ]),
    );
  }

  Widget _buildMyRow(MyRank mr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1E3A5F), borderRadius: BorderRadius.circular(10), border: Border.all(color: _blue.withAlpha(100))),
      child: Row(children: [
        SizedBox(
          width: 36,
          child: Text(mr.rank > 0 ? '#${mr.rank}' : '---', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w800, color: _blue)),
        ),
        const SizedBox(width: 36 + 12),
        const Expanded(child: Text('YOU', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _blue))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: _blue.withAlpha(25), borderRadius: BorderRadius.circular(6), border: Border.all(color: _blue.withAlpha(60))),
          child: Text('${mr.xp} XP', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: _blue)),
        ),
      ]),
    );
  }

  Widget _buildAvatar(LeaderboardUser u) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _border, border: Border.all(color: _green.withAlpha(80), width: 1.5)),
      child: Center(
        child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: _green.withAlpha(200))),
      ),
    );
  }
}
