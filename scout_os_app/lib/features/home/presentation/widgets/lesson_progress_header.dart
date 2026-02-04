import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

// PERBAIKAN: Tambahkan 'implements PreferredSizeWidget'
class LessonProgressHeader extends StatelessWidget implements PreferredSizeWidget {
  final int current;
  final int total;
  final VoidCallback onExit;

  const LessonProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.onExit,
  });

  // PERBAIKAN: Definisikan tinggi widget (kToolbarHeight adalah standar tinggi AppBar)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    double progress = total == 0 ? 0 : (current + 1) / total;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textGrey),
        onPressed: onExit,
        tooltip: "Keluar Latihan",
      ),
      title: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 16,
          backgroundColor: Colors.grey.shade300,
          color: AppColors.forestGreen,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}