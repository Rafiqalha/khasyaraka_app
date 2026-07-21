import 'package:scout_os_app/core/widgets/terminal_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scout_os_app/features/dashboard/presentation/providers/dashboard_view_model.dart';
import 'package:scout_os_app/features/dashboard/data/repositories/user_repository.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('DASHBOARD', style: GoogleFonts.fredoka(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: [
          if (viewModel.isBackgroundUpdating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: const SizedBox(width: 24, height: 24, child: TerminalLoading(fontSize: 12)),
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
      style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildMissionPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF58CC02).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF58CC02), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: Color(0xFF58CC02)),
          const SizedBox(width: 12),
          Text("Data Misi (Mock)", style: GoogleFonts.nunito(color: const Color(0xFF58CC02), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9600).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF9600), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.leaderboard, color: Color(0xFFFF9600)),
          const SizedBox(width: 12),
          Text("Data Leaderboard (Mock)", style: GoogleFonts.nunito(color: const Color(0xFFFF9600), fontWeight: FontWeight.bold)),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5E5E5),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF1CB0F6),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total XP: ${stats.totalXp}',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Streak: 🔥 ${stats.streak} Hari',
                style: GoogleFonts.nunito(
                  color: const Color(0xFFFF9600),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
        color: const Color(0xFFFF4B4B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF4B4B), width: 2),
      ),
      child: Text(
        'Gagal memuat data. Ketuk untuk mengulang.',
        style: GoogleFonts.nunito(color: const Color(0xFFFF4B4B), fontWeight: FontWeight.bold),
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
