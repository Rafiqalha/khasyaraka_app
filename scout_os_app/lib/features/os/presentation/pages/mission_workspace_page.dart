import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import '../providers/os_provider.dart';
import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/runtime/presentation/shell/workspace_shell.dart';
import 'package:scout_os_app/core/config/environment.dart';

class MissionWorkspacePage extends ConsumerStatefulWidget {
  const MissionWorkspacePage({super.key});

  @override
  ConsumerState<MissionWorkspacePage> createState() => _MissionWorkspacePageState();
}

class _MissionWorkspacePageState extends ConsumerState<MissionWorkspacePage> {
  @override
  Widget build(BuildContext context) {
    ref.listen(homeSseProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        ref.invalidate(homeDataProvider);
      }
    });

    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: homeDataAsync.when(
          data: (data) {
            return CustomScrollView(
              slivers: [
                _buildHeader(),
                _buildMissionSection(data.goalTitle ?? "Unknown Mission", data.directorInsight?.strategy ?? "Calculating..."),
                if (data.isCalculating)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text("Director is analyzing your learning profile...", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                if (data.directorInsight != null) _buildInsightSection(data.directorInsight!),
                _buildKnowledgeGraph(data.masteredCompetencies ?? 0, data.remainingCompetencies ?? 0, data.currentUnderstanding ?? [], data.missingCompetencies ?? []),
                _buildTodayObjective(context, ref, data.currentNode ?? "Waiting"),
                const SliverToBoxAdapter(child: SizedBox(height: 64)),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.black),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'System Offline: $error',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Afternoon.',
              style: PradigiTypography.h2.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI Director',
              style: PradigiTypography.h1,
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.black, thickness: 1),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMissionSection(String mission, String trajectory) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mission', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text(mission, style: PradigiTypography.h2),
            const SizedBox(height: 24),
            const Text('Current Trajectory', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text(trajectory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Divider(color: Colors.black, thickness: 1),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildInsightSection(dynamic insight) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Observation', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology, size: 32, color: Colors.black),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      insight.observation,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            if (insight.reflection.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Reflection', style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 8),
              Text(insight.reflection, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            ],
            if (insight.motivation.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Motivation', style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 8),
              Text(insight.motivation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: 24),
            const Divider(color: Colors.black, thickness: 1),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildKnowledgeGraph(int mastered, int remaining, List<String> understanding, List<String> missing) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current State', style: PradigiTypography.h2),
            const SizedBox(height: 8),
            Text('$mastered competencies mastered', style: const TextStyle(fontSize: 16)),
            Text('$remaining competencies remaining', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            const Text("I've analyzed your progress.\nYou already understand:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ...understanding.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(item, style: const TextStyle(fontSize: 18)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Text("But you're still missing:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ...missing.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(item, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Divider(color: Colors.black, thickness: 1),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTodayObjective(BuildContext context, WidgetRef ref, String objective) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Objective", style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text(objective, style: PradigiTypography.h2),
            const SizedBox(height: 24),
            InkWell(
              onTap: () async {
                try {
                  final dio = ApiDioProvider.getDio();
                  final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
                  final url = '$host/api/v2/runtime/start';
                  print('🚀🚀🚀 Calling URL: $url 🚀🚀🚀');
                  // Request to start the session, then navigate
                  await dio.post(url, data: {
                    'learning_goal_id': 'goal_ai_engineer',
                    'pack_id': 'pack_ai',
                    'pack_version': 'v1'
                  });
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkspaceShell(),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to launch workspace: $e')),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
