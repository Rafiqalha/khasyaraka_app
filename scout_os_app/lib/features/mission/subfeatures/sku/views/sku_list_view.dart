import 'package:scout_os_app/core/widgets/terminal_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/models/sku_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/views/sku_quiz_page.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_home_page.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';

class SkuListView extends StatefulWidget {
  const SkuListView({super.key, required this.level});

  final String level;

  @override
  State<SkuListView> createState() => _SkuListViewState();
}

class _SkuListViewState extends State<SkuListView> {
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
    final isBantara = widget.level.toLowerCase() == 'bantara';
    final titleText = isBantara ? 'SCOUT INFILTRATOR' : 'CYBER SENTINEL';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'NODE QUESTS [$titleText]',
          style: GoogleFonts.fredoka(
            color: const Color(0xFF1CB0F6),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(child: TerminalLoading())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.points.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final point = controller.points[index];
                // Every 4th quest is a Versus Quest
                final isVersus = index % 4 == 3;
                
                return _NodeQuestTile(
                  point: point,
                  isVersus: isVersus,
                  onTap: () {
                    if (isVersus) {
                      _showVersusDialog(context, point);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SkuQuizPage(pointId: point.id),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  void _showVersusDialog(BuildContext context, SkuPointStatusModel point) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '[VERSUS QUEST]',
          style: GoogleFonts.fredoka(color: const Color(0xFFFF4B4B), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Node ${point.number}: ${point.title}',
              style: GoogleFonts.nunito(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Misi ini membutuhkan kerja sama tim (Sangga). Anda harus memasuki Arena 5v5 dan meraih 1 kali kemenangan untuk mendapatkan System Approval di Node ini.',
              style: GoogleFonts.nunito(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.nunito(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
          ),
          DuoButton(
            text: 'MASUK ARENA',
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArenaHomePage()),
              );
            },
            variant: DuoButtonVariant.red,
          ),
        ],
      ),
    );
  }
}

class _NodeQuestTile extends StatelessWidget {
  const _NodeQuestTile({required this.point, required this.isVersus, required this.onTap});

  final SkuPointStatusModel point;
  final bool isVersus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color questColor;
    if (point.isCompleted) {
      questColor = const Color(0xFF58CC02); // System Approved (Neon Green)
    } else if (point.score > 0) {
      questColor = const Color(0xFFFF9600); // Partial/Failed (Yellow)
    } else {
      questColor = isVersus ? const Color(0xFFFF4B4B) : const Color(0xFF1CB0F6); // Cyber Red or Cyan
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: point.isCompleted ? const Color(0xFF58CC02).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: point.isCompleted ? questColor : const Color(0xFFE5E5E5), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: questColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isVersus ? 'VERSUS' : 'SOLO',
                    style: GoogleFonts.fredoka(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: questColor,
                    ),
                  ),
                ),
                Icon(
                  point.isCompleted ? Icons.verified : (isVersus ? Icons.sports_esports : Icons.memory),
                  color: questColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'NODE ${point.number}',
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              point.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              point.isCompleted
                  ? 'SYS-APPROVED'
                  : point.score > 0
                  ? 'IN PROGRESS'
                  : 'LOCKED',
              style: GoogleFonts.fredoka(
                color: questColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
