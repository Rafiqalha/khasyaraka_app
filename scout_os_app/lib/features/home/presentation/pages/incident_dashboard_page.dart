import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/home/data/models/incident.dart';
import 'package:scout_os_app/features/home/presentation/widgets/incident_card.dart';
import 'package:scout_os_app/features/home/presentation/pages/quiz_page.dart';
import 'package:scout_os_app/features/mission/presentation/pages/log_analyzer_page.dart';

class IncidentDashboardPage extends StatefulWidget {
  const IncidentDashboardPage({super.key});

  @override
  State<IncidentDashboardPage> createState() => _IncidentDashboardPageState();
}

class _IncidentDashboardPageState extends State<IncidentDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingController>().loadIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.terminal, color: Color(0xFF58A6FF), size: 22),
            const SizedBox(width: 8),
            Text(
              'COMMAND CENTER',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF58A6FF),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.terminal, color: Color(0xFF3FB950), size: 20),
            tooltip: 'Log Analyzer Mission',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LogAnalyzerPage())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white38, size: 20),
            onPressed: () => context.read<TrainingController>().loadIncidents(),
          ),
        ],
      ),
      body: Consumer<TrainingController>(
        builder: (context, ctrl, _) {
          if (ctrl.isIncidentsLoading && ctrl.incidents.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF58A6FF))),
                  const SizedBox(height: 16),
                  Text('Fetching threat intelligence...', style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 13)),
                ],
              ),
            );
          }

          if (ctrl.incidentsError != null && ctrl.incidents.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 40, color: Colors.white24),
                  const SizedBox(height: 12),
                  const Text('Unable to fetch incidents', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(ctrl.incidentsError!, style: GoogleFonts.plusJakartaSans(color: Colors.white24, fontSize: 11)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ctrl.loadIncidents(),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
                    child: Text('Retry', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }

          if (ctrl.incidents.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.radar, size: 48, color: Colors.white12),
                  const SizedBox(height: 16),
                  const Text('No active incidents', style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('AI Scraper will populate threats\nevery 6 hours from live feeds.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ctrl.loadIncidents(),
            color: const Color(0xFF58A6FF),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.incidents.length,
              itemBuilder: (_, i) => IncidentCard(
                incident: ctrl.incidents[i],
                onEngage: () => _engageIncident(context, ctrl.incidents[i]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _engageIncident(BuildContext context, IncidentModel incident) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizPage.withLevel(levelId: incident.levelId),
      ),
    );
  }
}
