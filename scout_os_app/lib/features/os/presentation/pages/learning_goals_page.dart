import 'package:flutter/material.dart';
import 'package:scout_os_app/design_system/theme/app_theme.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import '../../data/models/academy_tree_model.dart';
import '../../../learning/presentation/pages/mission_page.dart';
import '../../../../core/telemetry/telemetry.dart';
import '../../../../shared/theme/app_theme.dart';

class LearningGoalsPage extends StatelessWidget {
  final SpecializationModel specialization;

  const LearningGoalsPage({super.key, required this.specialization});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(specialization.title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Learning Goals",
              style: TextStyle(
                color: PradigiColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              specialization.description,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ...specialization.learningGoals.map((goal) => _buildGoalCard(context, goal)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, LearningGoalModel goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: PradigiColors.editorBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Telemetry.track(
              event: CognitiveEvent.activityStarted,
              payload: {
                'goalTitle': goal.title,
                'goalType': goal.goalType,
              },
            );

            // Demo Route: Immediately launch the Mission Page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MissionPage(nodeId: "demo_mission_1"),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: PradigiColors.primary.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              goal.goalType ?? "SKILL",
                              style: const TextStyle(
                                color: PradigiColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (goal.latestPackId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: PradigiColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "PACK READY",
                                style: TextStyle(
                                  color: PradigiColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        goal.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (goal.learningObjective != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          goal.learningObjective!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PradigiColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
