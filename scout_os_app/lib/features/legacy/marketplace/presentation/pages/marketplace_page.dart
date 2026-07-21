import 'package:flutter/material.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Extensions & Academies'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Discover'),
              Tab(text: 'Installed'),
              Tab(text: 'Publishers'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {},
              tooltip: 'Check for Updates',
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Registry Search & Install UI (Like VSCode Extensions)')),
            Center(child: Text('Local Package Manager (Update, Uninstall, Verify)')),
            Center(child: Text('Official & Verified Publishers')),
          ],
        ),
      ),
    );
  }
}
