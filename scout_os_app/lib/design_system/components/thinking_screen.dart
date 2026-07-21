import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import '../tokens/radius.dart';

enum ThinkingCheckItemStatus { pending, analyzing, completed }

class ThinkingCheckItem {
  final String label;
  final ThinkingCheckItemStatus status;

  const ThinkingCheckItem({
    required this.label,
    this.status = ThinkingCheckItemStatus.pending,
  });
}

/// A signature component for Pradigi: Thinking Screen.
/// 
/// Replaces generic loading spinners. Gives the impression of an analytical machine at work.
class ThinkingScreen extends StatelessWidget {
  final String title;
  final List<ThinkingCheckItem> checkItems;
  final String statusMessage;

  const ThinkingScreen({
    super.key,
    this.title = "Analyzing your solution...",
    required this.checkItems,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(PradigiSpacing.s32),
        decoration: BoxDecoration(
          color: PradigiColors.surface,
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          boxShadow: [
            BoxShadow(
              color: PradigiColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
          border: Border.all(color: PradigiColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: PradigiTypography.h2),
            const SizedBox(height: PradigiSpacing.s24),
            
            // Checklist Items
            ...checkItems.map((item) => _buildCheckItem(item)),
            
            const SizedBox(height: PradigiSpacing.s24),
            const Divider(),
            const SizedBox(height: PradigiSpacing.s16),
            
            // Status Message (e.g. "Updating competency...")
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: PradigiColors.primary),
                ),
                const SizedBox(width: PradigiSpacing.s16),
                Text(statusMessage, style: PradigiTypography.caption.copyWith(color: PradigiColors.primary)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(ThinkingCheckItem item) {
    Widget icon;
    Color textColor;
    
    switch (item.status) {
      case ThinkingCheckItemStatus.completed:
        icon = const Icon(Icons.check, size: 20, color: PradigiColors.success);
        textColor = PradigiColors.textPrimary;
        break;
      case ThinkingCheckItemStatus.analyzing:
        icon = const SizedBox(
          width: 20, 
          height: 20, 
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: CircularProgressIndicator(strokeWidth: 2, color: PradigiColors.textSecondary),
          )
        );
        textColor = PradigiColors.textPrimary;
        break;
      case ThinkingCheckItemStatus.pending:
      default:
        icon = const Icon(Icons.circle_outlined, size: 20, color: PradigiColors.border);
        textColor = PradigiColors.textSecondary;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: PradigiSpacing.s16),
      child: Row(
        children: [
          icon,
          const SizedBox(width: PradigiSpacing.s16),
          Text(item.label, style: PradigiTypography.body.copyWith(color: textColor)),
        ],
      ),
    );
  }
}
