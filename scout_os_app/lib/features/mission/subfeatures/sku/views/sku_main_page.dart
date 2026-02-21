import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/presentation/pages/sku_point_list_page.dart';

class SkuMainPage extends StatefulWidget {
  const SkuMainPage({super.key});

  @override
  State<SkuMainPage> createState() => _SkuMainPageState();
}

class _SkuMainPageState extends State<SkuMainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkuController>().loadOverview();
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
          'PILIH TINGKATAN',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFFFD600),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: PillarWidget(
                title: 'BANTARA',
                color: const Color(0xFF2E7D32),
                isLocked: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SkuPointListPage(level: 'bantara'),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/tunas_kelapa.png',
                  width: 90,
                  height: 90,
                  color: const Color(0xFFFFD600),
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.spa, color: Color(0xFFFFD600), size: 64),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: PillarWidget(
                title: 'LAKSANA',
                color: const Color(0xFFB71C1C),
                isLocked: !controller.isLaksanaUnlocked,
                onTap: () {
                  if (!controller.isLaksanaUnlocked) {
                    _showLockedDialog(context);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SkuPointListPage(level: 'laksana'),
                    ),
                  );
                },
                child: Icon(Icons.lock, size: 64, color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF3E2723),
        title: const Text(
          'LAKSANA TERKUNCI',
          style: TextStyle(color: Color(0xFFFFD600)),
        ),
        content: const Text(
          'Selesaikan semua poin Bantara untuk membuka Laksana.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Kembali',
              style: TextStyle(color: Color(0xFFFFD600)),
            ),
          ),
        ],
      ),
    );
  }
}

class PillarWidget extends StatelessWidget {
  const PillarWidget({
    super.key,
    required this.title,
    required this.color,
    required this.child,
    required this.onTap,
    required this.isLocked,
  });

  final String title;
  final Color color;
  final Widget child;
  final VoidCallback onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.72;
    final borderColor = const Color(0xFFFFD600);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 4),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: isLocked ? 0.55 : 0.9),
              color,
              color.withValues(alpha: isLocked ? 0.45 : 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.4),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(child: Center(child: child)),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                color: isLocked
                    ? Colors.grey.shade300
                    : const Color(0xFFFFD600),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
