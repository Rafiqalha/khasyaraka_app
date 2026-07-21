import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/logic/mission_controller.dart';
import 'package:scout_os_app/features/mission/presentation/widgets/alert_overlay.dart';

class LogAnalyzerPage extends StatefulWidget {
  const LogAnalyzerPage({super.key});

  @override
  State<LogAnalyzerPage> createState() => _LogAnalyzerPageState();
}

class _LogAnalyzerPageState extends State<LogAnalyzerPage> {
  final _searchCtrl = TextEditingController();
  String _selectedPersona = 'beginner';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionController>().generateMission(_selectedPersona);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: _buildAppBar(),
      body: Consumer<MissionController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3FB950)));
          }
          if (ctrl.error != null && ctrl.missionId == null) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off, color: Colors.white24, size: 48),
              const SizedBox(height: 12),
              Text(ctrl.error!, style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => ctrl.generateMission(_selectedPersona), child: const Text('Retry')),
            ]));
          }
          return Stack(children: [
            Column(children: [
              _buildToolbar(ctrl),
              _buildSearchBar(ctrl),
              Expanded(child: _buildLogList(ctrl)),
            ]),
            AlertOverlay(events: ctrl.events, timeRemaining: ctrl.timeRemaining, score: ctrl.score),
          ]);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D1117),
      elevation: 0,
      title: Text('LOG ANALYZER', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF3FB950), fontSize: 16, fontWeight: FontWeight.w800)),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.person, color: Color(0xFF8B949E)),
          onSelected: (v) {
            setState(() => _selectedPersona = v);
            context.read<MissionController>().generateMission(v);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'beginner', child: Text('Rookie Attacker')),
            const PopupMenuItem(value: 'scriptkiddie', child: Text('Script Kiddie')),
            const PopupMenuItem(value: 'apt', child: Text('APT Group')),
          ],
        ),
      ],
    );
  }

  Widget _buildToolbar(MissionController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: const Color(0xFF161B22),
      child: Row(children: [
        _toolBtn(Icons.filter_list, 'Filter', () => ctrl.sendAction('search_logs', {'query': _searchCtrl.text})),
        const SizedBox(width: 8),
        _toolBtn(Icons.sort_by_alpha, 'Sort', () {}),
        const SizedBox(width: 8),
        _toolBtn(Icons.timeline, 'Timeline', () {}),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF30363D))),
          child: Text('${ctrl.timeRemaining}s', style: GoogleFonts.jetBrainsMono(color: ctrl.timeRemaining < 60 ? const Color(0xFFF85149) : const Color(0xFF3FB950), fontSize: 14, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 8),
        _toolBtn(Icons.block, 'Block IP', () => _showBlockIPDialog(ctrl)),
        const SizedBox(width: 8),
        _toolBtn(Icons.shield, 'Firewall', () => _showFirewallDialog(ctrl)),
      ]),
    );
  }

  Widget _toolBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF30363D))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: const Color(0xFF8B949E), size: 16),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF8B949E), fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildSearchBar(MissionController ctrl) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF30363D))),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => ctrl.setSearchQuery(v),
        style: GoogleFonts.jetBrainsMono(color: const Color(0xFFC9D1D9), fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search logs... (IP, status, service)',
          hintStyle: TextStyle(color: const Color(0xFF484F58), fontSize: 13),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Color(0xFF484F58), size: 18),
          suffix: ctrl.searchQuery.isNotEmpty
              ? InkWell(onTap: () { _searchCtrl.clear(); ctrl.setSearchQuery(''); }, child: const Icon(Icons.close, color: Color(0xFF484F58), size: 16))
              : null,
        ),
      ),
    );
  }

  Widget _buildLogList(MissionController ctrl) {
    final logs = ctrl.filteredLogs;
    if (logs.isEmpty) return const Center(child: Text('No logs match', style: TextStyle(color: Color(0xFF484F58))));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: logs.length,
      itemBuilder: (_, i) {
        final l = logs[i];
        final anomaly = l['is_anomaly'] == true;
        return InkWell(
          onTap: () => ctrl.sendAction('inspect_log', {'id': l['id']}),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(color: anomaly ? const Color(0xFF3FB950).withAlpha(10) : const Color(0xFF161B22), borderRadius: BorderRadius.circular(4)),
            child: Row(children: [
              SizedBox(width: 38, child: Text('${l['id']}', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF484F58), fontSize: 10))),
              SizedBox(width: 52, child: Text(l['timestamp'] ?? '', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF8B949E), fontSize: 11))),
              SizedBox(width: 60, child: Text(l['server'] ?? '', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF58A6FF), fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              SizedBox(width: 90, child: Text(l['source_ip'] ?? '', style: GoogleFonts.jetBrainsMono(color: anomaly ? const Color(0xFFF85149) : const Color(0xFF8B949E), fontSize: 11), overflow: TextOverflow.ellipsis)),
              SizedBox(width: 70, child: Text(l['service'] ?? '', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF8B949E), fontSize: 11), overflow: TextOverflow.ellipsis)),
              Expanded(child: Text(l['message'] ?? '', style: GoogleFonts.plusJakartaSans(color: anomaly ? const Color(0xFFF85149) : const Color(0xFFC9D1D9), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        );
      },
    );
  }

  void _showBlockIPDialog(MissionController ctrl) {
    final tc = TextEditingController(text: '192.168.1.105');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: Text('Block IP', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFC9D1D9))),
      content: TextField(controller: tc, style: GoogleFonts.jetBrainsMono(color: const Color(0xFFC9D1D9)), decoration: const InputDecoration(hintText: 'IP address')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { ctrl.sendAction('block_ip', {'ip': tc.text}); Navigator.pop(ctx); }, child: const Text('Block')),
      ],
    ));
  }

  void _showFirewallDialog(MissionController ctrl) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: Text('Add Firewall Rule', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFC9D1D9))),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(title: const Text('DENY 192.168.1.105', style: TextStyle(color: Color(0xFF3FB950))), onTap: () { ctrl.sendAction('add_firewall_rule', {'action': 'DENY', 'source': '192.168.1.105', 'port': 0}); Navigator.pop(ctx); }),
        ListTile(title: const Text('DENY 45.33.32.156', style: TextStyle(color: Color(0xFFF85149))), onTap: () { ctrl.sendAction('add_firewall_rule', {'action': 'DENY', 'source': '45.33.32.156', 'port': 22}); Navigator.pop(ctx); }),
      ]),
    ));
  }
}
