import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'mission_preview_page.dart';
import '../providers/os_provider.dart';

class AcademyDomain {
  final String id;
  final String title;
  final IconData icon;
  final List<SpecializationRole> specializations;

  AcademyDomain({
    required this.id,
    required this.title,
    required this.icon,
    required this.specializations,
  });
}

class SpecializationRole {
  final String id;
  final String title;
  final List<String> packFiles;

  SpecializationRole({
    required this.id,
    required this.title,
    required this.packFiles,
  });
}

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  String _searchQuery = "";

  final List<AcademyDomain> _registryData = [
    AcademyDomain(
      id: "cyber_academy",
      title: "Cyber Security Academy",
      icon: Icons.security_outlined,
      specializations: [
        SpecializationRole(
          id: "cyber_analyst",
          title: "Cyber Security Analyst",
          packFiles: [
            "Fundamental Keamanan Siber.pack",
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final registryAsync = ref.watch(osRegistryProvider);
    final activeData = registryAsync.when(
      data: (models) => models.map((m) => AcademyDomain(
        id: m.id,
        title: m.title,
        icon: m.icon,
        specializations: m.specializations.map((s) => SpecializationRole(
          id: s.id,
          title: s.title,
          packFiles: s.packFiles,
        )).toList(),
      )).toList(),
      loading: () => _registryData,
      error: (e, st) => _registryData,
    );

    final filteredDomains = activeData.where((domain) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      if (domain.title.toLowerCase().contains(q)) return true;
      for (var spec in domain.specializations) {
        if (spec.title.toLowerCase().contains(q)) return true;
        for (var pack in spec.packFiles) {
          if (pack.toLowerCase().contains(q)) return true;
        }
      }
      return false;
    }).toList();

    return Container(
      color: PradigiColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              final titleColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Explore Registry", style: PradigiTypography.h1),
                  const SizedBox(height: 4),
                  Text(
                    "Pradigi OS Registry: Academies, Specializations, & Executable Blueprint Packs.",
                    style: PradigiTypography.bodySecondary,
                  ),
                ],
              );

              final countPill = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PradigiColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: PradigiColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder_special_outlined, size: 14, color: PradigiColors.textPrimary),
                    const SizedBox(width: 6),
                    Text(
                      "${_registryData.length} Domains Registered",
                      style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11),
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
                    countPill,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleColumn),
                  const SizedBox(width: 16),
                  countPill,
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Search Registry Bar
          Container(
            decoration: BoxDecoration(
              color: PradigiColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PradigiColors.border),
            ),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: const InputDecoration(
                hintText: "Search OS Registry (e.g. Python, Penetration Tester, Go.pack, Riverpod.pack)...",
                prefixIcon: Icon(Icons.search, color: PradigiColors.textSecondary, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              style: PradigiTypography.body,
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: PradigiColors.border),
          const SizedBox(height: 16),

          // Registry List
          Expanded(
            child: filteredDomains.isEmpty
                ? Center(
                    child: Text(
                      "No matching registry blueprints found.",
                      style: PradigiTypography.bodySecondary,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredDomains.length,
                    itemBuilder: (context, index) {
                      final domain = filteredDomains[index];
                      return _buildAcademyDomainNode(domain);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademyDomainNode(AcademyDomain domain) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: PradigiColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: PradigiColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _searchQuery.isNotEmpty,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PradigiColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: PradigiColors.border),
            ),
            child: Icon(domain.icon, color: PradigiColors.textPrimary, size: 20),
          ),
          title: Text(
            domain.title,
            style: PradigiTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "${domain.specializations.length} Specializations / Roles",
            style: PradigiTypography.caption,
          ),
          children: domain.specializations.map((spec) => _buildSpecializationNode(domain, spec)).toList(),
        ),
      ),
    );
  }

  Widget _buildSpecializationNode(AcademyDomain domain, SpecializationRole spec) {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      elevation: 0,
      color: PradigiColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: PradigiColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _searchQuery.isNotEmpty,
          leading: const Icon(Icons.badge_outlined, color: PradigiColors.textPrimary, size: 18),
          title: Text(
            spec.title,
            style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            "${spec.packFiles.length} Executable Blueprint Packs",
            style: PradigiTypography.caption.copyWith(fontSize: 12),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: spec.packFiles.map((packName) => _buildPackChip(domain, spec, packName)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackChip(AcademyDomain domain, SpecializationRole spec, String packName) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MissionPreviewPage(
              academyId: domain.id,
              academyTitle: domain.title,
              specializationId: spec.id,
              specializationTitle: "${spec.title} ($packName)",
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: PradigiColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: PradigiColors.textPrimary.withOpacity(0.25)),
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
            const SizedBox(width: 6),
            Text(
              packName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrains Mono',
                color: PradigiColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 10, color: PradigiColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
