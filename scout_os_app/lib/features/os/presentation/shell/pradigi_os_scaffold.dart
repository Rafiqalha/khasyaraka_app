import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'package:scout_os_app/features/runtime/presentation/shell/workspace_shell.dart';

import '../../data/models/home_data_model.dart';
import '../providers/os_provider.dart';
import '../pages/explore_page.dart'; 
import '../pages/home_page.dart';
import '../pages/knowledge_graph_page.dart'; 
import '../pages/portfolio_page.dart';
import '../pages/profile_page.dart';

enum SidebarItem {
  home,
  explore,
  knowledgeGraph,
  portfolio,
  profile,
}

class SidebarNotifier extends Notifier<SidebarItem> {
  @override
  SidebarItem build() => SidebarItem.home;

  void select(SidebarItem item) {
    state = item;
  }
}

final activeSidebarItemProvider = NotifierProvider<SidebarNotifier, SidebarItem>(SidebarNotifier.new);

class PradigiOSScaffold extends ConsumerWidget {
  const PradigiOSScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeItem = ref.watch(activeSidebarItemProvider);
    final homeDataAsync = ref.watch(homeDataProvider);
    
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: PradigiColors.surface,
      appBar: isMobile ? AppBar(
        title: Text('Pradigi OS', style: PradigiTypography.h3),
        backgroundColor: PradigiColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: PradigiColors.textPrimary),
      ) : null,
      drawer: isMobile ? _buildDrawer(context, ref, activeItem, homeDataAsync) : null,
      body: Row(
        children: [
          // Sidebar for Desktop/Tablet
          if (isDesktop || isTablet)
            _buildSidebar(context, ref, activeItem, isDesktop, isTablet, homeDataAsync),
            
          // Main Content Area
          Expanded(
            child: _buildContent(activeItem),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SidebarItem activeItem) {
    switch (activeItem) {
      case SidebarItem.home:
        return const HomePage();
      case SidebarItem.explore:
        return const ExplorePage();
      case SidebarItem.knowledgeGraph:
        return const KnowledgeGraphPage();
      case SidebarItem.portfolio:
        return const PortfolioPage();
      case SidebarItem.profile:
        return const ProfilePage();
    }
  }

  Widget _buildSidebar(
    BuildContext context, 
    WidgetRef ref, 
    SidebarItem activeItem, 
    bool isDesktop, 
    bool isTablet,
    AsyncValue<HomeDataModel> homeDataAsync,
  ) {
    final bool isCompact = isTablet;
    final homeData = homeDataAsync.value;
    final activeRuntime = homeData?.activeRuntime;
    final knowledgeUpdates = homeData?.knowledgeUpdateCount ?? 0;

    return Container(
      width: isCompact ? 72 : 250,
      color: PradigiColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          if (!isCompact)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text("Pradigi OS", style: PradigiTypography.h2),
            ),
          _buildSidebarItem(context, ref, activeItem, SidebarItem.home, Icons.home_outlined, Icons.home, "Home", isCompact),
          _buildSidebarItem(context, ref, activeItem, SidebarItem.explore, Icons.explore_outlined, Icons.explore, "Explore", isCompact),
          _buildSidebarItem(
            context, ref, activeItem, SidebarItem.knowledgeGraph, 
            Icons.account_tree_outlined, Icons.account_tree, "Knowledge", isCompact,
            badgeCount: knowledgeUpdates,
          ),
          _buildSidebarItem(context, ref, activeItem, SidebarItem.portfolio, Icons.folder_outlined, Icons.folder, "Portfolio", isCompact),
          _buildSidebarItem(context, ref, activeItem, SidebarItem.profile, Icons.person_outline, Icons.person, "Profile", isCompact),
          
          const Spacer(),

          // ACTIVE RUNTIME SECTION (IDE Cursor-style active project context)
          if (activeRuntime != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: PradigiColors.border),
            ),
            if (!isCompact)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Text(
                  "ACTIVE RUNTIME",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PradigiColors.textSecondary, letterSpacing: 1.2),
                ),
              ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkspaceShell()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                color: PradigiColors.primary.withOpacity(0.08),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: PradigiColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!isCompact) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeRuntime.title,
                              style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.bold, color: PradigiColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              activeRuntime.status,
                              style: const TextStyle(fontSize: 10, color: PradigiColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: PradigiColors.textSecondary),
                    ]
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, SidebarItem activeItem, AsyncValue<HomeDataModel> homeDataAsync) {
    final homeData = homeDataAsync.value;
    final activeRuntime = homeData?.activeRuntime;
    final knowledgeUpdates = homeData?.knowledgeUpdateCount ?? 0;

    return Drawer(
      backgroundColor: PradigiColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text("Pradigi OS", style: PradigiTypography.h2),
          ),
          const SizedBox(height: 32),
          _buildSidebarItem(context, ref, activeItem, SidebarItem.home, Icons.home_outlined, Icons.home, "Home", false, inDrawer: true),
          _buildSidebarItem(context, ref, activeItem, SidebarItem.explore, Icons.explore_outlined, Icons.explore, "Explore", false, inDrawer: true),
          _buildSidebarItem(context, ref, activeItem, SidebarItem.knowledgeGraph, Icons.account_tree_outlined, Icons.account_tree, "Knowledge", false, inDrawer: true, badgeCount: knowledgeUpdates),
          _buildSidebarItem(context, ref, activeItem, SidebarItem.portfolio, Icons.folder_outlined, Icons.folder, "Portfolio", false, inDrawer: true),
          _buildSidebarItem(context, ref, activeItem, SidebarItem.profile, Icons.person_outline, Icons.person, "Profile", false, inDrawer: true),
          
          const Spacer(),
          if (activeRuntime != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: PradigiColors.border),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              leading: const Icon(Icons.play_circle_fill, color: PradigiColors.primary),
              title: Text("Active: ${activeRuntime.title}", style: PradigiTypography.body.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text("Status: ${activeRuntime.status}", style: PradigiTypography.caption),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkspaceShell()),
                );
              },
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, 
    WidgetRef ref, 
    SidebarItem active, 
    SidebarItem item, 
    IconData iconUnselected, 
    IconData iconSelected, 
    String label, 
    bool isCompact, 
    {bool inDrawer = false, int badgeCount = 0}
  ) {
    final isSelected = active == item;
    final color = isSelected ? PradigiColors.textPrimary : PradigiColors.textSecondary;
    
    return InkWell(
      onTap: () {
        ref.read(activeSidebarItemProvider.notifier).select(item);
        if (inDrawer) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? PradigiColors.border.withOpacity(0.4) : Colors.transparent,
          border: isSelected && !isCompact ? const Border(left: BorderSide(color: PradigiColors.textPrimary, width: 3)) : null,
        ),
        child: Row(
          mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(isSelected ? iconSelected : iconUnselected, color: color, size: 22),
            if (!isCompact) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label, 
                  style: TextStyle(
                    color: color, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: PradigiColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$badgeCount",
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ]
          ],
        ),
      ),
    );
  }
}
