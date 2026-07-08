import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import '../../logic/training_controller.dart';
import '../../data/models/training_path.dart';
import '../widgets/top_stats_bar.dart';
import '../widgets/active_unit_header_delegate.dart';
import '../widgets/path_road_painter.dart';
import 'package:scout_os_app/core/widgets/zoo_3d_circle.dart';
import 'quiz_page.dart';

class TrainingPathPage extends StatefulWidget {
  const TrainingPathPage({super.key});

  @override
  State<TrainingPathPage> createState() => _TrainingPathPageState();
}

class _TrainingPathPageState extends State<TrainingPathPage> {
  final ScrollController _scrollController = ScrollController();

  int _activeUnitIndex = 0;
  List<double> _unitOffsets = [];
  List<String> _sectionOrder = []; // Track section order for header

  static const double _statsBarHeight = 60.0;
  static const double _activeHeaderHeight = 80.0;
  static const double _itemHeight = 110.0;
  static const double _dividerHeight = 100.0;

  /// Compute section number (Bagian) for a unit based on its sectionId
  /// Returns the section.order value (1, 2, 3, etc.)
  int _getSectionNumber(UnitModel unit) {
    // Find the section that contains this unit
    final controller = context.read<TrainingController>();
    for (final sectionWithUnits in controller.sectionsWithUnits) {
      if (sectionWithUnits.id == unit.sectionId) {
        return sectionWithUnits.order; // Use section.order, not list index
      }
    }
    return 1; // Default fallback
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetScrollState();
      _loadData();
    });
  }

  /// Load training data: structure first (critical), then user data in background
  Future<void> _loadData() async {
    final ctrl = context.read<TrainingController>();
    // Phase 1: Structure (shows the map)
    await ctrl.loadUnitsOnly();
    // Phase 2: User data (updates node statuses) — parallel, non-blocking
    try {
      await Future.wait([
        ctrl.loadProgress(),
        ctrl.loadUserStats(),
        // Check for hearts regeneration when page loads
        ctrl.refreshHearts(),
      ]);
    } catch (e) {
      debugPrint('⚠️ [PATH] Background user data failed: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Reset scroll state when data reloads
  void _resetScrollState() {
    _activeUnitIndex = 0;
    _unitOffsets = [];
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _calculateUnitOffsets(List<UnitModel> units) {
    if (units.isEmpty) {
      _unitOffsets = [];
      return;
    }

    _unitOffsets = [];
    double offset = 0;

    // Group units by section to properly calculate offsets including section headers
    final controller = context.read<TrainingController>();
    final sectionsWithUnits = controller.sectionsWithUnits;

    const double sectionHeaderHeight =
        150.0; // Adjusted height for _PartHeader (was 80.0)

    String? currentSectionId;

    for (int i = 0; i < units.length; i++) {
      final unit = units[i];

      // If we're entering a new section, add section header height
      if (unit.sectionId != currentSectionId) {
        offset += sectionHeaderHeight;
        currentSectionId = unit.sectionId;
      }

      // Record offset for this unit
      _unitOffsets.add(offset);

      // Add this unit's content height (lessons + divider)
      offset += (unit.lessons.length * _itemHeight);

      // Add divider height if not last unit in section
      final isLastUnitInSection =
          (i + 1 >= units.length) || (units[i + 1].sectionId != unit.sectionId);
      if (!isLastUnitInSection) {
        offset += _dividerHeight;
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _unitOffsets.isEmpty) return;

    // Account for stats bar and header heights
    final scrollOffset = _scrollController.offset;

    // Find active unit based on scroll position
    int newActiveUnit = 0;
    for (int i = 0; i < _unitOffsets.length; i++) {
      // Use a threshold to determine which unit is "active"
      // Adjust threshold to change when header updates
      if (scrollOffset >= _unitOffsets[i] - 100) {
        newActiveUnit = i;
      }
    }

    if (newActiveUnit != _activeUnitIndex) {
      setState(() {
        _activeUnitIndex = newActiveUnit;
      });
    }
  }

  /// Scroll to a specific section (for "Jump to" feature)
  void _scrollToSection(int sectionIndex) {
    if (!_scrollController.hasClients || _unitOffsets.isEmpty) return;

    // Calculate approximate offset for section
    // This is a simplified version - proper implementation would track section offsets
    final targetOffset = sectionIndex * 800.0; // Approximate section height

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Consumer<TrainingController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: GrassSosLoader(color: AppColors.primary),
              );
            }

            if (controller.units.isEmpty) {
              return const Center(child: Text('No contents available'));
            }

            // Calculate offsets when units change
            if (_unitOffsets.isEmpty ||
                _unitOffsets.length != controller.units.length) {
              _calculateUnitOffsets(controller.units);
            }

            // BOUNDS CHECK: Clamp _activeUnitIndex to valid range
            final safeActiveIndex = _activeUnitIndex.clamp(
              0,
              controller.units.length - 1,
            );
            final activeUnit = controller.units[safeActiveIndex];
            final unitColor = _getUnitColor(safeActiveIndex);

            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // 1. PINNED Stats Bar (ALWAYS visible)
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  snap: false,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  backgroundColor: Theme.of(context).cardColor,
                  toolbarHeight: _statsBarHeight,
                  title: const TopStatsBar(),
                  titleSpacing: 0,
                ),

                // 2. PINNED Dynamic Unit Header (ALWAYS visible, content changes)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: (() {
                    final sectionNum = _getSectionNumber(activeUnit);
                    return ActiveUnitHeaderDelegate(
                      unit: activeUnit,
                      sectionIndex: sectionNum,
                      color: unitColor,
                      height: _activeHeaderHeight,
                    );
                  })(),
                ),

                // 3. Scrollable Unit Content (NO per-unit headers!)
                ..._buildUnitContent(controller, context),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build unit content from backend-driven sections
  /// NO preview cards, NO manual grouping - Just strict sequential list
  List<Widget> _buildUnitContent(
    TrainingController controller,
    BuildContext context,
  ) {
    List<Widget> slivers = [];

    final sections = controller.sectionsWithUnits;
    if (sections.isEmpty) return slivers;

    // Update state for header computation (used by pinned header)
    _sectionOrder = sections.map((s) => s.id).toList();

    debugPrint(
      '🐛 [PATH_DEBUG] Rendering ${sections.length} sections sequentially',
    );

    // Debug: Print structure
    for (int idx = 0; idx < sections.length; idx++) {
      final sec = sections[idx];
      debugPrint(
        '  📦 Section ${sec.section.order}: ${sec.id} (${sec.units.length} units)',
      );
      for (final u in sec.units) {
        debugPrint('    - Unit ${u.orderIndex}: ${u.title}');
      }
    }

    // Calculate global index base for alternating directions
    // This allows zigzag to continue smoothly across sections/headers
    int globalIndexCounter = 0;

    for (int i = 0; i < sections.length; i++) {
      final currentSection = sections[i];

      // 2. Render Units for this section
      for (int j = 0; j < currentSection.units.length; j++) {
        final unit = currentSection.units[j];
        final globalIndex = globalIndexCounter;
        final unitColor = _getUnitColor(globalIndex);

        slivers.add(
          SliverToBoxAdapter(
            child: _UnitPathSection(
              lessons: unit.lessons,
              unitColor: unitColor,
              unitIndex: globalIndex,
              onLessonTap: (lesson) => _handleLessonTap(context, lesson),
            ),
          ),
        );

        // Divider within section
        // Only show divider if it's not the very last unit of the section
        if (j < currentSection.units.length - 1) {
          slivers.add(
            SliverToBoxAdapter(
              child: _buildDivider(j, currentSection.units.length, context),
            ),
          );
        }

        globalIndexCounter++;
      }
    }

    // Bottom padding
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 120)));

    return slivers;
  }

  Widget _buildDivider(int index, int total, BuildContext context) {
    final isLast = index >= total - 1;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (_) => _dot(context)),
          ),
          const SizedBox(height: 16),
          Text(
            isLast
                ? "Kamu sudah sampai di ujung! 🏕️"
                : "Lanjut ke unit berikutnya...",
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getUnitColor(int index) {
    const colors = [
      AppColors.primary,
      Color(0xFF58CC02),
      Color(0xFFCE82FF),
      Color(0xFFFF9600),
      Color(0xFFFF4B4B),
      Color(0xFF2B70C9),
    ];
    return colors[index % colors.length];
  }

  void _handleLessonTap(BuildContext context, LessonNode lesson) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return _LevelActionDialog(
          lesson: lesson,
          onPlay: () {
            Navigator.pop(context); // Close dialog
            _navigateToLevel(lesson);
          },
        );
      },
    );
  }

  void _navigateToLevel(LessonNode lesson) {
    // Determine status again just to be safe, though UI prevents locked play usually
    final status = lesson.status.toUpperCase();
    if (status == 'LOCKED')
      return; // Should not happen via button, but good safety

    if (lesson.levelId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPage.withLevel(levelId: lesson.levelId!),
        ),
      ).then((_) {
        // ✅ Only refresh progress + stats
        if (context.mounted) {
          debugPrint(
            '🔄 [NAV] Returning from QuizPage, refreshing progress + stats...',
          );
          final controller = context.read<TrainingController>();
          Future.microtask(() async {
            try {
              await Future.wait<void>([
                controller.loadProgress(),
                controller.loadUserStats(),
                controller.refreshHearts(),
              ]);
              debugPrint('✅ [NAV] Progress refreshed');
            } catch (e) {
              debugPrint('⚠️ [NAV] Refresh error: $e');
            }
          });
        }
      });
    }
  }
}

