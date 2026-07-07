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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'PILIH KASTA',
          style: GoogleFonts.fredoka(
            color: const Color(0xFF1CB0F6),
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: PillarWidget(
                title: 'SCOUT\nINFILTRATOR',
                color: const Color(0xFF58CC02),
                borderColor: const Color(0xFF58CC02),
                isLocked: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SkuPointListPage(level: 'bantara'),
                    ),
                  );
                },
                child: const Icon(Icons.security, size: 80, color: Color(0xFF58CC02)),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: PillarWidget(
                title: 'CYBER\nSENTINEL',
                color: const Color(0xFFFF4B4B),
                borderColor: const Color(0xFFFF4B4B),
                isLocked: !controller.isLaksanaUnlocked,
                onTap: () {
                  if (!controller.isLaksanaUnlocked) {
                    _showLockedDialog(context, 'Selesaikan semua Node Quest [Scout Infiltrator] untuk membuka Kasta ini.');
                    return;
                  }
                  if (!controller.timeGateEligible) {
                    _showLockedDialog(context, 'Kasta ini memiliki Time Gate 90 Hari.\nKamu baru aktif ${controller.timeGateDaysActive} hari.\nSisa waktu: ${controller.timeGateDaysRemaining} hari lagi.');
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SkuPointListPage(level: 'laksana'),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade400),
                    if (controller.isLaksanaUnlocked && !controller.timeGateEligible) ...[
                      const SizedBox(height: 16),
                      Text(
                        'TIME GATE',
                        style: GoogleFonts.fredoka(color: const Color(0xFFFF9600), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: controller.timeGateDaysActive / 90.0,
                        backgroundColor: const Color(0xFFE5E5E5),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9600)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.timeGateDaysActive}/90 Hari',
                        style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'KASTA TERKUNCI',
          style: GoogleFonts.fredoka(color: const Color(0xFFFF4B4B), fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: GoogleFonts.nunito(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.nunito(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold),
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
    required this.borderColor,
    required this.child,
    required this.onTap,
    required this.isLocked,
  });

  final String title;
  final Color color;
  final Color borderColor;
  final Widget child;
  final VoidCallback onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.72;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isLocked ? const Color(0xFFF7F7F7) : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isLocked ? const Color(0xFFE5E5E5) : borderColor, width: 3),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(child: Center(child: child)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                color: isLocked ? Colors.grey.shade400 : borderColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
