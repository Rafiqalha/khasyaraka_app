import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/leaderboard/controllers/leaderboard_controller.dart';
import 'package:scout_os_app/features/leaderboard/models/leaderboard_model.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  // Light Nature Scout color palette
  static const _backgroundWhite = Color(0xFFFFFFFF);
  static const _backgroundOffWhite = Color(0xFFF5F5F5);
  static const _forestGreen = Color(0xFF2E7D32);
  static const _forestGreenLight = Color(0xFF4CAF50);
  static const _forestGreenDark = Color(0xFF1B5E20);
  static const _goldYellow = Color(0xFFFFC107);
  static const _textDark = Color(0xFF212121);
  static const _textGrey = Color(0xFF757575);
  static const _textLightGrey = Color(0xFFBDBDBD);
  static const _silver = Color(0xFF9E9E9E);
  static const _bronze = Color(0xFF8D6E63);
  static const _cardWhite = Color(0xFFFFFFFF);
  static const _borderLight = Color(0xFFE0E0E0);

  final bool _isProMember = false;
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = Provider.of<LeaderboardController>(context, listen: false);
        debugPrint('🔍 [RANK_PAGE] initState: controller.hashCode=${controller.hashCode}');
        controller.loadLeaderboard(limit: 50);
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = Provider.of<LeaderboardController>(context, listen: false);
        debugPrint('🔍 [RANK_PAGE] didChangeDependencies: controller.hashCode=${controller.hashCode}');
        if (!controller.isLoading) {
          debugPrint('🔄 [RANK_PAGE] Page visible, refreshing leaderboard...');
          controller.loadLeaderboard(limit: 50);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardController>(
      builder: (context, controller, _) {
        debugPrint('🔍 [RANK_PAGE] build: controller.hashCode=${controller.hashCode}');
        
        if (controller.isLoading) {
          return Scaffold(
            backgroundColor: _backgroundWhite,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_forestGreen),
              ),
            ),
          );
        }

        if (controller.errorMessage != null) {
          return Scaffold(
            backgroundColor: _backgroundWhite,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _textGrey,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.loadLeaderboard(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forestGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Coba Lagi',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final topUsers = controller.topUsers;
        final myRank = controller.myRank;

        debugPrint('📊 [RANK_PAGE] UI State: myRank=${myRank != null ? 'present (rank=${myRank.rank}, xp=${myRank.xp})' : 'null'}, topUsers=${topUsers.length}');
        debugPrint('📊 [RANK_PAGE] Controller state: isLoading=${controller.isLoading}, hasData=${controller.leaderboardData != null}, topUsers.length=${topUsers.length}');

        final currentUser = myRank != null
            ? _LeaderboardUser(
                rank: myRank.rank,
                name: 'Kamu',
                xp: myRank.xp,
                badge: _getBadge(myRank.rank),
                trendUp: false,
                isMe: true,
              )
            : _LeaderboardUser(
                rank: 0,
                name: 'Kamu',
                xp: 0,
                badge: 'Belum ada rank',
                trendUp: false,
                isMe: true,
              );
        
        debugPrint('📊 [RANK_PAGE] Current user UI: rank=${currentUser.rank}, xp=${currentUser.xp}, badge=${currentUser.badge}');

        // Separate top 3 and other users
        final top3 = topUsers.take(3).toList();
        final otherUsers = topUsers.length > 3 ? topUsers.sublist(3) : <LeaderboardUser>[];

        return Scaffold(
          backgroundColor: _backgroundWhite,
          body: RefreshIndicator(
            onRefresh: () => controller.refresh(),
            color: _forestGreen,
            child: Stack(
              children: [
                // Main content column
                Column(
                  children: [
                    // Header section (fixed height)
                    _buildHeaderSection(top3),
                    // Podium section (fixed height ~250px)
                    _buildPodiumSection(top3),
                    // List section (expandable, scrollable)
                    Expanded(
                      child: _buildListSection(otherUsers, topUsers.length),
                    ),
                  ],
                ),
                // Sticky bottom bar (overlay)
                _buildStickyMeBar(currentUser),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(List<LeaderboardUser> top3) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: _backgroundWhite,
        border: Border(
          bottom: BorderSide(color: _borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LIGA PENEGAK',
                style: GoogleFonts.poppins(
                  color: _forestGreenDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              _buildCategoryTabs(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _forestGreenLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Berakhir dalam 2 hari 4 jam',
                  style: GoogleFonts.poppins(
                    color: _forestGreenDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumSection(List<LeaderboardUser> top3) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: _backgroundOffWhite,
      ),
      child: Center(
        child: _buildPodium(top3),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _backgroundOffWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabButton('LATIHAN', 0),
          _tabButton('CYBER', 1),
          _tabButton('SURVIVAL', 2),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final active = _selectedCategory == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _forestGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: active ? Colors.white : _textGrey,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardUser> top3) {
    if (top3.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'Belum ada data',
            style: GoogleFonts.poppins(
              color: _textLightGrey,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    if (top3.length == 1) {
      return SizedBox(
        height: 150,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: _podiumUser(top3[0], rank: 1, size: 84, color: _goldYellow, crown: true),
                ),
              );
            },
          ),
        ),
      );
    }

    if (top3.length == 2) {
      return SizedBox(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.translate(
                    offset: const Offset(0, 16),
                    child: _podiumUser(top3[1], rank: 2, size: 64, color: _silver),
                  ),
                );
              },
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.translate(
                    offset: const Offset(0, -4),
                    child: _podiumUser(top3[0], rank: 1, size: 84, color: _goldYellow, crown: true),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.translate(
                  offset: const Offset(0, 16),
                  child: _podiumUser(top3[1], rank: 2, size: 64, color: _silver),
                ),
              );
            },
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: _podiumUser(top3[0], rank: 1, size: 84, color: _goldYellow, crown: true),
                ),
              );
            },
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.translate(
                  offset: const Offset(0, 18),
                  child: _podiumUser(top3[2], rank: 3, size: 64, color: _bronze),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _podiumUser(
    LeaderboardUser user, {
    required int rank,
    required double size,
    required Color color,
    bool crown = false,
  }) {
    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (crown)
            Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                Icons.emoji_events,
                color: _goldYellow,
                size: 20,
              ),
            ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: _cardWhite,
              backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Text(
                      _getInitials(user.name),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                        fontSize: size * 0.3,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              user.name,
              style: GoogleFonts.poppins(
                color: _textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${user.xp} XP',
            style: GoogleFonts.poppins(
              color: _forestGreenDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(List<LeaderboardUser> otherUsers, int totalUsers) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: otherUsers.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.leaderboard_outlined,
                      size: 64,
                      color: _textLightGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      totalUsers == 0
                          ? 'Jadilah yang pertama menantang juara!'
                          : 'Hanya $totalUsers pengguna di leaderboard',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _textGrey,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Bottom padding for sticky bar
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                final user = otherUsers[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _rankTile(user, totalCount: totalUsers),
                );
              },
            ),
    );
  }

  Widget _rankTile(LeaderboardUser user, {required int totalCount}) {
    final isPromotion = user.rank <= 5;
    final isDemotion = user.rank >= totalCount - 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _cardWhite,
        border: Border.all(
          color: isPromotion
              ? _forestGreen.withValues(alpha: 0.3)
              : isDemotion
                  ? Colors.redAccent.withValues(alpha: 0.2)
                  : _borderLight,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '#${user.rank}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: user.rank < 10 ? _forestGreen : _textGrey,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 14),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _borderLight, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: _backgroundOffWhite,
              backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Text(
                      _getInitials(user.name),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: _forestGreen,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getBadge(user.rank).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textGrey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '${user.xp}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: _forestGreen,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'XP',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: _textGrey,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyMeBar(_LeaderboardUser me) {
    final isLocked = _selectedCategory != 0 && !_isProMember;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              _backgroundWhite.withValues(alpha: 0.95),
              _backgroundWhite,
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _forestGreen,
                _forestGreenDark,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _forestGreen.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: isLocked ? _showUpgradeDialog : null,
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(
                      _getInitials(me.name),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: _forestGreen,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLocked
                            ? 'KAMU ▸ POSISI - (0 XP)'
                            : me.rank > 0
                                ? 'KAMU ▸ RANK #${me.rank} | ${me.xp} XP'
                                : 'KAMU ▸ BELUM ADA RANK (${me.xp} XP)',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLocked
                            ? 'AKTIFKAN PRO UNTUK BERSAING DI LIGA INI!'
                            : me.badge.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _goldYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLocked ? '0 XP' : '${me.xp} XP',
                    style: GoogleFonts.poppins(
                      color: _textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return parts.take(2).map((p) => p.characters.first.toUpperCase()).join();
  }

  String _getBadge(int rank) {
    if (rank <= 3) return 'Juara';
    if (rank <= 10) return 'Siaga Mula';
    if (rank <= 20) return 'Penegak';
    return 'Pramuka';
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _goldYellow, width: 1),
        ),
        title: Text(
          'UPGRADE KE PRO',
          style: GoogleFonts.poppins(
            color: _forestGreenDark,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Aktifkan Pro untuk bersaing di Liga Cyber & Survival.',
          style: GoogleFonts.poppins(
            color: _textGrey,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'NANTI',
              style: GoogleFonts.poppins(
                color: _textGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _forestGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'UPGRADE',
              style: GoogleFonts.poppins(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardUser {
  _LeaderboardUser({
    required this.rank,
    required this.name,
    required this.xp,
    required this.badge,
    required this.trendUp,
    required this.isMe,
  });

  final int rank;
  final String name;
  final int xp;
  final String badge;
  final bool trendUp;
  final bool isMe;
}
