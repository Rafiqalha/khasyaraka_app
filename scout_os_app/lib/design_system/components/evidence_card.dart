import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import '../tokens/radius.dart';

class EvidenceCard extends StatelessWidget {
  final List<String> observations;
  final Map<String, String> impacts;

  const EvidenceCard({
    super.key,
    required this.observations,
    required this.impacts,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Evidence Card showing ${observations.length} observations",
      child: Container(
      key: const ValueKey("evidence_card"),
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(PradigiSpacing.s32),
      decoration: BoxDecoration(
        color: PradigiColors.surface,
        borderRadius: BorderRadius.circular(PradigiRadius.r16),
        border: Border.all(color: PradigiColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Evidence Generated", style: PradigiTypography.h2),
          const SizedBox(height: PradigiSpacing.s24),
          
          ...observations.map((obs) => Padding(
            padding: const EdgeInsets.only(bottom: PradigiSpacing.s12),
            child: Row(
              children: [
                const Icon(Icons.check, size: 20, color: PradigiColors.success),
                const SizedBox(width: PradigiSpacing.s16),
                Expanded(child: Text(obs, style: PradigiTypography.body)),
              ],
            ),
          )),
          
          const SizedBox(height: PradigiSpacing.s16),
          const Divider(color: PradigiColors.border),
          const SizedBox(height: PradigiSpacing.s16),
          
          Text("Impact", style: PradigiTypography.caption),
          const SizedBox(height: PradigiSpacing.s12),
          
          ...impacts.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: PradigiSpacing.s8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: PradigiTypography.bodySecondary),
                Text(entry.value, style: PradigiTypography.body.copyWith(
                  color: PradigiColors.success,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
          )),
        ],
      ),
    ));
  }
}
