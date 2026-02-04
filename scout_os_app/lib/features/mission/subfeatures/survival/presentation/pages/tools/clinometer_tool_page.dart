import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';

class ClinometerToolPage extends StatefulWidget {
  const ClinometerToolPage({super.key});

  @override
  State<ClinometerToolPage> createState() => _ClinometerToolPageState();
}

class _ClinometerToolPageState extends State<ClinometerToolPage> {
  static const _background = Color(0xFFF5F5F5);
  static const _primaryGreen = Color(0xFF2E7D32);
  static const _darkGreen = Color(0xFF1B5E20);
  static const _gold = Color(0xFFFFD600);

  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _eyeHeightController = TextEditingController();
  final TextEditingController _targetHeightController = TextEditingController();

  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  double _currentAngle = 0;
  double? _lockedAngle;
  double? _calculatedHeight;
  double? _targetHeight;
  double? _accuracy;
  int _xpGained = 0;
  String? _rankTitle;

  @override
  void initState() {
    super.initState();
    _accelerometerSub = accelerometerEvents.listen((event) {
      final angle = math.atan2(event.y, event.z) * 180 / math.pi;
      final clamped = angle.clamp(-90.0, 90.0);
      if (mounted && _lockedAngle == null) {
        setState(() {
          _currentAngle = clamped;
        });
      } else {
        _currentAngle = clamped;
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    _distanceController.dispose();
    _eyeHeightController.dispose();
    _targetHeightController.dispose();
    super.dispose();
  }

  double _parseInput(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }

  Future<void> _lockAndCalculate() async {
    HapticFeedback.heavyImpact();
    if (_lockedAngle != null) {
      _resetLock();
      return;
    }
    if (_targetHeight == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan tinggi target terlebih dahulu.')),
      );
      return;
    }
    final distance = _parseInput(_distanceController.text);
    final eyeHeightCm = _parseInput(_eyeHeightController.text);

    if (distance <= 0 || eyeHeightCm <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jarak dan tinggi mata yang valid.')),
      );
      return;
    }

    final angle = _currentAngle;
    final radians = angle * math.pi / 180;
    final height = (distance * math.tan(radians)) + (eyeHeightCm / 100);

    setState(() {
      _lockedAngle = angle;
      _calculatedHeight = height;
    });

    if (height <= 0 || _targetHeight == null) {
      return;
    }

    final target = _targetHeight!;
    final diff = (target - height).abs();
    final accuracy = (100 - (diff / target * 100)).clamp(0.0, 100.0);
    final xpGained = accuracy >= 95
        ? 100
        : accuracy >= 90
            ? 50
            : accuracy >= 80
                ? 20
                : 0;

    final response = xpGained > 0
        ? await context.read<SurvivalMasteryController>().recordAction(
              toolType: 'clinometer',
              xpGained: xpGained,
              metadata: {
                'distance_m': distance,
                'eye_height_cm': eyeHeightCm,
                'angle_deg': angle,
                'height_m': height,
                'target_height_m': target,
                'accuracy': accuracy,
              },
            )
        : null;

    if (!mounted) return;
    final rankTitle = response?.rankTitle ??
        (accuracy >= 95
            ? 'Master Surveyor'
            : accuracy >= 90
                ? 'Skilled'
                : accuracy >= 80
                    ? 'Apprentice'
                    : 'Trainee');
    setState(() {
      _accuracy = accuracy;
      _xpGained = xpGained;
      _rankTitle = rankTitle;
    });
    final tip = accuracy < 80
        ? 'Coba kalibrasi tanganmu lagi.'
        : 'Pertahankan posisi dan sudutmu!';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Simulasi'),
        content: Text(
          'Target: ${target.toStringAsFixed(1)}m\n'
          'Hasil Ukur Kamu: ${height.toStringAsFixed(1)}m\n'
          'Akurasi: ${accuracy.toStringAsFixed(1)}% ($rankTitle)\n\n'
          'Tip: $tip',
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

  void _resetLock() {
    setState(() {
      _lockedAngle = null;
      _calculatedHeight = null;
      _accuracy = null;
      _xpGained = 0;
      _rankTitle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayAngle = _lockedAngle ?? _currentAngle;
    final isLocked = _lockedAngle != null;
    final needleColor = isLocked ? _gold : _primaryGreen;
    final needleThickness = isLocked ? 6.0 : 4.0;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: Text(
          'CLINOMETER',
          style: GoogleFonts.cinzel(
            color: _primaryGreen,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _resetLock,
            icon: const Icon(Icons.refresh, color: _primaryGreen),
          ),
        ],
      ),
      body: Stack(
        children: [
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: _primaryGreen,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: _primaryGreen,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Alat Ukur'),
                    Tab(text: 'Bedah Rumus'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildMeasurementTab(
                        displayAngle: displayAngle,
                        isLocked: isLocked,
                        needleColor: needleColor,
                        needleThickness: needleThickness,
                      ),
                      _buildEducationTab(
                        displayAngle: displayAngle,
                        isLocked: isLocked,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_targetHeight == null) _buildTargetInputOverlay(),
        ],
      ),
    );
  }

  Widget _buildTargetInputOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TARGET TINGGI',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.6,
                        color: _darkGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _targetHeightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: _darkGreen,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.0',
                        hintStyle: GoogleFonts.playfairDisplay(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                        suffixText: 'm',
                        suffixStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          color: _darkGreen,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const StadiumBorder(),
                          elevation: 8,
                          shadowColor: _primaryGreen.withValues(alpha: 0.35),
                        ),
                        onPressed: () {
                          final target = _parseInput(_targetHeightController.text);
                          if (target <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Masukkan tinggi target yang valid.')),
                            );
                            return;
                          }
                          setState(() {
                            _targetHeight = target;
                          });
                        },
                        child: Text(
                          'MULAI SIMULASI',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
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

  Widget _buildMeasurementTab({
    required double displayAngle,
    required bool isLocked,
    required Color needleColor,
    required double needleThickness,
  }) {
    final distance = _parseInput(_distanceController.text);
    final eyeHeightCm = _parseInput(_eyeHeightController.text);
    final heightMeters = _calculatedHeight;
    final target = _targetHeight;
    final accuracy = _accuracy;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 240),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _AngleGauge(
                        angle: displayAngle,
                        needleColor: needleColor,
                        needleThickness: needleThickness,
                        accentColor: _gold,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ANGLE',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '${displayAngle.toStringAsFixed(1)}°',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: _darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLocked && heightMeters != null ? 1 : 0,
                    child: isLocked && heightMeters != null
                        ? _MissionReportCard(
                            targetMeters: target ?? 0,
                            measuredMeters: heightMeters,
                            accuracy: accuracy ?? 0,
                            xpGained: _xpGained,
                            rankTitle: _rankTitle,
                            onCopy: () => _copyReport(
                              distance: distance,
                              angle: displayAngle,
                              eyeHeightCm: eyeHeightCm,
                              heightMeters: heightMeters,
                            ),
                          )
                        : const SizedBox(height: 0),
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
          child: _ControlCard(
            distanceController: _distanceController,
            eyeHeightController: _eyeHeightController,
            onLock: _lockAndCalculate,
            isLocked: isLocked,
          ),
        ),
      ],
    );
  }

  Widget _buildEducationTab({
    required double displayAngle,
    required bool isLocked,
  }) {
    final distance = _parseInput(_distanceController.text);
    final eyeHeightCm = _parseInput(_eyeHeightController.text);
    final angleRadians = displayAngle * math.pi / 180;
    final tanValue = math.tan(angleRadians);
    final heightMeters = _calculatedHeight ??
        (distance > 0 && eyeHeightCm > 0
            ? (distance * tanValue) + (eyeHeightCm / 100)
            : null);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _NotebookCard(
          title: 'Ilustrasi Segitiga',
          child: _TriangleDiagram(
            distance: distance,
            angle: displayAngle,
            heightMeters: heightMeters ?? 0,
          ),
        ),
        const SizedBox(height: 16),
        _NotebookCard(
          title: 'Langkah Perhitungan',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FormulaLine(
                title: '1. Diketahui',
                value:
                    'd = ${distance.toStringAsFixed(2)} m, tm = ${eyeHeightCm.toStringAsFixed(0)} cm, θ = ${displayAngle.toStringAsFixed(1)}°',
              ),
              _FormulaLine(
                title: '2. Rumus',
                value: 'h = (d × tan(θ)) + tm',
              ),
              _FormulaLine(
                title: '3. Substitusi',
                value: 'h = (${distance.toStringAsFixed(2)} × ${tanValue.toStringAsFixed(2)}) + ${(eyeHeightCm / 100).toStringAsFixed(2)}',
              ),
              _FormulaLine(
                title: '4. Hasil',
                value: heightMeters != null
                    ? 'h = ${heightMeters.toStringAsFixed(2)} m'
                    : 'h = (isi data untuk melihat hasil)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _NotebookCard(
          title: 'Tabel Tan (Cheat Sheet)',
          child: Column(
            children: const [
              _TanRow(angle: '30°', value: '0.58'),
              _TanRow(angle: '45°', value: '1.00'),
              _TanRow(angle: '60°', value: '1.73'),
            ],
          ),
        ),
        if (!isLocked)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Kunci sudut untuk laporan yang rapi.',
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
          ),
      ],
    );
  }

  Future<void> _copyReport({
    required double distance,
    required double angle,
    required double eyeHeightCm,
    required double heightMeters,
  }) async {
    final report = _buildReportText(
      distance: distance,
      angle: angle,
      eyeHeightCm: eyeHeightCm,
      heightMeters: heightMeters,
    );
    await Clipboard.setData(ClipboardData(text: report));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Laporan disalin ke clipboard.')),
    );
  }

  String _buildReportText({
    required double distance,
    required double angle,
    required double eyeHeightCm,
    required double heightMeters,
  }) {
    final tanValue = math.tan(angle * math.pi / 180);
    final eyeHeightMeters = eyeHeightCm / 100;
    return '''
LAPORAN MENAKSIR TINGGI
-----------------------
Metode: Trigonometri (Klinometer)
Jarak ke Objek : ${distance.toStringAsFixed(2)} m
Sudut Elevasi  : ${angle.toStringAsFixed(1)}°
Tinggi Mata    : ${eyeHeightCm.toStringAsFixed(0)} cm

Perhitungan:
T = (Jarak x Tan(Sudut)) + TM
T = (${distance.toStringAsFixed(2)} x ${tanValue.toStringAsFixed(2)}) + ${eyeHeightMeters.toStringAsFixed(2)}
T = ${heightMeters.toStringAsFixed(2)} m

Kesimpulan: Tinggi objek estimasi adalah ${heightMeters.toStringAsFixed(2)} meter.
''';
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.distanceController,
    required this.eyeHeightController,
    required this.onLock,
    required this.isLocked,
  });

  final TextEditingController distanceController;
  final TextEditingController eyeHeightController;
  final VoidCallback onLock;
  final bool isLocked;

  static const _primaryGreen = Color(0xFF2E7D32);
  static const _dangerRed = Color(0xFFD32F2F);

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
                  controller: distanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Jarak (m)',
                    prefixIcon: const Icon(Icons.straighten),
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
                  controller: eyeHeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Tinggi Mata (cm)',
                    prefixIcon: const Icon(Icons.visibility_outlined),
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
                backgroundColor: isLocked ? _dangerRed : _primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
                shadowColor: (isLocked ? _dangerRed : _primaryGreen)
                    .withValues(alpha: 0.35),
              ),
              onPressed: onLock,
              child: Text(
                isLocked ? 'UNLOCK / RESET' : 'LOCK & HITUNG',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionReportCard extends StatelessWidget {
  const _MissionReportCard({
    required this.targetMeters,
    required this.measuredMeters,
    required this.accuracy,
    required this.xpGained,
    required this.rankTitle,
    required this.onCopy,
  });

  final double targetMeters;
  final double measuredMeters;
  final double accuracy;
  final int xpGained;
  final String? rankTitle;
  final VoidCallback onCopy;

  static const _textDark = Color(0xFF1B5E20);
  static const _primaryGreen = Color(0xFF2E7D32);
  static const _gold = Color(0xFFFFD600);

  @override
  Widget build(BuildContext context) {
    final accuracyValue = (accuracy / 100).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(top: 12),
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
          Row(
            children: [
              Text(
                'Mission Report',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Salin Laporan',
                onPressed: onCopy,
                icon: const Icon(Icons.copy, color: _textDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 90,
                width: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: accuracyValue,
                      strokeWidth: 8,
                      backgroundColor: Colors.black.withValues(alpha: 0.08),
                      color: _primaryGreen,
                    ),
                    Text(
                      '${accuracy.toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akurasi',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      rankTitle ?? 'Surveyor',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: xpGained > 0 ? 1 : 0.9,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '+$xpGained XP',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Target',
                  value: '${targetMeters.toStringAsFixed(1)} m',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatChip(
                  label: 'Measured',
                  value: '${measuredMeters.toStringAsFixed(1)} m',
                ),
              ),
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

class _AngleGauge extends StatelessWidget {
  const _AngleGauge({
    required this.angle,
    required this.needleColor,
    required this.needleThickness,
    required this.accentColor,
  });

  final double angle;
  final Color needleColor;
  final double needleThickness;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: angle),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          height: 220,
          child: CustomPaint(
            painter: _ProtractorPainter(
              angle: value,
              needleColor: needleColor,
              needleThickness: needleThickness,
              accentColor: accentColor,
            ),
          ),
        );
      },
    );
  }
}

class _NotebookCard extends StatelessWidget {
  const _NotebookCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
          child,
        ],
      ),
    );
  }
}

