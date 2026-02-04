import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';

class RiverToolPage extends StatefulWidget {
  const RiverToolPage({super.key});

  @override
  State<RiverToolPage> createState() => _RiverToolPageState();
}

class _RiverToolPageState extends State<RiverToolPage> with SingleTickerProviderStateMixin {
  static const _background = Color(0xFFF5F5F5);
  static const _primaryGreen = Color(0xFF2E7D32);
  static const _darkGreen = Color(0xFF1B5E20);
  static const _gold = Color(0xFFFFD600);
  static const _dangerRed = Color(0xFFD32F2F);

  late final TabController _tabController;

  final TextEditingController _stepLengthController =
      TextEditingController(text: '65');
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _targetWidthController = TextEditingController();

  final TextEditingController _flowDistanceController =
      TextEditingController(text: '5');
  final TextEditingController _targetFlowController = TextEditingController();

  double? _targetWidth;
  double? _targetFlow;

  double? _widthMeters;
  double? _widthAccuracy;
  int _widthXp = 0;
  String? _widthRank;

  bool _isRunning = false;
  double _elapsedSeconds = 0;
  Timer? _timer;
  double? _velocity;
  double? _flowAccuracy;
  int _flowXp = 0;
  String? _flowRank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stepLengthController.dispose();
    _stepsController.dispose();
    _targetWidthController.dispose();
    _flowDistanceController.dispose();
    _targetFlowController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  double _parseInput(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }

  Future<void> _calculateWidth() async {
    final stepLengthCm = _parseInput(_stepLengthController.text);
    final steps = _parseInput(_stepsController.text);
    if (stepLengthCm <= 0 || steps <= 0) {
      _showSnack('Masukkan panjang langkah dan jumlah langkah yang valid.');
      return;
    }

    final width = (steps * stepLengthCm) / 100;
    setState(() {
      _widthMeters = width;
    });

    if (_targetWidth == null) return;
    final accuracy = _calculateAccuracy(_targetWidth!, width);
    final xpGained = _xpFromAccuracy(accuracy);

    final response = xpGained > 0
        ? await context.read<SurvivalMasteryController>().recordAction(
              toolType: 'leveler',
              xpGained: xpGained,
              metadata: {
                'method': 'river_width',
                'step_length_cm': stepLengthCm,
                'steps': steps,
                'width_m': width,
                'target_width_m': _targetWidth,
                'accuracy': accuracy,
              },
            )
        : null;

    setState(() {
      _widthAccuracy = accuracy;
      _widthXp = xpGained;
      _widthRank = response?.rankTitle ?? _rankFromAccuracy(accuracy);
    });
  }

