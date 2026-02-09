import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import '../../logic/training_controller.dart';
import '../../data/models/training_path.dart';
import '../widgets/top_stats_bar.dart';
import '../widgets/active_unit_header_delegate.dart';
import '../widgets/path_road_painter.dart';
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
  static const double _unitHeaderHeight = 70.0;
  static const double _itemHeight = 130.0;
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
    
    // ✅ REMOVED: loadPathData() called in controller constructor
    // Only reset scroll state, don't duplicate data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetScrollState();
      // context.read<TrainingController>().loadPathData(); // Already called in constructor
    });
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
    
    const double sectionHeaderHeight = 150.0; // Adjusted height for _PartHeader (was 80.0)
    
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
      final isLastUnitInSection = (i + 1 >= units.length) || 
                                   (units[i + 1].sectionId != unit.sectionId);
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Consumer<TrainingController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (controller.units.isEmpty) {
              return const Center(child: Text('No contents available'));
            }

            // Calculate offsets when units change
            if (_unitOffsets.isEmpty || _unitOffsets.length != controller.units.length) {
              _calculateUnitOffsets(controller.units);
            }

            // BOUNDS CHECK: Clamp _activeUnitIndex to valid range
            final safeActiveIndex = _activeUnitIndex.clamp(0, controller.units.length - 1);
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
                  backgroundColor: Colors.white,
                  toolbarHeight: _statsBarHeight,
                  title: const TopStatsBar(),
                  titleSpacing: 0,
                ),
                
                // 2. PINNED Dynamic Unit Header (ALWAYS visible, content changes)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: (() {
                    final sectionNum = _getSectionNumber(activeUnit);
                    final unitNum = activeUnit.orderIndex;
                    debugPrint('🔍 [HEADER] Section=$sectionNum, Unit=$unitNum, Title=${activeUnit.title}');
                    return ActiveUnitHeaderDelegate(
                      unit: activeUnit,
                      sectionIndex: sectionNum,
                      color: unitColor,
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
  List<Widget> _buildUnitContent(TrainingController controller, BuildContext context) {
    List<Widget> slivers = [];
    
    final sections = controller.sectionsWithUnits;
    if (sections.isEmpty) return slivers;

    // Update state for header computation (used by pinned header)
    _sectionOrder = sections.map((s) => s.id).toList();

    debugPrint('🐛 [PATH_DEBUG] Rendering ${sections.length} sections sequentially');

    // Debug: Print structure
    for (int idx = 0; idx < sections.length; idx++) {
      final sec = sections[idx];
      debugPrint('  📦 Section ${sec.section.order}: ${sec.id} (${sec.units.length} units)');
      for (final u in sec.units) {
        debugPrint('    - Unit ${u.orderIndex}: ${u.title}');
      }
    }

    // Calculate global index base for alternating directions
    // This allows zigzag to continue smoothly across sections/headers
    int globalIndexCounter = 0;

    for (int i = 0; i < sections.length; i++) {
        final currentSection = sections[i];
        
        // 1. Render Section Header
        slivers.add(
          SliverToBoxAdapter(
            child: _PartHeader(
              partNumber: currentSection.section.order,
              sectionId: currentSection.id,
              // title: currentSection.title, // Optional: Add title if needed
            ),
          ),
        );

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
                  child: _buildDivider(j, currentSection.units.length),
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

  Widget _buildDivider(int index, int total) {
    final isLast = index >= total - 1;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (_) => _dot()),
          ),
          const SizedBox(height: 16),
          Text(
            isLast ? "Kamu sudah sampai di ujung! 🏕️" : "Lanjut ke unit berikutnya...",
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
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
    // ✅ STRICT: Only UNLOCKED levels can be played
    final status = lesson.status.toUpperCase();
    
    if (status != 'UNLOCKED') {
      final message = status == 'COMPLETED' 
          ? 'Level ini sudah diselesaikan!' 
          : 'Level ini masih terkunci!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (lesson.levelId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPage.withLevel(levelId: lesson.levelId!),
        ),
      ).then((_) {
        // 🔥 SWR: Refresh data when user returns from quiz
        // This handles cases where optimistic UI might be out of sync
        // or just to ensure data consistency with server
        debugPrint('🔄 [NAV] Returning from QuizPage, refreshing path data...');
        context.read<TrainingController>().loadPathData();
      });
    }
  }
}

/// Part Header Widget - Duolingo-style "BAGIAN X" header
class _PartHeader extends StatelessWidget {
  final int partNumber;
  final String sectionId;

