import 'package:flutter/material.dart';
import '../../../../design_system/components/journey_card.dart';
import '../../../../design_system/tokens/spacing.dart';

class JourneyMapPage extends StatelessWidget {
  const JourneyMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PradigiSpacing.contentMaxWidth),
        child: JourneyCard(
          title: "Arrays",
          estimatedTime: "45 mins total",
          nodes: const [
            JourneyNodeItem(title: "Notebook", status: JourneyNodeStatus.active),
            JourneyNodeItem(title: "Quick Check", status: JourneyNodeStatus.locked),
            JourneyNodeItem(title: "Mission", status: JourneyNodeStatus.locked),
          ],
        ),
      ),
    );
  }
}
