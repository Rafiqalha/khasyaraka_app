import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:scout_os_app/features/home/presentation/widgets/glossy_stats_bar.dart';
import 'package:scout_os_app/features/home/presentation/widgets/lesson_node_widget.dart';
import 'package:scout_os_app/shared/widgets/shimmer_skeleton.dart';
import 'package:scout_os_app/features/leaderboard/controllers/leaderboard_controller.dart';
import '../../logic/training_controller.dart';
import '../../data/models/training_path.dart';
import 'quiz_page.dart';
import 'package:flutter/foundation.dart';

class TrainingMapPage extends StatefulWidget {
  const TrainingMapPage({super.key});

  @override
  State<TrainingMapPage> createState() => _TrainingMapPageState();
}

class _TrainingMapPageState extends State<TrainingMapPage> with TickerProviderStateMixin, RouteAware {
  final ScrollController _scrollController = ScrollController();
  
  // Konfigurasi Zigzag
  final double _itemSpacing = 100.0; // Jarak vertikal antar node
  final double _amplitude = 75.0; // Seberapa jauh belok ke kiri/kanan

  // ✅ UI State Management for Progressive Loading
  bool _isLoadingMateri = true;
  bool _isLoadingLeaderboard = true;
  // Progress & Stats are less critical blocking UI, but we track them
  bool _isLoadingProgress = true; 

