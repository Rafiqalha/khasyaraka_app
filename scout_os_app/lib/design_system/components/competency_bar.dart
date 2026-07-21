import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import '../tokens/radius.dart';

/// A signature component for Pradigi: Competency Bar.
/// 
/// Shows the progression of a specific competency clearly with a block-based progress view.
class CompetencyBar extends StatelessWidget {
  final String title;
  final double oldPercentage; // 0.0 to 1.0
  final double newPercentage; // 0.0 to 1.0
  final bool animateDelta;
  final String? subtitle;

  const CompetencyBar({
    super.key,
    required this.title,
    required this.oldPercentage,
    required this.newPercentage,
    this.animateDelta = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final diff = newPercentage - oldPercentage;
    final diffStr = diff > 0 ? "+${(diff * 100).toInt()}%" : "${(diff * 100).toInt()}%";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600)),
            Text(
              "${(newPercentage * 100).toInt()}%", 
              style: PradigiTypography.body.copyWith(fontWeight: FontWeight.bold)
            ),
          ],
        ),
        
        if (subtitle != null) ...[
          const SizedBox(height: PradigiSpacing.s4),
          Text(subtitle!, style: PradigiTypography.caption),
        ],
        
        const SizedBox(height: PradigiSpacing.s8),
        
        // Progress Bar Line (8-10px thick, solid color)
        SizedBox(
          height: 10,
          child: Stack(
            children: [
              // Background track
              Container(
                decoration: BoxDecoration(
                  color: PradigiColors.border,
                  borderRadius: BorderRadius.circular(PradigiRadius.rFull),
                ),
              ),
              // Fill track
              FractionallySizedBox(
                widthFactor: newPercentage.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: PradigiColors.primary,
                    borderRadius: BorderRadius.circular(PradigiRadius.rFull),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Delta Indicator
        if (diff > 0 && animateDelta) ...[
          const SizedBox(height: PradigiSpacing.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.arrow_upward, size: 14, color: PradigiColors.success),
              const SizedBox(width: 4),
              Text(
                diffStr,
                style: PradigiTypography.caption.copyWith(
                  color: PradigiColors.success, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }
}