  void _toggleStopwatch() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
      _calculateFlowResult();
      return;
    }

    setState(() {
      _elapsedSeconds = 0;
      _isRunning = true;
      _velocity = null;
      _flowAccuracy = null;
      _flowXp = 0;
      _flowRank = null;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsedSeconds += 0.1;
      });
    });
  }

  Future<void> _calculateFlowResult() async {
    final distance = _parseInput(_flowDistanceController.text);
    if (distance <= 0 || _elapsedSeconds <= 0.1) {
      _showSnack('Jarak lintasan atau waktu belum valid.');
      return;
    }

    final velocity = distance / _elapsedSeconds;
    setState(() {
      _velocity = velocity;
    });

    if (_targetFlow == null) return;
    final accuracy = _calculateAccuracy(_targetFlow!, velocity);
    final xpGained = _xpFromAccuracy(accuracy);

    final response = xpGained > 0
        ? await context.read<SurvivalMasteryController>().recordAction(
              toolType: 'leveler',
              xpGained: xpGained,
              metadata: {
                'method': 'river_flow',
                'distance_m': distance,
                'time_s': _elapsedSeconds,
                'velocity_ms': velocity,
                'target_velocity_ms': _targetFlow,
                'accuracy': accuracy,
              },
            )
        : null;

    setState(() {
      _flowAccuracy = accuracy;
      _flowXp = xpGained;
      _flowRank = response?.rankTitle ?? _rankFromAccuracy(accuracy);
    });
  }

  double _calculateAccuracy(double target, double measured) {
    final diff = (target - measured).abs();
    return (100 - (diff / target * 100)).clamp(0.0, 100.0);
  }

  int _xpFromAccuracy(double accuracy) {
    if (accuracy >= 95) return 100;
    if (accuracy >= 90) return 50;
    if (accuracy >= 80) return 20;
    return 0;
  }

  String _rankFromAccuracy(double accuracy) {
    if (accuracy >= 95) return 'Master Surveyor';
    if (accuracy >= 90) return 'Skilled';
    if (accuracy >= 80) return 'Apprentice';
    return 'Trainee';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isWidthTab = _tabController.index == 0;
    final targetMissing = isWidthTab ? _targetWidth == null : _targetFlow == null;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: Text(
          'RIVER TOOL',
          style: GoogleFonts.cinzel(
            color: _primaryGreen,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: _primaryGreen,
                unselectedLabelColor: Colors.black54,
                indicatorColor: _primaryGreen,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Lebar Sungai'),
                  Tab(text: 'Kecepatan Arus'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWidthTab(),
                    _buildFlowTab(),
                  ],
                ),
              ),
            ],
          ),
          if (targetMissing) _buildTargetOverlay(isWidthTab),
        ],
      ),
    );
  }

  Widget _buildWidthTab() {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 220),
            child: Column(
              children: [
                _DiagramCard(
                  child: Column(
                    children: [
                      const _RiverDiagram(),
                      const SizedBox(height: 12),
                      Text(
                        'Metode Segitiga Sebangun 1:1. Jarak mundur = lebar sungai.',
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_widthMeters != null)
                  _WidthReportCard(
                    widthMeters: _widthMeters!,
                    accuracy: _widthAccuracy ?? 0,
                    xpGained: _widthXp,
                    rankTitle: _widthRank,
                    targetMeters: _targetWidth ?? 0,
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _WidthControlPanel(
            stepLengthController: _stepLengthController,
            stepsController: _stepsController,
            onCalculate: _calculateWidth,
          ),
        ),
      ],
    );
  }

  Widget _buildFlowTab() {
    final velocity = _velocity;
    final safetyText = velocity == null
        ? 'Mulai pengukuran untuk melihat hasil.'
        : velocity > 1.0
            ? 'ARUS DERAS! BAHAYA!'
            : velocity < 0.5
                ? 'Arus Tenang'
                : 'Arus Sedang';
    final safetyColor = velocity == null
        ? Colors.black54
        : velocity > 1.0
            ? _dangerRed
            : velocity < 0.5
                ? _primaryGreen
                : _gold;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 220),
            child: Column(
              children: [
                _DiagramCard(
                  child: Column(
                    children: [
                      Text(
                        'Jarak Lintasan & Stopwatch',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: _darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _elapsedSeconds.toStringAsFixed(1),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: _darkGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _toggleStopwatch,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRunning ? _dangerRed : _primaryGreen,
                            boxShadow: [
                              BoxShadow(
                                color: (_isRunning ? _dangerRed : _primaryGreen)
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isRunning ? 'STOP' : 'START',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (velocity != null)
                  _FlowReportCard(
                    velocity: velocity,
                    accuracy: _flowAccuracy ?? 0,
                    xpGained: _flowXp,
                    rankTitle: _flowRank,
                    targetVelocity: _targetFlow ?? 0,
                  ),
                const SizedBox(height: 12),
                Text(
                  safetyText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: safetyColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _FlowControlPanel(
            distanceController: _flowDistanceController,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetOverlay(bool isWidthTab) {
    final controller = isWidthTab ? _targetWidthController : _targetFlowController;
    final label = isWidthTab ? 'TARGET LEBAR (m)' : 'TARGET ARUS (m/s)';

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: _darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: _darkGreen,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.0',
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          final value = _parseInput(controller.text);
                          if (value <= 0) {
                            _showSnack('Masukkan target yang valid.');
                            return;
                          }
                          setState(() {
                            if (isWidthTab) {
                              _targetWidth = value;
                            } else {
                              _targetFlow = value;
                            }
                          });
                        },
                        child: const Text('MULAI SIMULASI'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagramCard extends StatelessWidget {
  const _DiagramCard({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _RiverDiagram extends StatelessWidget {
  const _RiverDiagram();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _RiverDiagramPainter(),
      ),
    );
  }
}

class _RiverDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final riverPaint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final riverRect = Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.3);
    canvas.drawRect(riverRect, riverPaint);

    final a = Offset(size.width * 0.2, size.height * 0.2);
    final b = Offset(size.width * 0.7, size.height * 0.5);
    final c = Offset(size.width * 0.2, size.height * 0.8);
    final d = Offset(size.width * 0.5, size.height * 0.9);

    canvas.drawLine(a, b, paint);
    canvas.drawLine(b, c, paint);
    canvas.drawLine(c, d, paint);

    final dotPaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawCircle(a, 4, dotPaint);
    canvas.drawCircle(b, 4, dotPaint);
    canvas.drawCircle(c, 4, dotPaint);
    canvas.drawCircle(d, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WidthControlPanel extends StatelessWidget {
  const _WidthControlPanel({
    required this.stepLengthController,
    required this.stepsController,
    required this.onCalculate,
  });

  final TextEditingController stepLengthController;
  final TextEditingController stepsController;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: stepLengthController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Panjang Langkah (cm)',
                    prefixIcon: const Icon(Icons.directions_walk),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: stepsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Jumlah Langkah',
                    prefixIcon: const Icon(Icons.north),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF2E7D32).withValues(alpha: 0.35),
              ),
              onPressed: onCalculate,
              child: Text(
                'HITUNG LEBAR',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, letterSpacing: 1.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowControlPanel extends StatelessWidget {
  const _FlowControlPanel({required this.distanceController});

  final TextEditingController distanceController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: TextField(
        controller: distanceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: 'Jarak Lintasan (m)',
          prefixIcon: const Icon(Icons.waves),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _WidthReportCard extends StatelessWidget {
  const _WidthReportCard({
    required this.widthMeters,
    required this.accuracy,
    required this.xpGained,
    required this.rankTitle,
    required this.targetMeters,
  });

  final double widthMeters;
  final double accuracy;
  final int xpGained;
  final String? rankTitle;
  final double targetMeters;

  @override
  Widget build(BuildContext context) {
    return _ReportCardBase(
      title: 'Hasil Lebar Sungai',
      accuracy: accuracy,
      xpGained: xpGained,
      rankTitle: rankTitle,
      leftLabel: 'Target',
      leftValue: '${targetMeters.toStringAsFixed(1)} m',
      rightLabel: 'Hasil',
      rightValue: '${widthMeters.toStringAsFixed(1)} m',
    );
  }
}

class _FlowReportCard extends StatelessWidget {
  const _FlowReportCard({
    required this.velocity,
    required this.accuracy,
    required this.xpGained,
    required this.rankTitle,
    required this.targetVelocity,
  });

  final double velocity;
  final double accuracy;
  final int xpGained;
  final String? rankTitle;
  final double targetVelocity;

  @override
  Widget build(BuildContext context) {
    return _ReportCardBase(
      title: 'Hasil Kecepatan',
      accuracy: accuracy,
      xpGained: xpGained,
      rankTitle: rankTitle,
      leftLabel: 'Target',
      leftValue: '${targetVelocity.toStringAsFixed(2)} m/s',
      rightLabel: 'Hasil',
      rightValue: '${velocity.toStringAsFixed(2)} m/s',
    );
  }
}

class _ReportCardBase extends StatelessWidget {
  const _ReportCardBase({
    required this.title,
    required this.accuracy,
    required this.xpGained,
    required this.rankTitle,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String title;
  final double accuracy;
  final int xpGained;
  final String? rankTitle;
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    final accuracyValue = (accuracy / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 78,
                width: 78,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: accuracyValue,
                      strokeWidth: 7,
                      backgroundColor: Colors.black.withValues(alpha: 0.08),
                      color: const Color(0xFF2E7D32),
                    ),
                    Text(
                      '${accuracy.toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rankTitle ?? 'Surveyor',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD600).withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '+$xpGained XP',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatChip(label: leftLabel, value: leftValue)),
              const SizedBox(width: 12),
              Expanded(child: _StatChip(label: rightLabel, value: rightValue)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }
}