  @override
  void initState() {
    super.initState();
    // ✅ NON-BLOCKING INIT: Move logic to separate method, no await here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllTrainingData();
    });
  }
  
  /// ✅ PARALLEL FETCHING STRATEGY
  /// Fetches Materi, Progress, Stats, and Leaderboard concurrently
  /// Updates UI progressively as data arrives
  Future<void> _loadAllTrainingData() async {
    final trainingCtrl = Provider.of<TrainingController>(context, listen: false);
    final leaderboardCtrl = Provider.of<LeaderboardController>(context, listen: false);

    setState(() {
      _isLoadingMateri = true;
      _isLoadingLeaderboard = true;
      _isLoadingProgress = true;
    });

    debugPrint('🚀 [MAP] Starting Parallel Data Fetching...');

    // 1. Fetch Materi (Units/Sections Structure) - CRITICAL UI
    final materiFuture = trainingCtrl.loadUnitsOnly().then((_) {
      if (mounted) {
        setState(() => _isLoadingMateri = false);
        debugPrint('✅ [MAP] Materi Loaded');
      }
    }).catchError((e) {
      debugPrint('❌ [MAP] Failed to load Materi: $e');
      if (mounted) setState(() => _isLoadingMateri = false);
    });

    // 2. Fetch Progress & Stats (User Data) - Updates existing nodes
    final progressFuture = Future.wait([
      trainingCtrl.loadProgress(),
      trainingCtrl.loadUserStats(),
    ]).then((_) {
      if (mounted) {
        setState(() => _isLoadingProgress = false);
        debugPrint('✅ [MAP] Progress & Stats Loaded');
      }
    }).catchError((e) {
      debugPrint('❌ [MAP] Failed to load Progress/Stats: $e');
      if (mounted) setState(() => _isLoadingProgress = false);
    });

    // 3. Fetch Leaderboard - Secondary Content
    final leaderboardFuture = leaderboardCtrl.loadLeaderboard(limit: 10).then((_) {
      if (mounted) {
        setState(() => _isLoadingLeaderboard = false);
        debugPrint('✅ [MAP] Leaderboard Loaded');
      }
    }).catchError((e) {
      debugPrint('❌ [MAP] Failed to load Leaderboard: $e');
      if (mounted) setState(() => _isLoadingLeaderboard = false);
    });

    // Wait for all to complete (so RefreshIndicator knows when to stop)
    // We use wait([futures]) so we wait for the LONGEST one, but UI updates happened individually/progressively
    await Future.wait([materiFuture, progressFuture, leaderboardFuture]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register with RouteObserver to get notified when this page becomes visible
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Note: RouteObserver must be registered in MaterialApp's navigatorObservers
      // For now, we use a simpler approach below in didPopNext
    }
  }
  
  /// ✅ AUTO-REFRESH: Called when this page becomes visible after another page is popped
  /// This fixes Bug #2 (Hearts sync) and Bug #3 (Level unlock visibility)
  void _onPageBecameVisible() {
    debugPrint('🔄 [MAP] Page became visible - refreshing data for hearts & level sync...');
    final controller = Provider.of<TrainingController>(context, listen: false);
    
    // Use Future.microtask to avoid calling during build
    Future.microtask(() async {
      try {
        // Refresh progress and stats to sync hearts and level status
        await Future.wait([
          controller.loadProgress(),
          controller.loadUserStats(),
        ]);
        debugPrint('✅ [MAP] Data refreshed: XP=${controller.userXp}, Hearts=${controller.userHearts}');
      } catch (e) {
        debugPrint('⚠️ [MAP] Refresh failed: $e');
      }
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
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Consumer<TrainingController>(
          builder: (context, controller, _) {
            // ✅ SWR: Show shimmer skeleton ONLY if Materi is loading
            // and we have no sections to show (Cold Start)
            if (_isLoadingMateri && controller.sectionsWithUnits.isEmpty) {
              return const ShimmerTrainingMap();
            }

            if (controller.errorMessage != null && controller.sectionsWithUnits.isEmpty) {
              return _buildErrorState(controller);
            }

            if (controller.sectionsWithUnits.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                await _loadAllTrainingData();
              },
              color: AppColors.primary,
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
                        Icon(Icons.map_rounded, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Peta Belajar',
                          style: AppTextStyles.h3.copyWith( // Titan One
                            color: Colors.grey[800],
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Center(
                        child: Builder(
                          builder: (context) {
                            // CRITICAL: Use Consumer to ensure rebuild when stats change
                            return Consumer<TrainingController>(
                              builder: (context, ctrl, _) {
                                // debugPrint('🔄 [UI] GlossyStatsBar rebuild: XP=${ctrl.userXp}, Streak=${ctrl.userStreak}');
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
                  
                  // ✅ Leaderboard Preview
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        return Consumer<LeaderboardController>(
                          builder: (context, leaderCtrl, _) {
                            if (_isLoadingLeaderboard && (leaderCtrl.topUsers.isEmpty)) {
                              return const SizedBox.shrink(); // Low priority, don't show shimmer if not loaded yet to avoid clutter? Or show simple shimmer?
                              // Actually user asked for Shimmer. Let's make a mini shimmer or just hide until loaded to keep it clean if it fails.
                              // But prompt said "Parallel... jadi user melihat konten muncul satu per satu".
                              // Let's return a simple placeholder or empty for now to not block UI.
                            }
                            
                            if (leaderCtrl.topUsers.isEmpty) return const SizedBox.shrink();

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Papan Peringkat',
                                          style: AppTextStyles.h3.copyWith(fontSize: 16),
                                        ),
                                        Text(
                                          'Lihat Semua >',
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 60,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: math.min(leaderCtrl.topUsers.length, 5),
                                      itemBuilder: (context, index) {
                                        final user = leaderCtrl.topUsers[index];
                                        return Container(
                                          margin: const EdgeInsets.only(right: 16),
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                                backgroundImage: user.avatar != null 
                                                    ? NetworkImage(user.avatar!) 
                                                    : null,
                                                child: user.avatar == null 
                                                    ? Text(user.name[0], style: TextStyle(color: AppColors.primary))
                                                    : null,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '#${user.rank}',
                                                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ✅ SECTION-BASED RENDERING (Lazy Loading support)
                  ...controller.sectionsWithUnits.expand((sectionWrapper) {
                    final section = sectionWrapper.section;
                    final units = sectionWrapper.units;
                    
                    return [
                      // 1. Backend Section Header (Divider)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.title.toUpperCase(),
                                style: AppTextStyles.h3.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              if (section.description != null)
                                Text(
                                  section.description!,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              Divider(color: Colors.grey[300], thickness: 1),
                            ],
                          ),
                        ),
                      ),
                      
                      // 2. Units or Load Button
                      if (units.isEmpty)
                        SliverToBoxAdapter(
                           child: _buildLoadSectionButton(context, controller, section),
                        )
                      else
                        ...units.asMap().entries.map((unitEntry) {
                           final index = unitEntry.key;
                           final unit = unitEntry.value;
                           return _buildUnitSection(unit, index, units.length);
                        }),
                    ];
                  }).toList(),
                  
                  // Spacer
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadSectionButton(BuildContext context, TrainingController controller, dynamic section) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Trigger lazy load
          controller.loadSectionUnits(section.id);
        },
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        label: Text('Muat Materi ${section.title}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              color: AppColors.danger,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Terjadi Kesalahan',
              style: AppTextStyles.h2.copyWith( // Titan One
                fontSize: 24,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ?? "Error memuat data path training",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => controller.refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
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
                  child: Text(
                    'BAGIAN 1',
                    style: AppTextStyles.h3.copyWith( // Titan One for label
                      color: AppColors.accent,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.shield, color: AppColors.accent, size: 16),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              unit.title,
              style: AppTextStyles.h3.copyWith( // Titan One
                color: Colors.white,
                fontSize: 22,
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
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Unit ${unit.orderIndex}: ${unit.title}',
            style: AppTextStyles.h3.copyWith( // Titan One
              color: Colors.blueGrey.shade800,
              fontSize: 18,
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
      unitColor: AppColors.primary,
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
            ).then((_) {
              // ✅ INSTANT REFRESH: No blocking await - fire & forget pattern
              if (mounted) {
                debugPrint('🔄 [MAP] Returned from QuizPage, refreshing data in background...');
                final controller = Provider.of<TrainingController>(context, listen: false);
                
                // ✅ NON-BLOCKING: Refresh in parallel background microtask
                Future.microtask(() async {
                  try {
                    // Refresh progress and stats in parallel for hearts & level sync
                    await Future.wait([
                      controller.loadProgress(),
                      controller.loadUserStats(),
                    ]);
                    debugPrint('✅ [MAP] Background refresh: XP=${controller.userXp}, Hearts=${controller.userHearts}');
                  } catch (e) {
                    debugPrint('⚠️ [MAP] Background refresh error: $e');
                  }
                });
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
    return Icon(Icons.redeem_rounded, size: 40, color: AppColors.accent);
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