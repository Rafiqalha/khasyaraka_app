import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/models/sku_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/views/sku_quiz_page.dart';

class SkuPointListPage extends StatefulWidget {
  const SkuPointListPage({super.key, required this.level});

  final String level;

  @override
  State<SkuPointListPage> createState() => _SkuPointListPageState();
}

class _SkuPointListPageState extends State<SkuPointListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkuController>().loadPoints(widget.level);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SkuController>();
    return Scaffold(
      backgroundColor: const Color(0xFF3E2723),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        elevation: 0,
        title: Text(
          '23 SYARAT KECAKAPAN',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFFFD600),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(child: GrassSosLoader(color: Color(0xFFFFD600)))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: controller.points.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final point = controller.points[index];
                  return SkuPointCard(
                    point: point,
                    onTap: () async {
                      await controller.loadPointDetail(point.id);
                      if (!mounted) return;
                      final rootContext = this.context;
                      if (!rootContext.mounted) return;
                      showModalBottomSheet(
                        context: rootContext,
                        backgroundColor: const Color(0xFF3E2723),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => BriefingSheet(pointId: point.id),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class SkuPointCard extends StatelessWidget {
  const SkuPointCard({super.key, required this.point, required this.onTap});

  final SkuPointStatusModel point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = point.isCompleted;
    final baseColor = isCompleted
        ? const Color(0xFF2E7D32)
        : const Color(0xFF4E4E4E);
    final glowColor = isCompleted ? const Color(0xFFFFD600) : Colors.black26;
    final categoryColor = _categoryColor(point.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: isCompleted ? 0.8 : 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFD600), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: isCompleted ? 0.4 : 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${point.number}',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFD600),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: categoryColor, width: 1),
              ),
              child: Text(
                point.category,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              point.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'intelektual':
        return const Color(0xFFFFD600);
      case 'spiritual':
        return const Color(0xFF9C27B0);
      case 'sosial':
        return const Color(0xFF2E7D32);
      case 'fisik':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFFFFD600);
    }
  }
}

class BriefingSheet extends StatefulWidget {
  const BriefingSheet({super.key, required this.pointId});

  final String pointId;

  @override
  State<BriefingSheet> createState() => _BriefingSheetState();
}

class _BriefingSheetState extends State<BriefingSheet> {
  int _remaining = 10;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _remaining -= 1;
        if (_remaining <= 0) {
          _ready = true;
        }
      });
      return !_ready;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SkuController>();
    final detail = controller.selectedPoint;
    final description = detail?.description ?? 'Materi belum tersedia.';
    final officialRef = detail?.officialRef;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail?.title ?? 'Briefing',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFFFD600),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(description, style: GoogleFonts.poppins(color: Colors.white70)),
          if (officialRef != null && officialRef.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Referensi: $officialRef',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _ready ? 1 : (1 - (_remaining / 10)).clamp(0, 1),
            minHeight: 8,
            backgroundColor: Colors.white12,
            color: const Color(0xFFFFD600),
          ),
          const SizedBox(height: 8),
          Text(
            _ready ? 'Siap diuji' : 'Uji materi dalam ${_remaining}s',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _ready
                  ? () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SkuQuizPage(pointId: widget.pointId),
                        ),
                      );
                    }
                  : null,
              child: Text(
                'UJI MATERI',
                style: GoogleFonts.cinzel(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
