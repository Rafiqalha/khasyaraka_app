import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/leaderboard/controllers/leaderboard_controller.dart';
import 'package:scout_os_app/features/leaderboard/models/leaderboard_model.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  // --- COLOR PALETTE (FLAT 3D) ---
  static const _bgLight = Color(0xFFFFFFFF);
  
  // Header Colors
  static const _headerBlue = Color(0xFF1CB0F6);
  static const _headerBlueDark = Color(0xFF1899D6);
  
  // Podium Colors
  static const _gold = Color(0xFFFFC800);
  static const _goldDark = Color(0xFFE5A500);
  static const _silver = Color(0xFFCECECE);
  static const _silverDark = Color(0xFFAFAFAF);
  static const _bronze = Color(0xFFC97B46);
  static const _bronzeDark = Color(0xFF9E5C30);
  
  // List Item Colors
  static const _itemWhite = Colors.white;
  static const _itemBorder = Color(0xFFE5E5E5); // Light grey border
  static const _itemBorderShadow = Color(0xFFD6D6D6); // Darker grey for 3D effect
  
  // Sticky Bar Colors
  static const _scoutGreen = Color(0xFF58CC02);
  static const _scoutGreenDark = Color(0xFF46A302);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeaderboardController>().loadLeaderboard(limit: 50);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Consumer<LeaderboardController>(
        builder: (context, controller, _) {
          // LOADING STATE
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: _scoutGreen),
            );
          }

          // ERROR STATE
          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.error_rounded, color: Colors.amber, size: 64),
                   const SizedBox(height: 16),
                   Text(controller.errorMessage!, textAlign: TextAlign.center),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () => controller.loadLeaderboard(),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: _scoutGreen,
                       foregroundColor: Colors.white,
                     ),
                     child: const Text("Coba Lagi"),
                   )
                ],
              ),
            );
          }

          final topUsers = controller.topUsers;
          final myRank = controller.myRank;

          // Split Top 3 and Rest
          final top3 = topUsers.take(3).toList();
          final restUsers = topUsers.length > 3 ? topUsers.sublist(3) : <LeaderboardUser>[];

          return Stack(
            children: [
              Column(
                children: [
                  // 1. CUSTOM 3D HEADER
                  _build3DHeader(),
                  
                  // 2. SCROLLABLE CONTENT (Podium + List)
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => controller.refresh(),
                      color: _scoutGreen,
                      child: CustomScrollView(
                        slivers: [
                          // PODIUM SECTION
                          if (top3.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 24, bottom: 32),
                              child: _buildPodiumSection(top3),
                            ),
                          ),
                          
                          // LIST SECTION
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120), // Bottom padding for sticky bar
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _build3DListItem(restUsers[index]);
                                },
                                childCount: restUsers.length,
                              ),
                            ),
                          ),
                          
                           // EMPTY STATE
                          if (topUsers.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  "Belum ada data leaderboard.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 3. STICKY "ME" BOTTOM BAR
              if (myRank != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildStickyMeBar(myRank),
                ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _build3DHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24), // SafeArea top padding roughly
      decoration: const BoxDecoration(
        color: _headerBlue,
        border: Border(
          bottom: BorderSide(color: _headerBlueDark, width: 6.0),
        ),
      ),
      child: Column(
        children: [
          Text(
            "PAPAN JUARA",
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Reset dalam 6 hari",
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSection(List<LeaderboardUser> top3) {
    // We expect 1 to 3 users
    LeaderboardUser? rank1 = top3.isNotEmpty ? top3[0] : null;
    LeaderboardUser? rank2 = top3.length > 1 ? top3[1] : null;
    LeaderboardUser? rank3 = top3.length > 2 ? top3[2] : null;

    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // RANK 2 (Left)
          if (rank2 != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildPodiumItem(rank2, 2, 80, 150, _silver, _silverDark),
            ),
          
          // RANK 1 (Center)
          if (rank1 != null)
            _buildPodiumItem(rank1, 1, 110, 190, _gold, _goldDark),
            
          // RANK 3 (Right)
          if (rank3 != null)
             Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildPodiumItem(rank3, 3, 80, 130, _bronze, _bronzeDark),
             ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardUser user, 
    int rank, 
    double avatarSize, 
    double podiumHeight, // Not used strictly directly, but implies scale
    Color mainColor, 
    Color shadowColor
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // AVATAR
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: mainColor,
                shape: BoxShape.circle,
                border: Border.all(color: shadowColor, width: 3),
              ),
              child: _buildAvatar(user, rank == 1 ? avatarSize : avatarSize * 0.9),
            ),
             if (rank == 1)
              Positioned(
                top: -24,
                child: Icon(Icons.emoji_events_rounded, color: _gold, size: 32),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // NAME
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
        
        // XP BADGE
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: mainColor,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              bottom: BorderSide(color: shadowColor, width: 3),
            ),
          ),
          child: Text(
            "${user.xp} XP",
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // PODIUM BOX (Visual anchor)
        Container(
          width: rank == 1 ? 100 : 80,
          height: rank == 1 ? 40 : (rank == 2 ? 30 : 20),
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
             border: Border(
              top: BorderSide(color: mainColor, width: 2),
            ),
          ),
          child: Center(
            child: Text(
              "$rank",
              style: GoogleFonts.fredoka(
                color: shadowColor,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build3DListItem(LeaderboardUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _itemWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _itemBorder, width: 2),
      ),
      // Apply 3D bottom border effect manually via container above it or specific styling
      // Using a container to simulate the bottom border 3D effect:
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18), // Slightly less to fit inside
          border: const Border(
            bottom: BorderSide(color: _itemBorderShadow, width: 4.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // RANK NUMBER
            Text(
              "${user.rank}",
              style: GoogleFonts.fredoka(
                color: Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 16),
            
            // AVATAR
            _buildAvatar(user, 48),
            const SizedBox(width: 16),
            
            // NAME
            Expanded(
              child: Text(
                user.name,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // XP
            Text(
              "${user.xp} XP",
              style: GoogleFonts.fredoka(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyMeBar(MyRank myRank) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: _scoutGreen,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border(
            bottom: BorderSide(color: _scoutGreenDark, width: 6.0),
          ),
        ),
        child: Row(
          children: [
            Text(
              myRank.rank > 0 ? "#${myRank.rank}" : "Unranked",
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: myRank.rank > 0 ? 20 : 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "KAMU",
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              "${myRank.xp} XP",
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(LeaderboardUser user, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEEEEEE),
      ),
      child: ClipOval(
        child: user.avatar != null && user.avatar!.isNotEmpty
            ? Image.network(
                user.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitials(user),
              )
            : _buildInitials(user),
      ),
    );
  }

  Widget _buildInitials(LeaderboardUser user) {
    return Center(
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
        style: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
