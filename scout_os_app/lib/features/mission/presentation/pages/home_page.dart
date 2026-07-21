import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/logic/mission_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<MissionController>().missionId == null) {
        context.read<MissionController>().generateMission('beginner');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<MissionController>(builder: (context, ctrl, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _greeting(),
              const SizedBox(height: 28),
              _aiStatus(ctrl),
              const SizedBox(height: 20),
              _missionCard(ctrl),
              const SizedBox(height: 24),
              _continueSection(),
            ]),
          );
        }),
      ),
    );
  }

  Widget _greeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(greeting, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
      const SizedBox(height: 4),
      Text('Your AI-powered cyber training is ready.', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF6B7280))),
    ]);
  }

  Widget _aiStatus(MissionController ctrl) {
    final active = ctrl.missionId != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB)), boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 16)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF2563EB).withAlpha(15), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF2563EB).withAlpha(30))), child: Text('AI GENERATED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)))),
          const Spacer(),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(active ? 'ONLINE' : 'STANDBY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: active ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF))),
        ]),
        const SizedBox(height: 16),
        Text(active ? 'Adaptive Mission Engine' : 'Initializing adaptive engine...', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
        const SizedBox(height: 6),
        Text(active ? '${ctrl.serverHealth}% server health · ${ctrl.activeThreats.length} active threats · Phase: ${ctrl.phase}' : 'Preparing your personalized mission.', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
        if (active) ...[
          const SizedBox(height: 12),
          Row(children: [
            _aiLabel('Confidence', '${((ctrl.blockedIPs.length) * 25 + (ctrl.score / 2).floor()).clamp(5, 95)}%'),
            const SizedBox(width: 16),
            _aiLabel('Threats', '${ctrl.activeThreats.length}'),
            const SizedBox(width: 16),
            _aiLabel('Health', '${ctrl.serverHealth}%'),
          ]),
        ],
      ]),
    );
  }

  Widget _aiLabel(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF9CA3AF))),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
    ]);
  }

  Widget _missionCard(MissionController ctrl) {
    return InkWell(
      onTap: () {
        final scaffold = context.findAncestorStateOfType<State>();
        if (scaffold != null && scaffold.mounted) {
          final tabController = DefaultTabController.of(context);
          // Navigate to Mission tab (index 1)
          final parent = context.findAncestorWidgetOfExactType<Scaffold>();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x1A2563EB), offset: Offset(0, 8), blurRadius: 24)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text('Start Mission', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const Spacer(),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
          ]),
          const SizedBox(height: 8),
          Text('Investigate server anomalies in the SOC workspace. Identify threats, contain attacks, and protect critical infrastructure.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withAlpha(200), height: 1.4)),
          const SizedBox(height: 16),
          Row(children: [
            _metric('Time', '${ctrl.timeRemaining ~/ 60}m', Colors.white),
            const SizedBox(width: 16),
            _metric('Score', '${ctrl.score}', Colors.white),
            const SizedBox(width: 16),
            _metric('Status', ctrl.missionId != null ? 'Active' : 'Ready', Colors.white),
          ]),
        ]),
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: color.withAlpha(180))),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  Widget _continueSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB)), boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 16)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Continue Learning', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
        const SizedBox(height: 16),
        _continueItem(Icons.straighten_rounded, 'Network Investigation', 'Packet analysis fundamentals'),
        const SizedBox(height: 10),
        _continueItem(Icons.bug_report_rounded, 'Threat Hunting', 'Log pattern recognition'),
        const SizedBox(height: 10),
        _continueItem(Icons.terminal_rounded, 'Linux Commands', 'Shell navigation basics'),
      ]),
    );
  }

  Widget _continueItem(IconData icon, String title, String subtitle) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 22),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
          ]),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
        ]),
      ),
    );
  }
}
