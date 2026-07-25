import 'package:flutter/material.dart';

class ConceptCard extends StatelessWidget {
  final String title;
  final String description;
  final double readinessScore;

  const ConceptCard({
    super.key,
    required this.title,
    required this.description,
    required this.readinessScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              _buildReadinessBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
                color: Colors.white70, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessBadge() {
    final color = readinessScore > 80
        ? Colors.green
        : (readinessScore > 50 ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        'Readiness: \${readinessScore.toStringAsFixed(0)}%',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
