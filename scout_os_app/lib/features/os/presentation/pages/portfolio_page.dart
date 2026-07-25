import 'package:flutter/material.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PradigiColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Portfolio & Evidence",
            style: PradigiTypography.h1,
          ),
          const SizedBox(height: 8),
          Text(
            "Verified artifacts, project outputs, certificates, and learning history.",
            style: PradigiTypography.bodySecondary,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildSectionHeader("Projects Evidence"),
                _buildPortfolioItem(
                  icon: Icons.code,
                  title: "REST Authentication System",
                  subtitle: "Built with Go, JWT, & PostgreSQL. 100% test coverage.",
                  tag: "VERIFIED",
                ),
                _buildPortfolioItem(
                  icon: Icons.security,
                  title: "Penetration Test Report",
                  subtitle: "Audited demo network topology; identified 3 vulnerabilities.",
                  tag: "COMPLETED",
                ),
                const SizedBox(height: 32),
                _buildSectionHeader("Certificates & Badges"),
                _buildPortfolioItem(
                  icon: Icons.workspace_premium_outlined,
                  title: "Cyber Security Fundamentals",
                  subtitle: "Issued by Pradigi Kernel • June 2026",
                  tag: "CERTIFIED",
                ),
                const SizedBox(height: 32),
                _buildSectionHeader("Export Evidence"),
                _buildPortfolioItem(
                  icon: Icons.picture_as_pdf_outlined,
                  title: "Export Resume PDF",
                  subtitle: "Generate ATS-friendly resume from verified learning evidence",
                  actionText: "Export",
                ),
                _buildPortfolioItem(
                  icon: Icons.table_chart_outlined,
                  title: "Learning Evidence CSV",
                  subtitle: "Download raw event log & capability graph history",
                  actionText: "Download",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PradigiTypography.h3.copyWith(
              color: PradigiColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 32,
            height: 2,
            color: PradigiColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? tag,
    String? actionText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PradigiColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PradigiColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PradigiColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: PradigiColors.border),
                    ),
                    child: Icon(icon, color: PradigiColors.textPrimary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: PradigiTypography.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: PradigiColors.textPrimary,
                                ),
                              ),
                            ),
                            if (tag != null && !isNarrow) ...[
                              const SizedBox(width: 8),
                              _buildPradigiBadge(tag),
                            ],
                          ],
                        ),
                        if (tag != null && isNarrow) ...[
                          const SizedBox(height: 6),
                          _buildPradigiBadge(tag),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: PradigiTypography.caption.copyWith(
                            color: PradigiColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (actionText != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PradigiColors.textPrimary,
                      side: const BorderSide(color: PradigiColors.border, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      actionText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Pradigi Minimalist Slate/Monochrome Badge
  Widget _buildPradigiBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: PradigiColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: PradigiColors.textPrimary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: PradigiColors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: PradigiColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
