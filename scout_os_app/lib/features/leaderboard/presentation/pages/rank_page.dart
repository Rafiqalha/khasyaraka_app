  import 'dart:convert';
  import 'package:scout_os_app/core/widgets/skeleton_loader.dart';

/// Rank Page — Real-time leaderboard powered by Redis Sorted Sets
///
/// **Architecture:**
/// - Backend: Redis ZSET for O(log N + M) ranking queries
/// - Transport: HTTP polling every 10s via /leaderboard (battery-friendly)
/// - Fallback: PostgreSQL if Redis is unavailable
/// - Pub/Sub: Redis channel 'leaderboard:updates' for SSE streaming
///
/// **Big O Complexity (per refresh):**
/// - ZREVRANGE: O(log N + M) — N=total users, M=limit
/// - ZSCORE:   O(1) — current user score
/// - ZREVRANK: O(log N) — current user rank
/// - MGET:     O(K) — K=profile cache keys
/// - Total:    O(log N + M + K) — sublinear in total users

import 'package:flutter/material.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scout_os_app/features/leaderboard/controllers/leaderboard_controller.dart';
import 'package:scout_os_app/features/leaderboard/models/leaderboard_model.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/features/profile/data/repositories/profile_repository.dart';
import 'package:scout_os_app/features/profile/models/public_profile_model.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage>
    with SingleTickerProviderStateMixin {
  // --- COLOR PALETTE (FLAT 3D) ---
  static const _bgLight = Color(0xFFFFFFFF);

  // Header Colors (Golden Theme)
  static const _headerGold = Color(0xFFFFC800);
  static const _headerGoldDark = Color(0xFFE5A500);

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
  static const _itemBorderShadow = Color(
    0xFFD6D6D6,
  ); // Darker grey for 3D effect

  // Sticky Bar Colors
  static const _scoutGreen = Color(0xFF58CC02);
  static const _scoutGreenDark = Color(0xFF46A302);

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeaderboardController>().loadLeaderboard(limit: 50);
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Papan Juara',
          style: GoogleFonts.fredoka(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<LeaderboardController>(
        builder: (context, controller, _) {
          // LOADING STATE
          if (controller.isLoading) {
            return _buildShimmerLoading();
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
                  ),
                ],
              ),
            );
          }

          final topUsers = controller.topUsers;
          final myRank = controller.myRank;

          // Split Top 3 and Rest
          final top3 = topUsers.take(3).toList();
          final restUsers = topUsers.length > 3
              ? topUsers.sublist(3)
              : <LeaderboardUser>[];

          return Stack(
            children: [
              Column(
                children: [
                  // SELECTORS AT THE TOP (FIXED)
                  _buildSelectors(controller),
                  
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
                                padding: const EdgeInsets.only(
                                  top: 24,
                                  bottom: 32,
                                ),
                                child: _buildPodiumSection(top3, controller.activeCategory),
                              ),
                            ),

                          // LIST SECTION
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              120,
                            ), // Bottom padding for sticky bar
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return _build3DListItem(restUsers[index], controller.activeCategory);
                              }, childCount: restUsers.length),
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
                  child: _buildStickyMeBar(myRank, controller.activeCategory),
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


  // ---------------------------------------------------------------------------
  // HELPER METHODS
  // ---------------------------------------------------------------------------

  Widget _buildSelectors(LeaderboardController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          // MODE SELECTOR (Normal vs Ranked) - Sembunyikan sementara
          // _buildCategoryToggle(controller),
          // const SizedBox(height: 12),
          // SCOPE SELECTOR
          _buildScopeToggle(controller),
        ],
      ),
    );
  }

  Widget _buildCategoryToggle(LeaderboardController controller) {
    final categories = [
      {'key': 'quiz', 'label': 'Normal Mode', 'icon': Icons.menu_book_rounded},
      {'key': 'rank', 'label': 'Ranked Mode', 'icon': Icons.security_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: _itemBorder,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: categories.map((cat) {
          final isSelected = controller.activeCategory == cat['key'] || 
              (controller.activeCategory == '' && cat['key'] == 'rank');
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (controller.activeCategory != cat['key']) {
                  controller.loadLeaderboard(category: cat['key'] as String);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected ? _scoutGreenDark : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['label'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: isSelected ? _scoutGreenDark : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScopeToggle(LeaderboardController controller) {
    final scopes = [
      {'key': 'kecamatan', 'label': 'Kec'},
      {'key': 'kota', 'label': 'Kota'},
      {'key': 'provinsi', 'label': 'Prov'},
      {'key': 'nasional', 'label': 'Nasional'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: _itemBorder,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: scopes.map((scope) {
          final isSelected = controller.activeScope == scope['key'] || 
              (controller.activeScope == 'global' && scope['key'] == 'nasional');
          return Expanded(
            child: GestureDetector(
              onTap: () {
                final newScope = scope['key'] == 'nasional' ? 'global' : scope['key']!;
                if (controller.activeScope != newScope) {
                  controller.loadLeaderboard(scope: newScope, category: controller.activeCategory);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  scope['label']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: isSelected ? _scoutGreenDark : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 32, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _buildShimmerPodium(160)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildShimmerPodium(200)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildShimmerPodium(130)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      childCount: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerPodium(double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 12,
          color: Colors.white,
        ),
        const SizedBox(height: 12),
        Container(
          height: height,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    return const Color(0xFF58CC02); // Scout Green
  }

  Color _getLevelShadowColor(String level) {
    return const Color(0xFF46A302); // Dark Green for 3D lip
  }

  Widget _buildPodiumSection(List<LeaderboardUser> top3, String category) {
    // We expect 1 to 3 users
    LeaderboardUser? rank1 = top3.isNotEmpty ? top3[0] : null;
    LeaderboardUser? rank2 = top3.length > 1 ? top3[1] : null;
    LeaderboardUser? rank3 = top3.length > 2 ? top3[2] : null;

    return Container(
      height: 360, // Increased height to prevent overflow (Rank 1 needs ~340px)
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // RANK 2 (Left)
          if (rank2 != null)
            Expanded(
              child: _buildPodiumItem(
                user: rank2,
                rank: 2,
                height: 160,
                color: _getLevelColor(rank2.level),
                shadowColor: _getLevelShadowColor(rank2.level),
                category: category,
              ),
            ),

          const SizedBox(width: 8),

          // RANK 1 (Center) - Tallest
          if (rank1 != null)
            Expanded(
              child: _buildPodiumItem(
                user: rank1,
                rank: 1,
                height: 200,
                color: _getLevelColor(rank1.level),
                shadowColor: _getLevelShadowColor(rank1.level),
                isCenter: true,
                category: category,
              ),
            ),

          const SizedBox(width: 8),

          // RANK 3 (Right)
          if (rank3 != null)
            Expanded(
              child: _buildPodiumItem(
                user: rank3,
                rank: 3,
                height: 130,
                color: _getLevelColor(rank3.level),
                shadowColor: _getLevelShadowColor(rank3.level),
                category: category,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required LeaderboardUser user,
    required int rank,
    required double height,
    required Color color,
    required Color shadowColor,
    bool isCenter = false,
    required String category,
  }) {
    bool isNormalMode = true; // HIDE RANK MODE: category == 'quiz';

    return GestureDetector(
      onTap: () => _showPublicProfileSheet(context, user.id),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // AVATAR & NAME
          Column(
            children: [
              // Avatar with animated glowing flat golden border
              AnimatedGlowingAvatar(
                avatar: _buildAvatar(user, isCenter ? 70 : 55),
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),

              // Rank & Stars Pill
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: isNormalMode
                    ? Text(
                        "${user.xp} XP",
                        style: GoogleFonts.fredoka(
                          color: Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${user.rankInfo.rankName} ${user.rankInfo.subTier}",
                            style: GoogleFonts.fredoka(
                              color: Colors.grey[700],
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${user.rankInfo.stars}/${user.rankInfo.maxStars}",
                                style: GoogleFonts.nunito(
                                  color: Colors.amber[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // PODIUM BOX (Flat 3D)
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: shadowColor, // Shadow/Lip Color
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 6), // Lip thickness
            child: Container(
              decoration: BoxDecoration(
                color: color, // Main green face
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$rank",
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (rank == 1)
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DListItem(LeaderboardUser user, String category) {
    bool isNormalMode = true; // HIDE RANK MODE: category == 'quiz';
    final levelColor = _getLevelColor(user.level);
    final levelShadow = _getLevelShadowColor(user.level);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      // FLAT 3D CONSTRUCTION: Shadow Container -> Face Container
      child: Container(
        decoration: BoxDecoration(
          color: levelShadow, // The "3D" depth color (Darker shade)
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.only(bottom: 4), // The depth thickness
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showPublicProfileSheet(context, user.id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: levelColor, // Green face
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // RANK NUMBER
                  SizedBox(
                    width: 30,
                    child: Text(
                      "${user.rank}",
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // AVATAR
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _buildAvatar(user, 48),
                  ),
                  const SizedBox(width: 16),

                  // NAME & LEVEL / XP
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isNormalMode)
                          Text(
                            "${user.rankInfo.rankName} ${user.rankInfo.subTier}",
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(
                                0.9,
                              ), // Slightly transparent white
                            ),
                          ),
                      ],
                    ),
                  ),

                  // STARS OR XP
                  if (isNormalMode)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${user.xp} XP",
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.2,
                        ), // Semi-transparent pill
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${user.rankInfo.stars}/${user.rankInfo.maxStars}",
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickyMeBar(MyRank myRank, String category) {
    bool isNormalMode = true; // HIDE RANK MODE: category == 'quiz';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _scoutGreenDark, // 3D lip
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(bottom: 4), // 3D depth
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: _scoutGreen, // Green face
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          children: [
            if (!isNormalMode)
              Text(
                myRank.rank > 0 ? "#${myRank.rank}" : "Unranked",
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontSize: myRank.rank > 0 ? 20 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            if (!isNormalMode)
              const SizedBox(width: 16),
            // Avatar in sticky bar
            _buildMyRankAvatar(myRank, 36),
            const SizedBox(width: 12),
            Text(
              "KAMU",
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (isNormalMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${myRank.xp} XP",
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${myRank.rankInfo.rankName} ${myRank.rankInfo.subTier}",
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${myRank.rankInfo.stars}/${myRank.rankInfo.maxStars}",
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
        ),
      ),
    );
  }

  /// Build avatar for MyRank (sticky bar) — supports Base64 & network URLs
  Widget _buildMyRankAvatar(MyRank myRank, double size) {
    final avatarUrl = myRank.avatar != null && myRank.avatar!.isNotEmpty
        ? Environment.resolveUrl(myRank.avatar!)
        : null;

    Widget imageWidget;
    if (avatarUrl != null && avatarUrl.startsWith('data:image')) {
      try {
        final base64String = avatarUrl.split(',').last;
        imageWidget = Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _buildMyRankInitials(size),
        );
      } catch (e) {
        imageWidget = _buildMyRankInitials(size);
      }
    } else if (avatarUrl != null) {
      imageWidget = Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildMyRankInitials(size),
      );
    } else {
      imageWidget = _buildMyRankInitials(size);
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  Widget _buildMyRankInitials(double size) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        color: Colors.white70,
        size: size * 0.6,
      ),
    );
  }

  Widget _buildAvatar(LeaderboardUser user, double size) {
    final avatarUrl = user.avatar != null && user.avatar!.isNotEmpty
        ? Environment.resolveUrl(user.avatar!)
        : null;

    Widget imageWidget;
    if (avatarUrl != null && avatarUrl.startsWith('data:image')) {
      try {
        final base64String = avatarUrl.split(',').last;
        imageWidget = Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _buildInitials(user),
        );
      } catch (e) {
        imageWidget = _buildInitials(user);
      }
    } else if (avatarUrl != null) {
      imageWidget = Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildInitials(user),
      );
    } else {
      imageWidget = _buildInitials(user);
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(child: imageWidget),
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

  void _showPublicProfileSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<PublicProfileModel>(
          future: ProfileRepository().getPublicProfile(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Center(child: SkeletonLoader.profile(size: 60)),
              );
            }

            if (snapshot.hasError) {
              return Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat profil:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = snapshot.data!;
            return Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle indicator
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Avatar
                  AnimatedGlowingAvatar(
                    avatar: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: _buildProfileAvatarImage(
                          profile.pictureUrl,
                          profile.fullName,
                          80,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name & Rank
                  Text(
                    profile.fullName ?? 'Pengguna',
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.fireFlameCurved,
                        color: Color(0xFFFF9600),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${profile.streak} Hari',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF9600),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const FaIcon(
                        FontAwesomeIcons.bolt,
                        color: Color(0xFF2CB0FA),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${profile.totalXp} XP',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2CB0FA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // TKK Highlight (show up to 3)
                  if (profile.tkkBadges.isNotEmpty) ...[
                    Text(
                      'TKK Terakhir:',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: profile.tkkBadges
                          .take(3)
                          .map(
                            (badge) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _scoutGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _scoutGreen.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                badge,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _scoutGreenDark,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _scoutGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close sheet
                        Navigator.pushNamed(
                          context,
                          AppRoutes.publicProfile,
                          arguments: profile,
                        );
                      },
                      child: Text(
                        'LIHAT PROFIL PENUH',
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileAvatarImage(String? url, String? name, double size) {
    if (url == null || url.isEmpty) {
      return _buildInitialsFromStr(name ?? "?");
    }

    final avatarUrl = Environment.resolveUrl(url);

    if (avatarUrl.startsWith('data:image')) {
      try {
        final base64String = avatarUrl.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _buildInitialsFromStr(name ?? "?"),
        );
      } catch (e) {
        return _buildInitialsFromStr(name ?? "?");
      }
    }

    return Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => _buildInitialsFromStr(name ?? "?"),
    );
  }

  Widget _buildInitialsFromStr(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "?",
        style: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class AnimatedGlowingAvatar extends StatefulWidget {
  final Widget avatar;

  const AnimatedGlowingAvatar({super.key, required this.avatar});

  @override
  State<AnimatedGlowingAvatar> createState() => _AnimatedGlowingAvatarState();
}

class _AnimatedGlowingAvatarState extends State<AnimatedGlowingAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GlowingRingPainter(progress: _controller.value),
          child: Padding(
            padding: const EdgeInsets.all(6.0), // Space for the ring and glow
            child: widget.avatar,
          ),
        );
      },
    );
  }
}

class _GlowingRingPainter extends CustomPainter {
  final double progress;

  _GlowingRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3.0; // Subtract half of stroke width

    final sweepGradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 3.141592653589793 * 2,
      transform: GradientRotation(progress * 3.141592653589793 * 2),
      colors: const [
        Color(0xFFFFD700), // Gold
        Color(0xFFFFA000), // Amber
        Color(0xFFFFF8E1), // Bright center of light
        Color(0xFFFFA000), // Amber
        Color(0xFFFFD700), // Gold
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    // Draw the glow (shadow)
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..shader = sweepGradient.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    
    canvas.drawCircle(center, radius, shadowPaint);

    // Draw the actual border ring
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = sweepGradient.createShader(rect);

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _GlowingRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
