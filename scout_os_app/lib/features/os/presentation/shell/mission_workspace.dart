import 'package:flutter/material.dart';
import '../pages/mission_workspace_page.dart';
import '../../../learning/presentation/pages/notebook_page.dart';
import '../../data/datasources/os_remote_datasource.dart';

// In a real implementation, this configuration would come from the MissionBundle via Provider
class WorkspaceConfig {
  final List<String> requestedPanels;
  WorkspaceConfig(this.requestedPanels);
}

class MissionWorkspace extends StatefulWidget {
  const MissionWorkspace({super.key});

  @override
  State<MissionWorkspace> createState() => _MissionWorkspaceState();
}

class _MissionWorkspaceState extends State<MissionWorkspace> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;

  WorkspaceConfig _config = WorkspaceConfig(['editor', 'terminal']); // fallback

  @override
  void initState() {
    super.initState();
    _startMission();
  }

  Future<void> _startMission() async {
    try {
      final dataSource = OsRemoteDataSource();
      final response = await dataSource.startMission();
      
      if (response['bundle'] != null && response['bundle']['panels'] != null) {
        final List<dynamic> panels = response['bundle']['panels'];
        setState(() {
          _config = WorkspaceConfig(panels.map((e) => e.toString()).toList());
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to start mission: $e";
        _isLoading = false;
      });
    }
  }

  List<Widget> _buildPanels() {
    List<Widget> panels = [];
    for (String panel in _config.requestedPanels) {
      if (panel == 'editor') {
        panels.add(const MissionWorkspacePage());
      } else if (panel == 'notebook') {
        panels.add(const NotebookPage(nodeId: 'dummy-node'));
      } else if (panel == 'reflection') {
        panels.add(const Center(child: Text("Reflection Panel")));
      }
    }
    return panels;
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    List<BottomNavigationBarItem> items = [];
    for (String panel in _config.requestedPanels) {
      if (panel == 'editor') {
        items.add(const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Mission'));
      } else if (panel == 'notebook') {
        items.add(const BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Notebook'));
      } else if (panel == 'reflection') {
        items.add(const BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), activeIcon: Icon(Icons.lightbulb), label: 'Reflection'));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Starting AI Director & Provisioning Workspace..."),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    final pages = _buildPanels();
    final items = _buildNavItems();

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: items,
      ),
    );
  }
}