/// 3. POP-UP LEVEL ACTION DIALOG (Duolingo Style)
class _LevelActionDialog extends StatelessWidget {
  final LessonNode lesson;
  final VoidCallback onPlay;

  const _LevelActionDialog({required this.lesson, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final status = lesson.status.toUpperCase();
    final isLocked = status == 'LOCKED' || status.isEmpty;
    final isCompleted = status == 'COMPLETED';
    final isActive = status == 'UNLOCKED';

    String title;
    String message;
    String buttonText;
    Color color;
    Widget icon;
    Color iconBgColor;

    if (isCompleted) {
      title = "Level Selesai!";
      message =
          "Kamu sudah menyelesaikannya. Mau latihan lagi untuk memantapkan ingatan?";
      buttonText = "ULANGI LATIHAN";
      color = const Color(0xFFFFC107); // Amber/Gold
      icon = Icon(Icons.check_circle_rounded, size: 40, color: color);
      iconBgColor = const Color(0xFFFFF8E1); // Light Amber
    } else if (isLocked) {
      title = "Level Terkunci";
      message = "Selesaikan level sebelumnya untuk membuka teka-teki ini!";
      buttonText = "KEMBALI";
      color = const Color(0xFF9E9E9E); // Grey
      icon = Icon(Icons.lock_rounded, size: 40, color: color);
      iconBgColor = const Color(0xFFF5F5F5); // Light Grey
    } else {
      // Active / Unlocked
      title = "Mulai Petualangan?";
      message = "Siap untuk mendapatkan XP dan melatih kemampuan kepanduanmu?";
      buttonText = "MULAI";
      color = const Color(0xFF58CC02); // Green
      icon = Image.asset(
        'assets/icons/training/star.png',
        height: 40,
        width: 40,
        color: color,
        colorBlendMode: BlendMode.srcIn,
      );
      iconBgColor = const Color(0xFFE8F5E9); // Light Green
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32), // Uniform padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.h2.copyWith(
                color: Colors.black87,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade600,
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Action Button (3D Style)
            // Use GestureDetector for custom 3D button or standard ElevatedButton with style
            _Dialog3DButton(
              text: buttonText,
              color: color,
              onPressed: isLocked ? () => Navigator.pop(context) : onPlay,
            ),
          ],
        ),
      ),
    );
  }
}

