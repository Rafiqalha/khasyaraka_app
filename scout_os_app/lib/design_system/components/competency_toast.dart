import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import '../tokens/radius.dart';

class CompetencyToast extends StatelessWidget {
  final String title;
  final String delta;

  const CompetencyToast({
    super.key,
    required this.title,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Competency updated: $title increased by $delta",
      child: Container(
      key: const ValueKey("competency_toast"),
      padding: const EdgeInsets.symmetric(horizontal: PradigiSpacing.s24, vertical: PradigiSpacing.s16),
      decoration: BoxDecoration(
        color: PradigiColors.textPrimary,
        borderRadius: BorderRadius.circular(PradigiRadius.rFull),
        boxShadow: [
          BoxShadow(
            color: PradigiColors.textPrimary.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: PradigiTypography.body.copyWith(color: PradigiColors.surface)),
          const SizedBox(width: PradigiSpacing.s24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(10, (index) {
              final isActive = index < 8; // hardcoded for display
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isActive ? PradigiColors.success : PradigiColors.textSecondary.withValues(alpha: 0.3),
                  shape: BoxShape.rectangle,
                ),
              );
            }),
          ),
          const SizedBox(width: PradigiSpacing.s24),
          Text(delta, style: PradigiTypography.body.copyWith(
            color: PradigiColors.success,
            fontWeight: FontWeight.bold,
          )),
        ],
      ),
    ));
  }
}
