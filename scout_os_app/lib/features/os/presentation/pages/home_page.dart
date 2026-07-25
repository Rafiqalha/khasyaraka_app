import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'package:scout_os_app/features/runtime/presentation/shell/workspace_shell.dart';

import '../../data/models/home_data_model.dart';
import '../providers/os_provider.dart';
import '../shell/pradigi_os_scaffold.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final greeting = "${_getGreeting()}, Learner";

    return Scaffold(
      backgroundColor: PradigiColors.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    greeting,
                    style: PradigiTypography.h1.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: PradigiColors.border, thickness: 1),
                  const SizedBox(height: 24),

                  homeDataAsync.when(
                    data: (homeData) {
                      final runtime = homeData.activeRuntime;
                      if (homeData.requiresInitialization || runtime == null) {
                        return _buildEmptyState(context, ref);
                      }
                      return _buildActiveRuntimeCommandCenter(context, ref, runtime, homeData.activeJourney, homeData.directorInsight);
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: PradigiColors.textPrimary)),
                    ),
                    error: (err, stack) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text("System Offline: $err", style: const TextStyle(color: PradigiColors.danger)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "NO ACTIVE RUNTIME",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "You are not currently enrolled in an active learning session.",
          style: PradigiTypography.bodySecondary,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: PradigiColors.textPrimary,
            side: const BorderSide(color: PradigiColors.textPrimary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            ref.read(activeSidebarItemProvider.notifier).select(SidebarItem.explore);
          },
          icon: const Icon(Icons.explore_outlined, size: 18),
          label: const Text("Explore Academy Catalog", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildActiveRuntimeCommandCenter(
    BuildContext context, 
    WidgetRef ref, 
    ActiveRuntimeModel runtime,
    ActiveJourneyModel? journey,
    DirectorInsight? fallbackInsight,
  ) {
    final specialization = journey?.specialization.isNotEmpty == true ? journey!.specialization : runtime.title;
    final objective = runtime.currentObjective.isNotEmpty 
        ? runtime.currentObjective 
        : (journey?.currentMission ?? "Continue Active Mission");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Runtime Status & Specialization
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CURRENT JOURNEY",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialization,
                  style: PradigiTypography.h2.copyWith(fontSize: 22),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: PradigiColors.successLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: PradigiColors.success.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: PradigiColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    runtime.status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PradigiColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Divider(color: PradigiColors.border),
        const SizedBox(height: 24),

        // Mission & Objective
        Text(
          "CURRENT OBJECTIVE",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          objective,
          style: PradigiTypography.h1.copyWith(fontSize: 26),
        ),

        const SizedBox(height: 16),

        // Planner Metrics (Estimated Duration & Difficulty computed on-the-fly)
        Row(
          children: [
            if (runtime.estimatedDuration.isNotEmpty) ...[
              const Icon(Icons.schedule, size: 16, color: PradigiColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                "Estimated: ${runtime.estimatedDuration}",
                style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 24),
            ],
            if (runtime.userDifficulty.isNotEmpty) ...[
              const Icon(Icons.bar_chart, size: 16, color: PradigiColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                "Difficulty: ${runtime.userDifficulty}",
                style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),

        const SizedBox(height: 32),

        // Primary Action
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PradigiColors.textPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkspaceShell()),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Open Active Runtime",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),

        const SizedBox(height: 36),
        const Divider(color: PradigiColors.border),
        const SizedBox(height: 28),

        // Director Brief (Actionable Briefing)
        if (runtime.directorBrief != null) ...[
          _buildDirectorBrief(runtime.directorBrief!),
        ] else if (fallbackInsight != null) ...[
          _buildLegacyInsightBrief(fallbackInsight),
        ],
      ],
    );
  }

  Widget _buildDirectorBrief(DirectorBrief brief) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.terminal, size: 18, color: PradigiColors.primary),
            SizedBox(width: 8),
            Text(
              "DIRECTOR BRIEF",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: PradigiColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PradigiColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PradigiColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (brief.yesterday.isNotEmpty) ...[
                _buildBriefItem("Yesterday", brief.yesterday, isDone: true),
                const SizedBox(height: 12),
              ],
              if (brief.today.isNotEmpty) ...[
                _buildBriefItem("Today", brief.today, isBold: true),
                const SizedBox(height: 12),
              ],
              if (brief.risk.isNotEmpty) ...[
                _buildBriefItem("Risk", brief.risk, isWarning: true),
                const SizedBox(height: 12),
              ],
              if (brief.focus.isNotEmpty) ...[
                _buildBriefItem("Focus", brief.focus),
                const SizedBox(height: 12),
              ],
              if (brief.expectedOutcome.isNotEmpty) ...[
                _buildBriefItem("Outcome", brief.expectedOutcome),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBriefItem(String label, String value, {bool isDone = false, bool isBold = false, bool isWarning = false}) {
    Color labelColor = PradigiColors.textSecondary;
    Color valueColor = PradigiColors.textPrimary;
    
    if (isDone) valueColor = PradigiColors.success;
    if (isWarning) valueColor = PradigiColors.warning;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegacyInsightBrief(DirectorInsight insight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DIRECTOR BRIEF",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: PradigiColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PradigiColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PradigiColors.border),
          ),
          child: Text(
            insight.observation.isNotEmpty ? insight.observation : "Ready for mission execution.",
            style: PradigiTypography.body,
          ),
        ),
      ],
    );
  }
}
