import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scout_os_app/features/dashboard/presentation/providers/dashboard_view_model.dart';
import 'package:scout_os_app/features/dashboard/data/repositories/user_repository.dart'; // For UserStats model

/// Dashboard Screen (Offline-First Implementation)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Provider locally for this screen (Scoped)
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    // ✅ Trigger Init on First Frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().initDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consume logic
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (viewModel.isBackgroundUpdating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 16, height: 16, child: GrassSosLoader()),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Stats Section
              _buildSectionHeader('User Profile'),
              const SizedBox(height: 8),

              if (viewModel.isLoading && !viewModel.hasData)
                const _ShimmerProfileCard() // 💀 Skeleton
              else if (viewModel.userData != null)
                _UserProfileCard(stats: viewModel.userData!) // 🟢 Real Data
              else
                const _ErrorCard(), // 🔴 Error or Empty

              const SizedBox(height: 24),

              // Placeholder for Missions
              _buildSectionHeader('Active Missions'),
              const SizedBox(height: 8),
              if (viewModel.isLoading && !viewModel.hasData)
                const _ShimmerMissionList()
              else
                _buildMissionPlaceholder(),

              // Placeholder for Leaderboard
              const SizedBox(height: 24),
              _buildSectionHeader('Top Scouts'),
              const SizedBox(height: 8),
              if (viewModel.isLoading && !viewModel.hasData)
                const _ShimmerLeaderboard()
              else
                _buildLeaderboardPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMissionPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.flag),
          SizedBox(width: 8),
          Text("Mission Data Loaded (Mock)"),
        ],
      ),
    );
  }

  Widget _buildLeaderboardPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.leaderboard),
          SizedBox(width: 8),
          Text("Leaderboard Data Loaded (Mock)"),
        ],
      ),
    );
  }
}

// --- WIDGETS ---

class _UserProfileCard extends StatelessWidget {
  final UserStats stats;
  const _UserProfileCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total XP: ${stats.totalXp}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Streak: 🔥 ${stats.streak} Days',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Failed to load data. Tap to retry.',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}

// --- SHIMMER SKELETONS ---

class _ShimmerProfileCard extends StatelessWidget {
  const _ShimmerProfileCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _ShimmerMissionList extends StatelessWidget {
  const _ShimmerMissionList();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            height: 60,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerLeaderboard extends StatelessWidget {
  const _ShimmerLeaderboard();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
