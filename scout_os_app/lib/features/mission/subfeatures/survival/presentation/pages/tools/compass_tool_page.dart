import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';

class CompassToolPage extends StatefulWidget {
  const CompassToolPage({super.key});

  @override
  State<CompassToolPage> createState() => _CompassToolPageState();
}

class _CompassToolPageState extends State<CompassToolPage> {
  static const _background = Color(0xFFF5F5F5);
  static const _surface = Colors.white;
  static const _primaryGreen = Color(0xFF2E7D32);
  static const _gold = Color(0xFFFFD600);
  static const _textDark = Color(0xFF1B5E20);

  double? _targetAzimuth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: Text(
          'AZIMUTH MASTER',
          style: GoogleFonts.cinzel(
            color: _primaryGreen,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: _primaryGreen,
              unselectedLabelColor: Colors.black54,
              indicatorColor: _primaryGreen,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Latihan'),
                Tab(text: 'Teori'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTrainingTab(),
                  _buildTheoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingTab() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading;
        if (heading == null) {
          return _buildUnavailable();
        }

        final normalized = (heading + 360) % 360;
        final backAzimuth = normalized < 180 ? normalized + 180 : normalized - 180;
        final direction = _cardinalDirection(normalized);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildReadout(normalized, direction, backAzimuth),
            const SizedBox(height: 16),
            _buildCompassCard(normalized),
            const SizedBox(height: 16),
            _buildControlPanel(normalized),
          ],
        );
      },
    );
  }

  Widget _buildUnavailable() {
    return Center(
      child: Text(
        'Sensor tidak tersedia.',
        style: GoogleFonts.poppins(color: Colors.black54),
      ),
    );
  }

  Widget _buildReadout(double heading, String direction, double backAzimuth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${heading.toStringAsFixed(0)}° $direction',
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Back Azimuth: ${backAzimuth.toStringAsFixed(0)}°',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassCard(double heading) {
    final target = _targetAzimuth;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: _CompassCirclePainter(),
            ),
            Transform.rotate(
              angle: -heading * math.pi / 180,
              child: CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: _CompassRosePainter(),
              ),
            ),
            if (target != null)
              Transform.rotate(
                angle: (target - heading) * math.pi / 180,
                child: _GhostNeedle(color: _gold),
              ),
            _PrimaryNeedle(color: _primaryGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(double heading) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: _textDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.assistant_navigation),
                  label: const Text('Minta Sasaran'),
                  onPressed: () {
                    final random = math.Random();
                    setState(() {
                      _targetAzimuth = random.nextDouble() * 360;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('LOCK / BIDIK'),
                  onPressed: () => _handleLock(heading),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _targetAzimuth == null
                ? 'Belum ada sasaran. Tekan "Minta Sasaran".'
                : 'Target: ${_targetAzimuth!.toStringAsFixed(0)}°',
            style: GoogleFonts.poppins(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLock(double heading) async {
    final target = _targetAzimuth;
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buat sasaran dulu.')),
      );
      return;
    }

    HapticFeedback.heavyImpact();

    final diff = _angleDiff(heading, target);
    final accuracy = diff <= 2
        ? 100.0
        : (100 - ((diff - 2) / 178 * 100)).clamp(0.0, 100.0);

    int xpGained = 0;
    if (accuracy > 90) {
      xpGained = 50;
      await context.read<SurvivalMasteryController>().recordAction(
            toolType: 'compass',
            xpGained: xpGained,
            metadata: {
              'target_azimuth': target,
              'heading': heading,
              'accuracy': accuracy,
            },
          );
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Bidikan'),
        content: Text(
          'Target: ${target.toStringAsFixed(0)}°\n'
          'Bidikanmu: ${heading.toStringAsFixed(0)}°\n'
          'Akurasi: ${accuracy.toStringAsFixed(1)}%\n'
          '${xpGained > 0 ? '(+${xpGained} XP)' : 'Belum dapat XP'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _TheoryCard(
          title: 'Aturan Back Azimuth',
          body:
              'Jika azimuth < 180°, maka tambah 180°. Jika azimuth ≥ 180°, maka kurangi 180°.',
        ),
        const SizedBox(height: 12),
        _TheoryCard(
          title: 'Contoh',
          body: 'Forward 45° → Back 225°.\nForward 250° → Back 70°.',
        ),
        const SizedBox(height: 12),
        _TheoryCard(
          title: 'Visual',
          child: _AzimuthDiagram(),
        ),
      ],
    );
  }

  double _angleDiff(double a, double b) {
    final diff = (a - b + 540) % 360 - 180;
    return diff.abs();
  }

  String _cardinalDirection(double heading) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((heading + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}

class _CompassCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final circlePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 4, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 360; i += 15) {
      final radians = i * math.pi / 180;
      final inner = radius - (i % 90 == 0 ? 18 : 10);
      final start = Offset(
        center.dx + inner * math.cos(radians),
        center.dy + inner * math.sin(radians),
      );
      final end = Offset(
        center.dx + radius * math.cos(radians),
        center.dy + radius * math.sin(radians),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    const labels = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = i * 90 * math.pi / 180;
      final labelOffset = Offset(
        center.dx + (radius - 32) * math.cos(angle),
        center.dy + (radius - 32) * math.sin(angle),
      );
      textPainter.text = TextSpan(
        text: labels[i],
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1B5E20),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        labelOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PrimaryNeedle extends StatelessWidget {
  const _PrimaryNeedle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 90,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _GhostNeedle extends StatelessWidget {
  const _GhostNeedle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 70,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _TheoryCard extends StatelessWidget {
  const _TheoryCard({required this.title, this.body, this.child});

  final String title;
  final String? body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          if (body != null)
            Text(
              body!,
              style: GoogleFonts.poppins(color: Colors.black87),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _AzimuthDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _AzimuthDiagramPainter(),
      ),
    );
  }
}

class _AzimuthDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    final circlePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final forwardPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final backPaint = Paint()
      ..color = const Color(0xFFFFD600)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, circlePaint);

    final forward = Offset(center.dx + radius * math.cos(-math.pi / 4),
        center.dy + radius * math.sin(-math.pi / 4));
    final back = Offset(center.dx + radius * math.cos(math.pi * 3 / 4),
        center.dy + radius * math.sin(math.pi * 3 / 4));

    canvas.drawLine(center, forward, forwardPaint);
    canvas.drawLine(center, back, backPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
