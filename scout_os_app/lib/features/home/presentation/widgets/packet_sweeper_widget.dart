import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:scout_os_app/core/services/quiz_haptic_service.dart';

class PacketSweeperWidget extends StatefulWidget {
  final List<Map<String, dynamic>> packets;
  final bool isChecked;
  final bool isCorrect;
  final Function(List<bool>) onSwipeComplete;

  const PacketSweeperWidget({
    super.key,
    required this.packets,
    required this.isChecked,
    required this.isCorrect,
    required this.onSwipeComplete,
  });

  @override
  State<PacketSweeperWidget> createState() => _PacketSweeperWidgetState();
}

class _PacketSweeperWidgetState extends State<PacketSweeperWidget>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final List<bool> _userDecisions = []; // true = user swiped "safe", false = "malicious"
  double _dragX = 0;
  bool _isDragging = false;
  late AnimationController _cardExitController;
  late AnimationController _pulseController;
  double _exitDirection = 0; // -1 left, +1 right

  @override
  void initState() {
    super.initState();
    _cardExitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cardExitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _allSwiped => _currentIndex >= widget.packets.length;

  void _onSwipe(bool swipedSafe) {
    if (_allSwiped || widget.isChecked) return;
    
    QuizHapticService.correctFeedback();
    
    setState(() {
      _exitDirection = swipedSafe ? 1 : -1;
      _userDecisions.add(swipedSafe);
    });

    _cardExitController.forward().then((_) {
      setState(() {
        _currentIndex++;
        _dragX = 0;
        _isDragging = false;
      });
      _cardExitController.reset();

      if (_allSwiped) {
        widget.onSwipeComplete(_userDecisions);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // Card stack area
        SizedBox(
          height: 350, // Reduced from 380 to avoid overlapping PERIKSA button
          child: _allSwiped ? _buildResultSummary() : _buildCardStack(),
        ),

        const SizedBox(height: 24),

        // Swipe hint labels
        if (!_allSwiped && !widget.isChecked) _buildSwipeHints(),
      ],
    );
  }

  Widget _buildProgress() {
    final total = widget.packets.length;
    final done = _currentIndex;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PAKET DATA ${min(done + 1, total)}/$total',
              style: AppTextStyles.h3.copyWith(
                fontSize: 14,
                color: AppColors.cyberBlue,
                letterSpacing: 1.0,
              ),
            ),
            if (_userDecisions.isNotEmpty)
              Text(
                '${_userDecisions.where((d) {
                  final idx = _userDecisions.indexOf(d);
                  final packet = widget.packets[idx];
                  final isMalicious = packet['is_malicious'] as bool? ?? false;
                  return d == !isMalicious;
                }).length}/${_userDecisions.length} Benar',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? done / total : 0,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyberBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardStack() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background card (next card peek)
        if (_currentIndex + 1 < widget.packets.length)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Transform.scale(
              scale: 0.95,
              child: Opacity(
                opacity: 0.7,
                child: _buildPacketCard(widget.packets[_currentIndex + 1], isBackground: true),
              ),
            ),
          ),

        // Current draggable card
        AnimatedBuilder(
          animation: _cardExitController,
          builder: (context, child) {
            final exitProgress = _cardExitController.value;
            final offsetX = exitProgress > 0
                ? _exitDirection * 400 * exitProgress
                : _dragX;
            final rotation = (offsetX / 400) * 0.15; // Milder rotation
            final opacity = exitProgress > 0 ? 1.0 - exitProgress : 1.0;

            return Opacity(
              opacity: opacity,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(offsetX, 0.0)
                  ..rotateZ(rotation),
                alignment: Alignment.center,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onHorizontalDragStart: (_) {
              setState(() => _isDragging = true);
            },
            onHorizontalDragUpdate: (details) {
              setState(() => _dragX += details.delta.dx);
            },
            onHorizontalDragEnd: (details) {
              if (_dragX.abs() > 100) {
                _onSwipe(_dragX > 0); // right = safe, left = malicious
              } else {
                setState(() {
                  _dragX = 0;
                  _isDragging = false;
                });
              }
            },
            child: _buildDraggableCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableCard() {
    final packet = widget.packets[_currentIndex];
    
    // Calculate overlay color based on drag direction
    Color? overlayColor;
    double overlayOpacity = 0;
    String overlayText = '';
    IconData overlayIcon = Icons.check_circle_rounded;
    
    if (_dragX.abs() > 30) {
      overlayOpacity = min((_dragX.abs() - 30) / 100, 0.6);
      if (_dragX > 0) {
        overlayColor = AppColors.duoSuccess;
        overlayText = 'AMAN';
        overlayIcon = Icons.shield_rounded;
      } else {
        overlayColor = AppColors.alertRed;
        overlayText = 'BAHAYA';
        overlayIcon = Icons.warning_rounded;
      }
    }

    return Stack(
      children: [
        _buildPacketCard(packet, isBackground: false),
        
        // Color overlay
        if (overlayColor != null)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8), // Match lip shadow offset
              decoration: BoxDecoration(
                color: overlayColor.withOpacity(overlayOpacity * 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: overlayColor.withOpacity(overlayOpacity),
                  width: 3,
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: overlayOpacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(overlayIcon, color: overlayColor, size: 64),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: overlayColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: overlayColor),
                        ),
                        child: Text(
                          overlayText,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 24,
                            color: overlayColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPacketCard(Map<String, dynamic> packet, {required bool isBackground}) {
    final protocol = packet['protocol'] as String? ?? 'TCP';
    final source = packet['source'] as String? ?? '???';
    final dest = packet['dest'] as String? ?? '???';
    final method = packet['method'] as String? ?? '';
    final payloadPreview = packet['payload_preview'] as String? ?? '';

    // 3D Lip Configuration
    final faceColor = isBackground ? AppColors.deepCharcoal.withOpacity(0.9) : AppColors.deepCharcoal;
    final lipColor = Colors.black.withOpacity(0.6);
    final borderColor = isBackground ? Colors.transparent : Colors.white.withOpacity(0.1);

    return Container(
      width: double.infinity,
      height: 360,
      decoration: BoxDecoration(
        color: lipColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(bottom: isBackground ? 4 : (_isDragging ? 4 : 8)),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Protocol Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cyberBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cyberBlue.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_rounded, color: AppColors.cyberBlue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    protocol,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.cyberBlue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Connection Details
            _buildDetailPill(Icons.upload_rounded, 'Source', source),
            const SizedBox(height: 12),
            _buildDetailPill(Icons.download_rounded, 'Dest', dest),
            
            if (method.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailPill(Icons.http_rounded, 'Method', method),
            ],

            const Spacer(),

            // Payload Container
            Text(
              'PAYLOAD',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                payloadPreview.isEmpty ? '(Empty)' : payloadPreview,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.duoSuccess,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPill(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.white70),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: Colors.white54),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwipeHints() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left hint
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-4 * _pulseController.value, 0),
                child: Opacity(
                  opacity: _dragX < 0 ? 1.0 : 0.4,
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_rounded, color: AppColors.alertRed, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'BAHAYA',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.alertRed,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Right hint
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(4 * _pulseController.value, 0),
                child: Opacity(
                  opacity: _dragX > 0 ? 1.0 : 0.4,
                  child: Row(
                    children: [
                      Text(
                        'AMAN',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.duoSuccess,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.duoSuccess, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultSummary() {
    int correctCount = 0;
    for (int i = 0; i < widget.packets.length; i++) {
      final isMalicious = widget.packets[i]['is_malicious'] as bool? ?? false;
      if (_userDecisions[i] == !isMalicious) correctCount++;
    }

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Lip equivalent
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.deepCharcoal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.isCorrect 
                      ? AppColors.duoSuccess.withOpacity(0.15)
                      : AppColors.alertRed.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isCorrect ? Icons.verified_rounded : Icons.gpp_bad_rounded,
                  size: 64,
                  color: widget.isCorrect ? AppColors.duoSuccess : AppColors.alertRed,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.isCorrect ? 'Analisis Selesai!' : 'Analisis Gagal',
                style: AppTextStyles.h2.copyWith(
                  color: widget.isCorrect ? AppColors.duoSuccess : AppColors.alertRed,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$correctCount dari ${widget.packets.length} paket dianalisis dengan benar.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