  const _PartHeader({
    required this.partNumber,
    required this.sectionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.flag_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BAGIAN $partNumber',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    sectionId.toUpperCase(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
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

  static const double _itemHeight = 130.0;

  const _UnitPathSection({
    required this.lessons,
    required this.unitColor,
    required this.unitIndex,
    required this.onLessonTap,
  });

  /// Direction: even units = right (1.0), odd units = left (-1.0)
  double get direction => unitIndex.isOdd ? -1.0 : 1.0;

  double _getOffsetX(int index) => PathCurveGenerator.getOffset(index, 75.0, direction: direction);

  @override
  Widget build(BuildContext context) {
    final totalHeight = lessons.length * _itemHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // Road with direction applied
          Positioned.fill(
            child: CustomPaint(
              painter: PathRoadPainter(
                itemCount: lessons.length,
                itemHeight: _itemHeight,
                getOffsetX: (i) => PathCurveGenerator.getOffset(i, 75.0),
                color: Colors.grey[300]!,
                strokeWidth: 14.0,
                direction: direction,
              ),
            ),
          ),
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
                  child: _AnimatedLevelButton(
                    lesson: lesson,
                    onTap: () => onLessonTap(lesson),
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

/// Animated level button
class _AnimatedLevelButton extends StatefulWidget {
  final LessonNode lesson;
  final VoidCallback onTap;

  const _AnimatedLevelButton({required this.lesson, required this.onTap});

  @override
  State<_AnimatedLevelButton> createState() => _AnimatedLevelButtonState();
}

class _AnimatedLevelButtonState extends State<_AnimatedLevelButton>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _updatePulse();
  }

  void _updatePulse() {
    final status = widget.lesson.status.toUpperCase();
    final isActive = status == 'UNLOCKED';  // Only pulse for UNLOCKED
    if (isActive) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void didUpdateWidget(_AnimatedLevelButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lesson.status != widget.lesson.status) _updatePulse();
  }

  @override
  void dispose() {
    _tapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ NORMALIZE: Backend sends UPPERCASE (LOCKED, UNLOCKED, COMPLETED)
    final status = widget.lesson.status.toUpperCase();
    final isLocked = status == 'LOCKED' || status.isEmpty;
    final isCompleted = status == 'COMPLETED';
    final isActive = status == 'UNLOCKED';  // Only UNLOCKED is active/clickable

    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) { _tapController.reverse(); widget.onTap(); },
      onTapCancel: () => _tapController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
        builder: (context, _) {
          final scale = _scaleAnimation.value * (isActive ? _pulseAnimation.value : 1.0);
          return Transform.scale(
            scale: scale,
            child: _LevelButton3D(isLocked: isLocked, isCompleted: isCompleted, isActive: isActive),
          );
        },
      ),
    );
  }
}

/// 3D level button visual
class _LevelButton3D extends StatelessWidget {
  final bool isLocked, isCompleted, isActive;
  const _LevelButton3D({required this.isLocked, required this.isCompleted, required this.isActive});

  @override
  Widget build(BuildContext context) {
    Color bodyColor, lipColor, iconColor = Colors.white;
    IconData icon;

    if (isCompleted) {
      bodyColor = const Color(0xFFFFD700);
      lipColor = const Color(0xFFDAA520);
      icon = Icons.check_rounded;
      iconColor = const Color(0xFF8B4513);
    } else if (isLocked) {
      bodyColor = const Color(0xFFE5E5E5);
      lipColor = const Color(0xFFC7C7C7);
      icon = Icons.lock_rounded;
      iconColor = const Color(0xFFAFB6C1);
    } else {
      bodyColor = AppColors.primary;
      lipColor = const Color(0xFF1B5E20);
      icon = Icons.star_rounded;
    }

    const double size = 70.0, lipHeight = 8.0;

    return SizedBox(
      height: size + lipHeight,
      width: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: lipHeight, child: Container(
            height: size, width: size,
            decoration: BoxDecoration(color: lipColor, borderRadius: BorderRadius.circular(size / 2)),
          )),
          Positioned(top: 0, child: Container(
            height: size, width: size,
            decoration: BoxDecoration(
              color: bodyColor,
              borderRadius: BorderRadius.circular(size / 2),
              gradient: isCompleted ? LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [const Color(0xFFFFE066), bodyColor, const Color(0xFFDAA520)],
                stops: const [0.0, 0.5, 1.0],
              ) : null,
            ),
            child: isActive
                ? Stack(alignment: Alignment.center, children: [
                    Container(height: 55, width: 55, decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.35), width: 4),
                    )),
                    Icon(icon, color: iconColor, size: 32),
                  ])
                : Icon(icon, color: iconColor, size: 32),
          )),
          if (isActive) Positioned(top: -12, right: -4, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Text("START", style: AppTextStyles.caption.copyWith(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
          )),
        ],
      ),
    );
  }
}
