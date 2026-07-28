import 'package:flutter/material.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/config/environment.dart';
import '../panels/editor_panel.dart';
import '../panels/console_panel.dart';
import '../panels/analysis_panel.dart';
import '../providers/runtime_provider.dart';
import '../controllers/workspace_controller.dart';
import '../../../os/data/models/home_data_model.dart';

class WorkspaceShell extends ConsumerWidget {
  const WorkspaceShell({super.key});

  void _advanceToNextMission(BuildContext context, WidgetRef ref, String currentId) async {
    const missionOrder = [
      'mission_network_recon',
      'mission_log_analysis',
      'mission_vuln_scanning',
      'mission_incident_response',
      'mission_cryptography_basics',
    ];
    int currentIndex = missionOrder.indexOf(currentId);
    int nextIndex = currentIndex >= 0 ? (currentIndex + 1) % missionOrder.length : 0;
    String nextId = missionOrder[nextIndex];

    try {
      final dio = ApiDioProvider.getDio();
      final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
      await dio.post('$host/api/v2/os/mission/start', data: {
        'academy_id': 'cyber_academy',
        'pack_id': 'cyber_fundamentals',
        'mission_id': nextId,
      });
      ref.read(workspaceProvider.notifier).reset();
      ref.invalidate(currentSessionProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Misi dialihkan ke: ${nextId.replaceAll('mission_', '').replaceAll('_', ' ').toUpperCase()}"),
            backgroundColor: PradigiColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengalihkan misi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentSessionProvider);

    return sessionAsync.when(
      data: (data) {
        final node = data.node;
        final session = data.session;
        if (node == null || session == null) {
          return const Scaffold(body: Center(child: Text('No active activity found.')));
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // Pradigi Clean Slate 50
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: const Color(0xFFE2E8F0), height: 1), // Slate 200 border
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              "Cyber Security Sandbox",
              style: PradigiTypography.h3.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton(
                  onPressed: () => _advanceToNextMission(context, ref, node.id),
                  child: Text(
                    "Selesai & Lanjut ➜",
                    style: PradigiTypography.caption.copyWith(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;

              // Top Half: Adaptive Soal / Objective with Clean Pradigi Style
              final objectivePanel = _buildObjectivePanel(context, ref, node);

              if (isDesktop) {
                return Column(
                  children: [
                    Expanded(flex: 5, child: objectivePanel),
                    Container(height: 1, color: const Color(0xFFE2E8F0)),
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: WorkspaceEditorPanel(
                              initialCode: node.initialCode,
                              language: node.language,
                              sessionId: session.id,
                              nodeId: node.id,
                            ),
                          ),
                          Container(width: 1, color: const Color(0xFF334155)),
                          const Expanded(
                            flex: 5,
                            child: WorkspaceConsolePanel(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile Portrait: Top half Soal, Bottom half Tabbed Editor / Terminal
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // Setengah Layar Atas: Soal Adaptif LLM Orchestrator
                      Expanded(
                        flex: 5,
                        child: objectivePanel,
                      ),
                      Container(height: 1, color: const Color(0xFFE2E8F0)),
                      // TabBar untuk Layar Bawah (Clean Minimalist Slate)
                      Container(
                        color: const Color(0xFF0F172A), // Slate 950
                        child: TabBar(
                          indicatorColor: const Color(0xFF3B82F6), // Blue 500
                          labelColor: const Color(0xFF3B82F6),
                          unselectedLabelColor: const Color(0xFF64748B),
                          labelStyle: PradigiTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                          tabs: [
                            Tab(text: "Kode (${node.language.toUpperCase()})"),
                            const Tab(text: "Terminal"),
                          ],
                        ),
                      ),
                      // Setengah Layar Bawah: Terminal / Code Editor
                      Expanded(
                        flex: 5,
                        child: TabBarView(
                          children: [
                            WorkspaceEditorPanel(
                              initialCode: node.initialCode,
                              language: node.language,
                              sessionId: session.id,
                              nodeId: node.id,
                            ),
                            const WorkspaceConsolePanel(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      ),
      error: (e, st) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildObjectivePanel(BuildContext context, WidgetRef ref, PackNode node) {
    final workspaceState = ref.watch(workspaceProvider);

    return Container(
      width: double.infinity,
      color: Colors.white, // Pradigi Clean White Surface
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with minimalist monochrome badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // Slate 100
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
                ),
                child: Text(
                  "TANTANGAN KOMPETENSI",
                  style: PradigiTypography.caption.copyWith(
                    color: const Color(0xFF475569), // Slate 600
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Blue 50
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBFDBFE)), // Blue 200
                ),
                child: Text(
                  node.language.toUpperCase(),
                  style: PradigiTypography.caption.copyWith(
                    color: const Color(0xFF2563EB), // Blue 600
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mission Title
          Text(
            node.title,
            style: PradigiTypography.h2.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Scrollable Mission Instruction / Soal Adaptif
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCleanMarkdown(node.description),
                  const SizedBox(height: 20),
                  // Celebration Banner when Passed
                  if (workspaceState.isPassed == true)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4), // Green 50
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 24),
                              const SizedBox(width: 10),
                              Text(
                                "Misi Berhasil Diselesaikan!",
                                style: PradigiTypography.h3.copyWith(color: const Color(0xFF16A34A), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Kompetensi kamu pada topik ini telah diverifikasi. Kamu siap melanjutkan ke tantangan berikutnya.",
                            style: PradigiTypography.body.copyWith(color: const Color(0xFF15803D)),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => _advanceToNextMission(context, ref, node.id),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: const Text("Lanjut ke Misi Berikutnya ➜", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // AI Analysis Panel (when evaluated)
                  const WorkspaceAnalysisPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanMarkdown(String text) {
    final lines = text.split('\n');
    List<Widget> widgets = [];
    bool inCodeBlock = false;
    List<String> codeBuffer = [];

    for (String line in lines) {
      if (line.trim().startsWith('```')) {
        if (inCodeBlock) {
          widgets.add(Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A), // Slate 900
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Text(
              codeBuffer.join('\n'),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFFE2E8F0),
                height: 1.4,
              ),
            ),
          ));
          codeBuffer.clear();
          inCodeBlock = false;
        } else {
          inCodeBlock = true;
        }
        continue;
      }

      if (inCodeBlock) {
        codeBuffer.add(line);
        continue;
      }

      if (line.trim().startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text(
            line.trim().substring(4),
            style: PradigiTypography.h3.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ));
      } else if (line.trim().startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            line.trim().substring(3),
            style: PradigiTypography.h2.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ));
      } else if (line.trim().isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            line,
            style: PradigiTypography.body.copyWith(color: const Color(0xFF334155), height: 1.5, fontSize: 14),
          ),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
