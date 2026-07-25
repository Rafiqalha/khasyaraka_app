import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuizFeedbackSheet extends StatelessWidget {
  final bool isCorrect;
  final String? correctAnswer;
  final VoidCallback onContinue;
  final String? aiDialog;
  final String? aiStatus;
  final int computationalScoreChange;
  final int ethicalScoreChange;
  final bool isAiEvaluating;
  final String? nextObjective;
  final String? threatMutation;
  final String? adaptiveNarrative;
  final int difficultyAdjustment;

  const QuizFeedbackSheet({
    super.key,
    required this.isCorrect,
    this.correctAnswer,
    required this.onContinue,
    this.aiDialog,
    this.aiStatus,
    this.computationalScoreChange = 0,
    this.ethicalScoreChange = 0,
    this.isAiEvaluating = false,
    this.nextObjective,
    this.threatMutation,
    this.adaptiveNarrative,
    this.difficultyAdjustment = 0,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isCorrect ? const Color(0xFF3FB950) : const Color(0xFFF85149);
    final statusText = isCorrect ? 'EVALUATION: SUCCESS' : 'OPERATION: INCOMPLETE';
    final pointText = isCorrect ? '+${computationalScoreChange + ethicalScoreChange} points acquired' : 'Analysis complete';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: _buildContent(statusColor, statusText, pointText),
      ),
    ).animate().moveY(begin: 80, end: 0, duration: 350.ms, curve: Curves.easeOutCubic).fadeIn(duration: 200.ms);
  }

  Widget _buildContent(Color statusColor, String statusText, String pointText) {
    final List<Widget> items = [];

    items.add(const SizedBox(height: 24));
    items.add(FaIcon(
      isCorrect ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circleXmark,
      color: statusColor,
      size: 36,
    ));
    items.add(const SizedBox(height: 16));
    items.add(Text(statusText, style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 1.2)));
    items.add(const SizedBox(height: 8));
    items.add(Text(pointText, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF8B949E))));
    items.add(const SizedBox(height: 20));

    if (!isCorrect && correctAnswer != null) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(10)),
          child: Text(correctAnswer!, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF8B949E), fontSize: 14)),
        ),
      ));
      items.add(const SizedBox(height: 16));
    }

    if (isAiEvaluating) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF58A6FF))),
            const SizedBox(width: 10),
            Text('AI evaluating...', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF8B949E), fontSize: 13)),
          ]),
        ),
      ));
    }

    if (!isAiEvaluating && aiDialog != null && aiDialog!.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const FaIcon(FontAwesomeIcons.robot, color: Color(0xFF8B949E), size: 14),
              const SizedBox(width: 8),
              Text('Pradigi Core', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF8B949E), fontSize: 13, fontWeight: FontWeight.w600)),
              if (aiStatus != null) const SizedBox(width: 8),
              if (aiStatus != null) Text(aiStatus!.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: const Color(0xFF58A6FF), fontSize: 10)),
            ]),
            const SizedBox(height: 10),
            Text(aiDialog!, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFC9D1D9), fontSize: 14, height: 1.5)),
            if (computationalScoreChange != 0 || ethicalScoreChange != 0) ...[
              const SizedBox(height: 14),
              const Divider(color: Color(0xFF30363D)),
              const SizedBox(height: 12),
              Row(children: [
                _Chip(label: 'COMP', score: computationalScoreChange, color: const Color(0xFF58A6FF)),
                const SizedBox(width: 10),
                _Chip(label: 'ETHIC', score: ethicalScoreChange, color: const Color(0xFF3FB950)),
              ]),
            ],
          ]),
        ),
      ));
    }

    if (!isAiEvaluating && (nextObjective != null || threatMutation != null || adaptiveNarrative != null)) {
      items.add(const SizedBox(height: 12));
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF30363D), width: 0.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('GAME MASTER UPDATE', style: GoogleFonts.jetBrainsMono(color: const Color(0xFFD29922), fontSize: 10, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (nextObjective != null && nextObjective!.isNotEmpty) ...[
              Text('>>> OBJECTIVE', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF58A6FF), fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(nextObjective!, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFC9D1D9), fontSize: 12, height: 1.4)),
              const SizedBox(height: 8),
            ],
            if (threatMutation != null && threatMutation!.isNotEmpty) ...[
              Text('>>> THREAT EVOLUTION', style: GoogleFonts.jetBrainsMono(color: const Color(0xFFF85149), fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(threatMutation!, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFC9D1D9), fontSize: 12, height: 1.4)),
              const SizedBox(height: 8),
            ],
            if (adaptiveNarrative != null && adaptiveNarrative!.isNotEmpty) ...[
              Text('>>> NARRATIVE', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF8B949E), fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(adaptiveNarrative!, style: GoogleFonts.plusJakartaSans(color: Color(0xFF8B949E), fontSize: 12, height: 1.4, fontStyle: FontStyle.italic)),
            ],
            if (difficultyAdjustment != 0) ...[
              const SizedBox(height: 8),
              Text('DIFFICULTY ${difficultyAdjustment > 0 ? "+" : ""}$difficultyAdjustment', style: GoogleFonts.jetBrainsMono(color: difficultyAdjustment > 0 ? const Color(0xFFF85149) : const Color(0xFF3FB950), fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ]),
        ),
      ));
    }

    items.add(const SizedBox(height: 24));
    items.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF21262D),
            foregroundColor: const Color(0xFFC9D1D9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF30363D))),
            elevation: 0,
          ),
          child: Text('Continue', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    ));
    items.add(const SizedBox(height: 32));

    return Column(mainAxisSize: MainAxisSize.min, children: items);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.score, required this.color});
  final String label;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final sign = score >= 0 ? '+' : '';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      FaIcon(score >= 0 ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown, color: color, size: 11),
      const SizedBox(width: 4),
      Text('$label $sign$score', style: GoogleFonts.jetBrainsMono(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }
}
