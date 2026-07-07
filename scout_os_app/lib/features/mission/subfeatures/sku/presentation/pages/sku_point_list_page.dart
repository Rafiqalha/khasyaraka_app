import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/models/sku_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/views/sku_quiz_page.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          '23 SYARAT KECAKAPAN',
          style: GoogleFonts.fredoka(
            color: const Color(0xFF1CB0F6),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(child: GrassSosLoader(color: Color(0xFF1CB0F6)))
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
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
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
        ? const Color(0xFF58CC02)
        : const Color(0xFFE5E5E5);
    final borderColor = isCompleted ? const Color(0xFF58A700) : const Color(0xFFCECECE);
    final textColor = isCompleted ? Colors.white : Colors.grey.shade400;
    final categoryColor = _categoryColor(point.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: borderColor, width: 2),
            left: BorderSide(color: borderColor, width: 2),
            right: BorderSide(color: borderColor, width: 2),
            bottom: BorderSide(color: borderColor, width: 4),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${point.number}',
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isCompleted ? Colors.white : categoryColor, width: 1),
              ),
              child: Text(
                point.category,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: isCompleted ? Colors.white : categoryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                point.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 11, 
                  color: isCompleted ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'intelektual':
        return const Color(0xFFFF9600);
      case 'spiritual':
        return const Color(0xFFCE82FF);
      case 'sosial':
        return const Color(0xFF1CB0F6);
      case 'fisik':
        return const Color(0xFFFF4B4B);
      default:
        return const Color(0xFFFF9600);
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
            style: GoogleFonts.fredoka(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(description, style: GoogleFonts.nunito(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.w600)),
          if (officialRef != null && officialRef.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Referensi: $officialRef',
              style: GoogleFonts.nunito(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: _ready ? 1 : (1 - (_remaining / 10)).clamp(0, 1),
            minHeight: 12,
            backgroundColor: const Color(0xFFE5E5E5),
            color: const Color(0xFF58CC02),
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 8),
          Text(
            _ready ? 'Siap diuji' : 'Uji materi dalam ${_remaining}s',
            style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          DuoButton(
            text: 'UJI MATERI',
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
            variant: _ready ? DuoButtonVariant.green : DuoButtonVariant.outline,
          ),
        ],
      ),
    );
  }
}
