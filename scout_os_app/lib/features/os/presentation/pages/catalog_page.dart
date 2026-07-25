import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'package:scout_os_app/features/os/presentation/providers/catalog_provider.dart';
import 'package:scout_os_app/features/os/presentation/providers/os_provider.dart';

import 'mission_preview_page.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academiesAsync = ref.watch(catalogProvider('academies'));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('Catalog', style: PradigiTypography.h2),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Discover'),
              Tab(text: 'My Journey'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            academiesAsync.when(
              data: (academies) => _buildDiscoverTab(context, academies, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
            _buildInstalledTab(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverTab(BuildContext context, List<dynamic> academies, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Domains', style: PradigiTypography.h2),
        const SizedBox(height: 16),
        ...academies.map((academy) => _buildDomainCard(
              academy['title'] ?? 'Unknown',
              academy['description'] ?? '',
              onTap: () {
                // Show Specializations (Packs) for this academy
                _showSpecializations(context, ref, academy['id'], academy['title']);
              },
            )),
      ],
    );
  }

  void _showSpecializations(BuildContext context, WidgetRef ref, String academyId, String academyTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _SpecializationsSheet(academyId: academyId, academyTitle: academyTitle);
      },
    );
  }

  Widget _buildInstalledTab(WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);
    return homeDataAsync.when(
      data: (data) {
        final journey = data.activeJourney;
        if (journey == null || journey.specialization == "No Active Journey") {
          return const Center(child: Text("You haven't started any journey yet.\nGo to Discover to start one.", textAlign: TextAlign.center,));
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildPackCard(
              journey.specialization,
              'Current Mission: ${journey.currentMission}\nBlueprint Version: ${journey.blueprintVersion}',
              installed: true,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildDomainCard(String title, String description, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildPackCard(String title, String description, {bool installed = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: installed ? Colors.grey[300] : Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    installed ? 'Continue' : 'Begin Journey',
                    style: TextStyle(
                      color: installed ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecializationsSheet extends ConsumerWidget {
  final String academyId;
  final String academyTitle;

  const _SpecializationsSheet({required this.academyId, required this.academyTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specsAsync = ref.watch(catalogProvider('academies/$academyId/specializations'));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$academyTitle Packs', style: PradigiTypography.h1),
              const SizedBox(height: 24),
              Expanded(
                child: specsAsync.when(
                  data: (specs) {
                    if (specs.isEmpty) {
                      return const Center(child: Text('No packs available.'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: specs.length,
                      itemBuilder: (context, index) {
                        final spec = specs[index];
                        return _buildPackCard(
                          spec['title'] ?? 'Unknown',
                          spec['description'] ?? '',
                          installed: false,
                          onTap: () {
                            Navigator.pop(context); // Close sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MissionPreviewPage(
                                  academyId: academyId,
                                  academyTitle: academyTitle,
                                  specializationId: spec['id'],
                                  specializationTitle: spec['title'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackCard(String title, String description, {bool installed = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: installed ? Colors.grey[300] : Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    installed ? 'Installed' : 'Explore',
                    style: TextStyle(
                      color: installed ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
