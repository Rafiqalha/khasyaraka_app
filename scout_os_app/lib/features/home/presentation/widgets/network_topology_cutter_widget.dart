import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:scout_os_app/core/services/quiz_haptic_service.dart';

class NetworkTopologyCutterWidget extends StatefulWidget {
  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> edges;
  final int targetCount; // how many malicious edges to cut
  final bool isChecked;
  final bool isCorrect;
  final Function(Set<int>) onEdgesCut;

  const NetworkTopologyCutterWidget({
    super.key,
    required this.nodes,
    required this.edges,
    required this.targetCount,
    required this.isChecked,
    required this.isCorrect,
    required this.onEdgesCut,
  });

  @override
  State<NetworkTopologyCutterWidget> createState() =>
      _NetworkTopologyCutterWidgetState();
}

class _NetworkTopologyCutterWidgetState
    extends State<NetworkTopologyCutterWidget> with TickerProviderStateMixin {
  final Set<int> _cutEdges = {};
  late AnimationController _sparkController;
  late AnimationController _flowController;
  int? _lastCutEdge;

  @override
  void initState() {
    super.initState();
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  void _onEdgeTap(int edgeIndex) {
    if (widget.isChecked) return;
    
    QuizHapticService.selectionFeedback();

    setState(() {
      if (_cutEdges.contains(edgeIndex)) {
        _cutEdges.remove(edgeIndex); // toggle off
      } else {
        _cutEdges.add(edgeIndex);
        _lastCutEdge = edgeIndex;
        _sparkController.forward(from: 0);
      }
    });

    widget.onEdgesCut(_cutEdges);
  }

  Map<String, Offset> _getNodePositions(Size canvasSize) {
    final positions = <String, Offset>{};
    for (final node in widget.nodes) {
      final id = node['id'] as String;
      final x = (node['x'] as num).toDouble();
      final y = (node['y'] as num).toDouble();
      positions[id] = Offset(
        x * canvasSize.width,
        y * canvasSize.height,
      );
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopologyCanvas(),
        const SizedBox(height: 16),
        _buildCounter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.alertRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.content_cut_rounded, color: AppColors.alertRed, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Potong Kabel Anomali',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopologyCanvas() {
    return Container(
      height: 350, // Adjusted to prevent overlap with button
      decoration: BoxDecoration(
        color: AppColors.deepCharcoal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canvasSize = Size(constraints.maxWidth, 350);
          final nodePositions = _getNodePositions(canvasSize);

          return Stack(
            children: [
              // Pattern background
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: Container(color: AppColors.deepCharcoal),
                ),
              ),

              // Edges (cables)
              AnimatedBuilder(
                animation: _flowController,
                builder: (context, _) {
                  return CustomPaint(
                    size: canvasSize,
                    painter: _EdgePainter(
                      edges: widget.edges,
                      nodePositions: nodePositions,
                      cutEdges: _cutEdges,
                      isChecked: widget.isChecked,
                      flowProgress: _flowController.value,
                    ),
                  );
                },
              ),

              // Edge tap targets
              ...widget.edges.asMap().entries.map((entry) {
                final idx = entry.key;
                final edge = entry.value;
                final fromId = edge['from'] as String;
                final toId = edge['to'] as String;
                final from = nodePositions[fromId];
                final to = nodePositions[toId];
                if (from == null || to == null) return const SizedBox();

                final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
                const hitSize = 48.0;

                return Positioned(
                  left: mid.dx - hitSize / 2,
                  top: mid.dy - hitSize / 2,
                  child: GestureDetector(
                    onTap: () => _onEdgeTap(idx),
                    child: Container(
                      width: hitSize,
                      height: hitSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _cutEdges.contains(idx)
                            ? AppColors.alertRed.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: _cutEdges.contains(idx)
                          ? const Icon(
                              Icons.close_rounded,
                              color: AppColors.alertRed,
                              size: 24,
                            )
                          : null,
                    ),
                  ),
                );
              }),

              // Spark animation
              if (_lastCutEdge != null)
                AnimatedBuilder(
                  animation: _sparkController,
                  builder: (context, _) {
                    final edge = widget.edges[_lastCutEdge!];
                    final from = nodePositions[edge['from'] as String];
                    final to = nodePositions[edge['to'] as String];
                    if (from == null || to == null) return const SizedBox();

                    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
                    final progress = _sparkController.value;
                    final size = 30 + progress * 30;
                    final opacity = 1.0 - progress;

                    return Positioned(
                      left: mid.dx - size / 2,
                      top: mid.dy - size / 2,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.alertRed.withOpacity(0.5),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Nodes
              ...widget.nodes.map((node) {
                final id = node['id'] as String;
                final pos = nodePositions[id]!;
                final type = node['type'] as String? ?? 'server';
                final isCompromised = node['is_compromised'] as bool? ?? false;

                IconData icon;
                Color baseColor;
                switch (type) {
                  case 'server':
                    icon = Icons.dns_rounded;
                    baseColor = isCompromised ? AppColors.alertRed : AppColors.cyberBlue;
                    break;
                  case 'db':
                    icon = Icons.storage_rounded;
                    baseColor = isCompromised ? AppColors.alertRed : Colors.orange;
                    break;
                  case 'client':
                    icon = Icons.computer_rounded;
                    baseColor = isCompromised ? AppColors.alertRed : AppColors.duoSuccess;
                    break;
                  default:
                    icon = Icons.device_unknown_rounded;
                    baseColor = Colors.white54;
                }

                return Positioned(
                  left: pos.dx - 24,
                  top: pos.dy - 24,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: baseColor.withOpacity(0.2),
                      border: Border.all(
                        color: baseColor.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        if (isCompromised)
                          BoxShadow(
                            color: AppColors.alertRed.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: baseColor,
                      ),
                      child: Center(
                        child: Icon(icon, size: 22, color: Colors.white),
                      ),
                    ),
                  ),
                );
              }),

              // Labels
              ...widget.nodes.map((node) {
                final id = node['id'] as String;
                final pos = nodePositions[id]!;
                final label = node['label'] as String? ?? id;

                return Positioned(
                  left: pos.dx - 40,
                  top: pos.dy + 28,
                  child: SizedBox(
                    width: 80,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCounter() {
    final remaining = widget.targetCount - _cutEdges.length;
    final isDone = remaining <= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: isDone 
                  ? AppColors.duoSuccess.withOpacity(0.15)
                  : AppColors.alertRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDone 
                    ? AppColors.duoSuccess.withOpacity(0.5)
                    : AppColors.alertRed.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isDone ? Icons.verified_rounded : Icons.content_cut_rounded,
                  color: isDone ? AppColors.duoSuccess : AppColors.alertRed,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDone ? 'Kabel Berhasil Dipotong!' : 'Kabel Tersisa:',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isDone)
                        Text(
                          '$remaining koneksi',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.alertRed,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EdgePainter extends CustomPainter {
  final List<Map<String, dynamic>> edges;
  final Map<String, Offset> nodePositions;
  final Set<int> cutEdges;
  final bool isChecked;
  final double flowProgress;

  _EdgePainter({
    required this.edges,
    required this.nodePositions,
    required this.cutEdges,
    required this.isChecked,
    required this.flowProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < edges.length; i++) {
      final edge = edges[i];
      final fromId = edge['from'] as String;
      final toId = edge['to'] as String;
      final isMalicious = edge['is_malicious'] as bool? ?? false;
      final isCut = cutEdges.contains(i);

      final from = nodePositions[fromId];
      final to = nodePositions[toId];
      if (from == null || to == null) continue;

      Color lineColor = Colors.white24;
      double strokeWidth = 3.0;

      if (isChecked) {
        if (isCut) {
          lineColor = isMalicious
              ? AppColors.duoSuccess.withOpacity(0.5) // Correct cut
              : AppColors.alertRed.withOpacity(0.5); // Wrong cut
        } else {
          lineColor = isMalicious
              ? AppColors.alertRed.withOpacity(0.8) // Missed cut
              : Colors.white24; // Correctly left intact
        }
      } else {
        if (isCut) {
          lineColor = AppColors.alertRed.withOpacity(0.5);
        } else {
          lineColor = isMalicious ? AppColors.alertRed.withOpacity(0.4) : Colors.white24;
        }
      }

      final paint = Paint()
        ..color = lineColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (isCut) {
        // Draw dashed/broken line
        _drawBrokenLine(canvas, from, to, paint);
      } else {
        // Draw solid line
        canvas.drawLine(from, to, paint);

        // Draw animated data flow
        if (!isChecked && isMalicious) {
          _drawFlow(canvas, from, to);
        }
      }
    }
  }

  void _drawBrokenLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final dist = sqrt(dx * dx + dy * dy);
    
    // Gap in the middle
    final gapSize = 30.0;
    
    if (dist <= gapSize) return;

    final ratio = (dist - gapSize) / 2 / dist;
    final mid1 = Offset(p1.dx + dx * ratio, p1.dy + dy * ratio);
    final mid2 = Offset(p2.dx - dx * ratio, p2.dy - dy * ratio);

    canvas.drawLine(p1, mid1, paint);
    canvas.drawLine(mid2, p2, paint);

    // Draw little cut marks (X)
    final midX = (p1.dx + p2.dx) / 2;
    final midY = (p1.dy + p2.dy) / 2;
    final crossPaint = Paint()
      ..color = AppColors.alertRed.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(midX - 4, midY - 4), Offset(midX + 4, midY + 4), crossPaint);
    canvas.drawLine(Offset(midX - 4, midY + 4), Offset(midX + 4, midY - 4), crossPaint);
  }

  void _drawFlow(Canvas canvas, Offset p1, Offset p2) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    
    // Multiple flowing dots
    for (int j = 0; j < 3; j++) {
      final t = (flowProgress + (j / 3)) % 1.0;
      final dotPos = Offset(p1.dx + dx * t, p1.dy + dy * t);
      
      final dotPaint = Paint()
        ..color = AppColors.alertRed.withOpacity(0.8)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(dotPos, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter oldDelegate) {
    return oldDelegate.flowProgress != flowProgress ||
        oldDelegate.cutEdges != cutEdges ||
        oldDelegate.isChecked != isChecked;
  }
}
