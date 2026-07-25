import 'dart:ui';
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

/// A signature component for Pradigi: Thinking Overlay.
/// 
/// Replaces generic loading spinners. Gives the impression of an analytical machine at work.
/// Designed to be overlaid on top of the current screen (e.g. Mission Editor)
class ThinkingOverlay extends StatelessWidget {
  final String title;
  final List<ThinkingCheckItem> checkItems;
  final String statusMessage;
  final Widget? evidenceCard;
  final Widget? competencyToast;
  final int progress;

  const ThinkingOverlay({
    super.key,
    this.title = "Analyzing Runtime...",
    required this.checkItems,
    required this.statusMessage,
    this.evidenceCard,
    this.competencyToast,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Determine what to show in the center based on presence of evidence/competency
    Widget centerContent;
    if (competencyToast != null) {
      centerContent = competencyToast!;
    } else if (evidenceCard != null) {
      centerContent = evidenceCard!;
    } else {
      centerContent = _buildChecklist();
    }

    return Stack(
      children: [
        // Background Blur + Opacity
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: PradigiColors.background.withValues(alpha: 0.85),
            ),
          ),
        ),
        
        // Content
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: centerContent,
          ),
        ),
      ],
    );
  }
  
  Widget _buildChecklist() {
    return Container(
      key: const ValueKey("checklist"),
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
          Text(title, style: PradigiTypography.h2),
          const SizedBox(height: PradigiSpacing.s24),
          
          // Checklist Items
          ...checkItems.map((item) => _buildCheckItem(item)),
          
          const SizedBox(height: PradigiSpacing.s24),
          const Divider(color: PradigiColors.border),
          const SizedBox(height: PradigiSpacing.s16),
          
          // Status Message & Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(statusMessage, style: PradigiTypography.caption.copyWith(color: PradigiColors.primary)),
              Text('$progress%', style: PradigiTypography.caption.copyWith(color: PradigiColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: PradigiSpacing.s8),
          LinearProgressIndicator(
            value: progress / 100.0,
            backgroundColor: PradigiColors.border,
            color: PradigiColors.primary,
            minHeight: 4,
          )
        ],
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
        icon = const SizedBox(width: 20, height: 20); // Placeholder
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
