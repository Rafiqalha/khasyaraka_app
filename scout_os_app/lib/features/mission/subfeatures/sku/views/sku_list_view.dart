import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/models/sku_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/views/sku_quiz_page.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        title: Text('POIN ${widget.level.toUpperCase()}'),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
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
                return _CrystalTile(
                  point: point,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SkuQuizPage(pointId: point.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _CrystalTile extends StatelessWidget {
  const _CrystalTile({required this.point, required this.onTap});

  final SkuPointStatusModel point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color crystalColor;
    if (point.isCompleted) {
      crystalColor = const Color(0xFF2E7D32);
    } else if (point.score > 0) {
      crystalColor = const Color(0xFFB71C1C);
    } else {
      crystalColor = const Color(0xFF9E9E9E);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD600), width: 1),
          boxShadow: [
            BoxShadow(
              color: crystalColor.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.hexagon, color: crystalColor, size: 20),
            ),
            Text(
              'Poin ${point.number}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              point.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF3E2723)),
            ),
            const Spacer(),
            Text(
              point.isCompleted
                  ? 'Selesai'
                  : point.score > 0
                      ? 'Ulangi'
                      : 'Belum',
              style: TextStyle(color: crystalColor),
            ),
          ],
        ),
      ),
    );
  }
}
