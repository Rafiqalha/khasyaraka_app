import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:scout_os_app/core/services/quiz_haptic_service.dart';

class VulnSpotterWidget extends StatefulWidget {
  final String description;
  final List<Map<String, dynamic>> elements;
  final int totalVulns;
  final bool isChecked;
  final bool isCorrect;
  final Function(Set<int>) onVulnsFound;

  const VulnSpotterWidget({
    super.key,
    required this.description,
    required this.elements,
    required this.totalVulns,
    required this.isChecked,
    required this.isCorrect,
    required this.onVulnsFound,
  });

  @override
  State<VulnSpotterWidget> createState() => _VulnSpotterWidgetState();
}

class _VulnSpotterWidgetState extends State<VulnSpotterWidget>
    with TickerProviderStateMixin {
  final Set<int> _tappedIndices = {};
  final Set<int> _foundVulns = {};
  final Set<int> _safeTaps = {};
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onElementTap(int index) {
    if (widget.isChecked || _tappedIndices.contains(index)) return;

    final element = widget.elements[index];
    final isVuln = element['is_vuln'] as bool? ?? false;

    if (isVuln) {
      QuizHapticService.correctFeedback();
    } else {
      QuizHapticService.selectionFeedback();
    }

    setState(() {
      _tappedIndices.add(index);
      if (isVuln) {
        _foundVulns.add(index);
      } else {
        _safeTaps.add(index);
      }
    });

    widget.onVulnsFound(_foundVulns);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // Blueprint area
        _buildBlueprintArea(),
        const SizedBox(height: 16),
        // Counter
        _buildCounter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cyberBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.radar_rounded, color: AppColors.cyberBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Analisis Kerentanan',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueprintArea() {
    return Container(
      height: 350, // Adjusted to prevent overlap with button
      decoration: BoxDecoration(
        color: AppColors.deepCharcoal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Elegant pattern background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/pattern_dot.png', // Or just a clean background
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.deepCharcoal),
              ),
            ),
          ),

          // Render Elements
          ...List.generate(widget.elements.length, (index) {
            return _buildInteractiveElement(index);
          }),
        ],
      ),
    );
  }

  Widget _buildInteractiveElement(int index) {
    final element = widget.elements[index];
    final x = (element['x'] as num?)?.toDouble() ?? 0.0;
    final y = (element['y'] as num?)?.toDouble() ?? 0.0;
    final w = (element['w'] as num?)?.toDouble() ?? 0.0;
    final h = (element['h'] as num?)?.toDouble() ?? 0.0;
    final label = element['label'] as String? ?? '';
    final isVuln = element['is_vuln'] as bool? ?? false;
    final vulnType = element['vuln_type'] as String? ?? '';

    final isTapped = _tappedIndices.contains(index);

    // Default Glassmorphism style
    Color faceColor = Colors.white.withOpacity(0.05);
    Color lipColor = Colors.black.withOpacity(0.2);
    Color borderColor = Colors.white.withOpacity(0.1);
    Color textColor = Colors.white;

    if (isTapped) {
      if (isVuln) {
        faceColor = AppColors.alertRed;
        lipColor = AppColors.alertRed.withOpacity(0.6);
        borderColor = AppColors.alertRed;
        textColor = Colors.white;
      } else {
        faceColor = AppColors.duoSuccess;
        lipColor = AppColors.duoSuccess.withOpacity(0.6);
        borderColor = AppColors.duoSuccess;
        textColor = Colors.white;
      }
    } else if (widget.isChecked && isVuln) {
      // Reveal unfound vulns after check
      faceColor = Colors.orange.withOpacity(0.8);
      lipColor = Colors.orange.withOpacity(0.5);
      borderColor = Colors.orange;
      textColor = Colors.white;
    }

    return Positioned(
      left: x * 350,
      top: y * 350,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: () => _onElementTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: w * 350,
              constraints: BoxConstraints(
                minHeight: h * 350,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: faceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isTapped && isVuln) ...[
                      const SizedBox(height: 4),
                      _BlinkingText(
                        text: '[!! INTRUSION DETECTED !!]',
                        color: Colors.redAccent,
                        fontSize: 9,
                      ),
                    ],
                    if (isTapped && !isVuln) ...[
                      const SizedBox(height: 4),
                      Text('SAFE', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.greenAccent.withOpacity(0.7), fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCounter() {
    final remaining = widget.totalVulns - _foundVulns.length;
    final isDone = remaining <= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: isDone 
                  ? AppColors.duoSuccess.withOpacity(0.15)
                  : AppColors.cyberBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDone 
                    ? AppColors.duoSuccess.withOpacity(0.5)
                    : AppColors.cyberBlue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isDone ? Icons.verified_rounded : Icons.search_rounded,
                  color: isDone ? AppColors.duoSuccess : AppColors.cyberBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDone ? 'Semua ditemukan!' : 'Kerentanan tersisa:',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isDone)
                        Text(
                          '$remaining titik',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.cyberBlue,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BlinkingText extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;
  const _BlinkingText({required this.text, required this.color, required this.fontSize});

  @override
  State<_BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<_BlinkingText> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _ctrl.value.clamp(0.3, 1.0),
        child: Text(widget.text, style: GoogleFonts.jetBrainsMono(fontSize: widget.fontSize, fontWeight: FontWeight.w800, color: widget.color)),
      ),
    );
  }
}
