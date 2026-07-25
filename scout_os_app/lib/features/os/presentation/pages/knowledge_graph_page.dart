import 'package:flutter/material.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';

enum CapabilityStatus { mastered, active, locked }

class CapabilityNodeData {
  final String title;
  final String category;
  final double confidence;
  final CapabilityStatus status;

  CapabilityNodeData({
    required this.title,
    required this.category,
    required this.confidence,
    required this.status,
  });
}

class KnowledgeGraphPage extends StatelessWidget {
  const KnowledgeGraphPage({super.key});

  @override
  Widget build(BuildContext context) {
    final capabilities = [
      CapabilityNodeData(title: "Python Core", category: "Language", confidence: 0.95, status: CapabilityStatus.mastered),
      CapabilityNodeData(title: "Functions & Scope", category: "Language", confidence: 0.90, status: CapabilityStatus.mastered),
      CapabilityNodeData(title: "Pointer Arithmetic", category: "Memory", confidence: 0.83, status: CapabilityStatus.mastered),
      CapabilityNodeData(title: "Dynamic Allocator", category: "Memory", confidence: 0.65, status: CapabilityStatus.active),
      CapabilityNodeData(title: "Gradient Descent", category: "Optimization", confidence: 0.50, status: CapabilityStatus.active),
      CapabilityNodeData(title: "Vector Operations", category: "Math", confidence: 0.20, status: CapabilityStatus.locked),
      CapabilityNodeData(title: "REST Architecture", category: "Networking", confidence: 0.0, status: CapabilityStatus.locked),
    ];

    return Container(
      color: PradigiColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              final titleColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Knowledge & Capability Graph",
                    style: PradigiTypography.h1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Single Source of Truth for your skill confidence and capability progression.",
                    style: PradigiTypography.bodySecondary,
                  ),
                ],
              );

              final summaryPill = Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: PradigiColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PradigiColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.analytics_outlined, size: 16, color: PradigiColors.textPrimary),
                    const SizedBox(width: 8),
                    Text(
                      "Overall Confidence: 0.81",
                      style: PradigiTypography.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PradigiColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleColumn,
                    const SizedBox(height: 12),
                    summaryPill,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleColumn),
                  const SizedBox(width: 16),
                  summaryPill,
                ],
              );
            },
          ),
          
          const SizedBox(height: 28),
          const Divider(color: PradigiColors.border),
          const SizedBox(height: 24),

          // Dependency Pipeline Visualizer
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CAPABILITY DEPENDENCY FLOW",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (int i = 0; i < capabilities.length; i++) ...[
                          _buildCapabilityNodeCard(capabilities[i]),
                          if (i < capabilities.length - 1) _buildFlowConnector(capabilities[i].status),
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                  Text(
                    "ALL CAPABILITIES",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Detailed Capability Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 700;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : 1,
                          mainAxisExtent: 104,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: capabilities.length,
                        itemBuilder: (context, index) {
                          return _buildCapabilityGridTile(capabilities[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityNodeCard(CapabilityNodeData item) {
    bool isMastered = item.status == CapabilityStatus.mastered;
    bool isActive = item.status == CapabilityStatus.active;

    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMastered ? PradigiColors.textPrimary : PradigiColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? PradigiColors.textPrimary : PradigiColors.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isMastered ? Colors.white70 : PradigiColors.textSecondary,
                ),
              ),
              _buildStatusIcon(item.status, isMastered),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isMastered ? Colors.white : PradigiColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Confidence Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: item.confidence,
                    minHeight: 4,
                    backgroundColor: isMastered ? Colors.white24 : PradigiColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isMastered ? Colors.white : PradigiColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${(item.confidence * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isMastered ? Colors.white70 : PradigiColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowConnector(CapabilityStatus currentStatus) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 1.5,
            color: currentStatus == CapabilityStatus.mastered 
                ? PradigiColors.textPrimary 
                : PradigiColors.border,
          ),
          Icon(
            Icons.chevron_right,
            size: 14,
            color: currentStatus == CapabilityStatus.mastered 
                ? PradigiColors.textPrimary 
                : PradigiColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityGridTile(CapabilityNodeData item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PradigiColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PradigiColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PradigiColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: PradigiColors.border),
            ),
            child: _buildStatusIcon(item.status, false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: PradigiTypography.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${item.category} • Confidence: ${item.confidence}",
                  style: PradigiTypography.caption,
                ),
              ],
            ),
          ),
          _buildBadge(item.status),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(CapabilityStatus status, bool isInverse) {
    Color iconColor = isInverse ? Colors.white : PradigiColors.textPrimary;
    switch (status) {
      case CapabilityStatus.mastered:
        return Icon(Icons.check_circle_outline, size: 16, color: iconColor);
      case CapabilityStatus.active:
        return Icon(Icons.radio_button_checked, size: 16, color: iconColor);
      case CapabilityStatus.locked:
        return Icon(Icons.lock_outline, size: 16, color: isInverse ? Colors.white38 : PradigiColors.textSecondary);
    }
  }

  Widget _buildBadge(CapabilityStatus status) {
    String text;
    switch (status) {
      case CapabilityStatus.mastered:
        text = "MASTERED";
        break;
      case CapabilityStatus.active:
        text = "ACTIVE";
        break;
      case CapabilityStatus.locked:
        text = "LOCKED";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status == CapabilityStatus.mastered 
            ? PradigiColors.textPrimary 
            : PradigiColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: PradigiColors.textPrimary.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: status == CapabilityStatus.mastered 
              ? Colors.white 
              : PradigiColors.textPrimary,
        ),
      ),
    );
  }
}
