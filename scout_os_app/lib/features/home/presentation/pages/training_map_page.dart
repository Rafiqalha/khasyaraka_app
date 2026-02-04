import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:scout_os_app/core/config/theme_config.dart';
import 'package:scout_os_app/features/home/presentation/widgets/glossy_stats_bar.dart';
import 'package:scout_os_app/features/home/presentation/widgets/lesson_node_widget.dart';
import '../../logic/training_controller.dart';
import '../../data/models/training_path.dart';
import 'quiz_page.dart';
import 'package:flutter/foundation.dart';

class TrainingMapPage extends StatefulWidget {
  const TrainingMapPage({super.key});

  @override
  State<TrainingMapPage> createState() => _TrainingMapPageState();
}

class _TrainingMapPageState extends State<TrainingMapPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  
  // Konfigurasi Zigzag
  final double _itemSpacing = 100.0; // Jarak vertikal antar node
  final double _amplitude = 75.0; // Seberapa jauh belok ke kiri/kanan

  @override
  void initState() {
    super.initState();
    // Load data when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<TrainingController>(context, listen: false);
      controller.refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<TrainingController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: ThemeConfig.primaryBrown),
              );
            }

            if (controller.errorMessage != null) {
              return _buildErrorState(controller);
            }

            if (controller.units.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async => controller.refresh(),
              color: ThemeConfig.primaryBrown,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_rounded, color: ThemeConfig.secondaryGrey),
                        const SizedBox(width: 8),
                        Text(
                          'Peta Belajar',
                          style: TextStyle(
                            color: ThemeConfig.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConfig.spaceL,
                        vertical: ThemeConfig.spaceM,
                      ),
                      child: Center(
                        child: Builder(
                          builder: (context) {
                            // CRITICAL: Use Consumer to ensure rebuild when stats change
                            return Consumer<TrainingController>(
                              builder: (context, ctrl, _) {
                                debugPrint('🔄 [UI] GlossyStatsBar rebuild: XP=${ctrl.userXp}, Streak=${ctrl.userStreak}');
                                return GlossyStatsBar(
                                  streak: ctrl.userStreak,
                                  totalXp: ctrl.userXp,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  ...controller.units.asMap().entries.map((unitEntry) {
                    final index = unitEntry.key;
                    final unit = unitEntry.value;
                    return _buildUnitSection(unit, index, controller.units.length);
                  }),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ... _buildErrorState and _buildEmptyState (Keep your existing implementation or verify below) ...
  Widget _buildErrorState(TrainingController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: ThemeConfig.errorRed,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryBrown,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ?? "Error memuat data path training",
              style: TextStyle(
                fontSize: 16,
                color: ThemeConfig.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => controller.refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primaryBrown,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("Belum ada materi tersedia"));
  }


  /// BAGIAN UNIT (Header + Zigzag Path)
  Widget _buildUnitSection(UnitModel unit, int unitIndex, int totalUnits) {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildSectionCard(unit),
        _buildUnitHeader(unit),
        _buildZigZagPath(unit),
        if (unitIndex < totalUnits - 1)
          SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildSectionCard(UnitModel unit) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00796B), Color(0xFF004D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF00E5FF), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00695C).withValues(alpha: 0.25),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'BAGIAN 1',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.shield, color: Color(0xFF00E5FF), size: 16),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              unit.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitHeader(UnitModel unit) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Unit ${unit.orderIndex}: ${unit.title}',
            style: TextStyle(
              color: Colors.blueGrey.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// LOGIKA UTAMA ZIGZAG
  Widget _buildZigZagPath(UnitModel unit) {
    // Kita butuh Stack untuk menumpuk: Garis (Belakang) -> Node (Depan)
    // Hitung total tinggi berdasarkan jumlah lesson
    final double totalHeight = unit.lessons.length * _itemSpacing;

    return SizedBox(
      height: totalHeight + 100,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PathPainter(
                itemCount: unit.lessons.length,
                spacing: _itemSpacing,
                amplitude: _amplitude,
                color: const Color(0xFF455A64),
              ),
            ),
          ),

          ...unit.lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;

            final double dx = (math.sin(index * 0.75) * _amplitude) +
                (math.cos(index * 0.35) * 18);
            final double dy = index * _itemSpacing;

            return Positioned(
              top: dy,
              left: 0,
              right: 0,
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Render Lesson Node
                      _buildLessonNode(lesson, index, unit),
                      
                      // Render Mascot/Chest di sebelah kanan/kiri node tertentu
                      // (Opsional, buat variasi)
                      if (index > 0 && index % 3 == 0)
                        Transform.translate(
                          offset: Offset(dx > 0 ? -120 : 120, -60),
                          child: _buildTreasureChest(),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],                                    
      ),
    );
  }

  Widget _buildLessonNode(LessonNode lesson, int index, UnitModel unit) {
    // CRITICAL FIX: Recognize 'active', 'unlocked', and 'completed' as playable states
    // Only 'locked' (or empty) should be considered locked
    final status = lesson.status;
    final isLocked = status == 'locked' || status.isEmpty;
    
    Widget nodeWidget = LessonNodeWidget(
      lesson: lesson,
      unitColor: ThemeConfig.primaryBrown,
      onTap: () {
        if (!isLocked) {
          // CRITICAL FIX: Always use QuizPage.withLevel() for individual levels
          // Level 1 should NOT load all unit questions - it should only load Level 1 questions
          if (lesson.levelId != null) {
            debugPrint('🔍 Opening Level: ${lesson.levelId} (Index: $index, Status: $status)');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizPage.withLevel(levelId: lesson.levelId!),
              ),
            ).then((_) async {
              if (mounted) {
                debugPrint('🔄 [MAP] Returned from QuizPage, refreshing progress and stats...');
                final controller = Provider.of<TrainingController>(context, listen: false);
                // CRITICAL: Wait a bit to ensure navigation is complete
                await Future.delayed(Duration(milliseconds: 200));
                // CRITICAL: Reload progress to ensure UI updates
                try {
                  await controller.loadProgress();
                  debugPrint('✅ [MAP] Progress refreshed after returning from quiz');
                  // CRITICAL: Explicitly refresh user stats to update header
                  await controller.loadUserStats();
                  debugPrint('✅ [MAP] User stats refreshed: XP=${controller.userXp}, Streak=${controller.userStreak}');
                } catch (e) {
                  debugPrint('❌ [MAP] Error refreshing: $e');
                }
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Error: Level ID tidak tersedia. Hubungi administrator."),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Selesaikan level sebelumnya terlebih dahulu!"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );

    return nodeWidget;
  }

  Widget _buildTreasureChest() {
    return Icon(Icons.redeem_rounded, size: 40, color: ThemeConfig.accentKhaki);
  }
}

/// PAINTER KHUSUS UNTUK MENGGAMBAR GARIS KURVA
class _PathPainter extends CustomPainter {
  final int itemCount;
  final double spacing;
  final double amplitude;
  final Color color;

  _PathPainter({
    required this.itemCount,
    required this.spacing,
    required this.amplitude,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount <= 1) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerX = size.width / 2;

    // Mulai dari node pertama
    // Koordinat node pertama:
    double startX = centerX + (math.sin(0) * amplitude);
    double startY = 35; // Offset setengah tinggi node (kira-kira)

    path.moveTo(startX, startY);

    for (int i = 0; i < itemCount - 1; i++) {
      // Titik Awal (Node i)
      double x1 = centerX + (math.sin(i * 0.75) * amplitude);
      double y1 = (i * spacing) + 35;

      // Titik Akhir (Node i+1)
      double x2 = centerX + (math.sin((i + 1) * 0.75) * amplitude);
      double y2 = ((i + 1) * spacing) + 35;

      // Titik Kontrol Bezier (Agar melengkung)
      // Kita ambil titik tengah vertikal, tapi horizontalnya rata-rata
      // Menggambar kurva Bezier Quadric agar halus
      // Trik: Tambahkan sedikit offset curve biar belokannya tajam
      path.quadraticBezierTo(
        x1,
        (y1 + y2) / 2,
        x2,
        y2,
      );
    }

    _drawDashedPath(canvas, path, paint, dashLength: 10, gapLength: 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        final segment = metric.extractPath(
          distance,
          next.clamp(0, metric.length),
        );
        canvas.drawPath(segment, paint);
        distance = next + gapLength;
      }
    }
  }
}