class _FormulaLine extends StatelessWidget {
  const _FormulaLine({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(color: const Color(0xFF3E2723)),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _TanRow extends StatelessWidget {
  const _TanRow({required this.angle, required this.value});

  final String angle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(angle, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }
}

class _TriangleDiagram extends StatelessWidget {
  const _TriangleDiagram({
    required this.distance,
    required this.angle,
    required this.heightMeters,
  });

  final double distance;
  final double angle;
  final double heightMeters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: _TrianglePainter(angle: angle, heightMeters: heightMeters, distance: distance),
          ),
          Positioned(
            left: 8,
            bottom: 12,
            child: Text('Jarak (d)', style: GoogleFonts.poppins(fontSize: 12)),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Text('Tinggi (h)', style: GoogleFonts.poppins(fontSize: 12)),
          ),
          Positioned(
            left: 10,
            top: 8,
            child: Text('Sudut (θ)', style: GoogleFonts.poppins(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({
    required this.angle,
    required this.heightMeters,
    required this.distance,
  });

  final double angle;
  final double heightMeters;
  final double distance;

  @override
  void paint(Canvas canvas, Size size) {
    final base = distance <= 0 ? 1.0 : distance;
    final height = heightMeters <= 0 ? base * math.tan(angle * math.pi / 180) : heightMeters;

    final maxBase = base;
    final maxHeight = math.max(height.abs(), 0.1);
    final scale = math.min(size.width * 0.7 / maxBase, size.height * 0.7 / maxHeight);

    final origin = Offset(size.width * 0.15, size.height * 0.85);
    final baseEnd = Offset(origin.dx + base * scale, origin.dy);
    final top = Offset(origin.dx + base * scale, origin.dy - height * scale);

    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final anglePaint = Paint()
      ..color = const Color(0xFFFFD600)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(origin, baseEnd, paint);
    canvas.drawLine(baseEnd, top, paint);
    canvas.drawLine(origin, top, paint);

    final arcRect = Rect.fromCircle(center: origin, radius: 24);
    final radians = angle * math.pi / 180;
    canvas.drawArc(arcRect, 0, -radians, false, anglePaint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.heightMeters != heightMeters ||
        oldDelegate.distance != distance;
  }
}
class _ProtractorPainter extends CustomPainter {
  _ProtractorPainter({
    required this.angle,
    required this.needleColor,
    required this.needleThickness,
    required this.accentColor,
  });

  final double angle;
  final Color needleColor;
  final double needleThickness;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final arcPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final tickPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..strokeWidth = 1.4;

    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = needleThickness
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      arcPaint,
    );

    for (int i = -90; i <= 90; i += 10) {
      final radians = (i * math.pi / 180) + math.pi;
      final start = Offset(
        center.dx + (radius - 10) * math.cos(radians),
        center.dy + (radius - 10) * math.sin(radians),
      );
      final end = Offset(
        center.dx + radius * math.cos(radians),
        center.dy + radius * math.sin(radians),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    final angleRadians = (angle * math.pi / 180) + math.pi;
    final needleEnd = Offset(
      center.dx + (radius - 24) * math.cos(angleRadians),
      center.dy + (radius - 24) * math.sin(angleRadians),
    );
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 6, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _ProtractorPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.needleColor != needleColor ||
        oldDelegate.needleThickness != needleThickness ||
        oldDelegate.accentColor != accentColor;
  }
}
