import 'package:flutter/material.dart';

class PassportPage extends StatelessWidget {
  const PassportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skill Passport'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Competencies'),
              Tab(text: 'Credentials'),
              Tab(text: 'Projects'),
              Tab(text: 'Timeline'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Competency Graph Viewer (DAG)')),
            Center(child: Text('Verified Credentials List')),
            Center(child: Text('Mission Artifacts & Repositories')),
            Center(child: Text('Learning Journey Timeline')),
          ],
        ),
      ),
    );
  }
}