class _Dialog3DButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _Dialog3DButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_Dialog3DButton> createState() => _Dialog3DButtonState();
}

class _Dialog3DButtonState extends State<_Dialog3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double lipHeight = 4.0;

    final HSLColor hsl = HSLColor.fromColor(widget.color);
    final Color lipColor = hsl
        .withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        height: 50,
        width: double.infinity,
        margin: EdgeInsets.only(
          top: _isPressed ? lipHeight : 0,
          bottom: _isPressed ? 0 : lipHeight,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: lipColor,
                    offset: Offset(0, lipHeight),
                    blurRadius: 0,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Part Header Widget - Duolingo-style "BAGIAN X" header
class _PartHeader extends StatelessWidget {
  final int partNumber;
  final String sectionId;

  const _PartHeader({required this.partNumber, required this.sectionId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF58CC02),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF46A302),
                blurRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BAGIAN $partNumber',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    sectionId.toUpperCase(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unit path section with road painter
/// Direction alternates per unit: odd units flip left
class _UnitPathSection extends StatelessWidget {
  final List<LessonNode> lessons;
  final Color unitColor;
  final int unitIndex;
  final void Function(LessonNode) onLessonTap;

  static const double _itemHeight = 110.0;

  const _UnitPathSection({
    required this.lessons,
    required this.unitColor,
    required this.unitIndex,
    required this.onLessonTap,
  });

  /// Direction: even units = right (1.0), odd units = left (-1.0)
  double get direction => unitIndex.isOdd ? -1.0 : 1.0;

  double _getOffsetX(int index) =>
      PathCurveGenerator.getOffset(index, 75.0, direction: direction);

  @override
  Widget build(BuildContext context) {
    final totalHeight = lessons.length * _itemHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // Road with direction applied
          // Road removed (Brutal Redesign)
          // Level buttons with direction applied
          ...lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            final offsetX = _getOffsetX(index);
            final offsetY = (index * _itemHeight) + (_itemHeight / 2) - 39;

            return Positioned(
              top: offsetY,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.translate(
                  offset: Offset(offsetX, 0),
                  child: _LevelNodeWidget(
                    lesson: lesson,
                    onTap: () => onLessonTap(lesson),
                    unitColor: unitColor,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LevelNodeWidget extends StatelessWidget {
  final LessonNode lesson;
  final VoidCallback onTap;
  final Color unitColor;

  const _LevelNodeWidget({
    required this.lesson,
    required this.onTap,
    required this.unitColor,
  });

  @override
  Widget build(BuildContext context) {
    final status = lesson.status.toUpperCase();
    final isLocked = status == 'LOCKED' || status.isEmpty;
    final isCompleted = status == 'COMPLETED';
    final isActive = status == 'UNLOCKED';

    Color faceColor;
    Color iconColor = Colors.white;
    Widget icon;

    if (isCompleted) {
      faceColor = unitColor;
      iconColor = Colors.white;
      icon = Image.asset(
        'assets/icons/training/star.png',
        width: 32,
        height: 32,
        color: iconColor,
        colorBlendMode: BlendMode.srcIn,
      );
    } else if (isLocked) {
      faceColor = const Color(0xFFE0E0E0);
      iconColor = const Color(0xFF757575);
      icon = Image.asset(
        'assets/icons/training/star.png',
        width: 32,
        height: 32,
        color: iconColor,
        colorBlendMode: BlendMode.srcIn,
      );
    } else if (isActive) {
      faceColor = unitColor;
      iconColor = Colors.white;
      icon = Image.asset(
        'assets/icons/training/star.png',
        width: 32,
        height: 32,
      );
    } else {
      faceColor = unitColor;
      icon = Image.asset(
        'assets/icons/training/star.png',
        width: 32,
        height: 32,
      );
    }

    Widget node = Zoo3DCircle(
      size: 72,
      color: faceColor,
      style: Zoo3DCircleStyle.duolingo,
      onPressed: isLocked ? null : onTap,
      child: icon,
    );

    return node;
  }
}
