import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';


enum JourneyNodeStatus { locked, active, completed }

class JourneyNodeItem {
  final String title;
  final JourneyNodeStatus status;

  const JourneyNodeItem({
    required this.title,
    required this.status,
  });
}

/// A signature component for Pradigi: Journey Card.
/// 
/// Shows the overall topic, estimated time, and a list of nodes (Fog of war).
class JourneyCard extends StatelessWidget {
  final String title;
  final String estimatedTime;
  final List<JourneyNodeItem> nodes;
  final VoidCallback? onContinue;
  final String continueText;
  final bool isContinueEnabled;

  const JourneyCard({
    super.key,
    required this.title,
    required this.estimatedTime,
    required this.nodes,
    this.onContinue,
    this.continueText = "Continue →",
    this.isContinueEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PradigiSpacing.s32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(title, style: PradigiTypography.h2),
            const SizedBox(height: PradigiSpacing.s8),
            Text(
              estimatedTime,
              style: PradigiTypography.bodySecondary,
            ),
            
            const SizedBox(height: PradigiSpacing.s24),
            const Divider(),
            const SizedBox(height: PradigiSpacing.s24),
            
            // Nodes
            ...nodes.map((node) => _buildNodeRow(node)),
            
            const SizedBox(height: PradigiSpacing.s32),
            const Divider(),
            const SizedBox(height: PradigiSpacing.s24),
            
            // Primary Action (Optional, usually handled by shell)
            if (onContinue != null)
              FilledButton(
                onPressed: isContinueEnabled ? onContinue : null,
                child: Text(continueText),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeRow(JourneyNodeItem node) {
    Color indicatorColor;
    IconData? iconData;
    
    switch (node.status) {
      case JourneyNodeStatus.completed:
        indicatorColor = PradigiColors.textPrimary;
        iconData = Icons.circle;
        break;
      case JourneyNodeStatus.active:
        indicatorColor = PradigiColors.primary;
        iconData = Icons.circle;
        break;
      case JourneyNodeStatus.locked:
        indicatorColor = PradigiColors.textSecondary;
        iconData = Icons.circle_outlined;
        break;
    }

    final isMystery = node.status == JourneyNodeStatus.locked;
    final textStyle = node.status == JourneyNodeStatus.active 
        ? PradigiTypography.body.copyWith(fontWeight: FontWeight.w600, color: PradigiColors.primary)
        : (isMystery ? PradigiTypography.bodySecondary : PradigiTypography.body);

    return Padding(
      padding: const EdgeInsets.only(bottom: PradigiSpacing.s16),
      child: Row(
        children: [
          Icon(iconData, size: 16, color: indicatorColor),
          const SizedBox(width: PradigiSpacing.s16),
          Text(isMystery ? '???' : node.title, style: textStyle),
        ],
      ),
    );
  }
}
