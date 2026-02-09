/// Leaderboard Models
/// 
/// Models for leaderboard API responses matching FastAPI schemas.

import 'package:flutter/foundation.dart';

class LeaderboardUser {
  final int rank;
  final String id;
  final String name;
  final int xp;
  final String? avatar;

  LeaderboardUser({
    required this.rank,
    required this.id,
    required this.name,
    required this.xp,
    this.avatar,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    // Defensive type casting for rank
    int rankValue;
    if (json['rank'] is int) {
      rankValue = json['rank'] as int;
    } else if (json['rank'] is String) {
      rankValue = int.tryParse(json['rank'] as String) ?? 0;
    } else {
      rankValue = (json['rank'] as num?)?.toInt() ?? 0;
    }

    // Defensive type casting for id
    String idValue;
    if (json['id'] is int) {
      idValue = json['id'].toString();
    } else if (json['id'] is String) {
      idValue = json['id'] as String;
    } else {
      idValue = json['id']?.toString() ?? '';
    }

    // Defensive type casting for name (handle both 'name' and 'full_name')
    String nameValue = json['name']?.toString() ?? 
                      json['full_name']?.toString() ?? 
                      'Unknown User';

    // Defensive type casting for xp (handle both 'xp' and 'total_xp')
    int xpValue;
    if (json['xp'] != null) {
      if (json['xp'] is int) {
        xpValue = json['xp'] as int;
      } else if (json['xp'] is String) {
        xpValue = int.tryParse(json['xp'] as String) ?? 0;
      } else {
        xpValue = (json['xp'] as num?)?.toInt() ?? 0;
      }
    } else if (json['total_xp'] != null) {
      // Fallback to total_xp if xp is not present
      if (json['total_xp'] is int) {
        xpValue = json['total_xp'] as int;
      } else if (json['total_xp'] is String) {
        xpValue = int.tryParse(json['total_xp'] as String) ?? 0;
      } else {
        xpValue = (json['total_xp'] as num?)?.toInt() ?? 0;
      }
    } else {
      xpValue = 0;
    }

    // Defensive type casting for avatar
    String? avatarValue;
    if (json['avatar'] != null) {
      avatarValue = json['avatar']?.toString();
    } else if (json['picture_url'] != null) {
      avatarValue = json['picture_url']?.toString();
    }

    debugPrint('📊 [LEADERBOARD_USER] Parsed: rank=$rankValue, id=$idValue, name=$nameValue, xp=$xpValue, avatar=${avatarValue ?? 'null'}');

    return LeaderboardUser(
      rank: rankValue,
      id: idValue,
      name: nameValue,
      xp: xpValue,
      avatar: avatarValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'id': id,
      'name': name,
      'xp': xp,
      'avatar': avatar,
    };
  }
}

class MyRank {
  final int rank;
  final int xp;

  MyRank({
    required this.rank,
    required this.xp,
  });

  factory MyRank.fromJson(Map<String, dynamic> json) {
    debugPrint('📊 [MY_RANK] Raw JSON: $json');
    
    // Defensive type casting for rank
    int rankValue;
    if (json['rank'] is int) {
      rankValue = json['rank'] as int;
    } else if (json['rank'] is String) {
      rankValue = int.tryParse(json['rank'] as String) ?? 0;
    } else {
      rankValue = (json['rank'] as num?)?.toInt() ?? 0;
    }
    
    // ✅ CRITICAL: If rank is 0 but should not be, log warning
    // Only warn if rank is 0 but raw JSON was not null (meaning backend potential issue)
    if (rankValue == 0 && json['rank'] != null && json['xp'] != null && (json['xp'] as int) > 0) {
      debugPrint('⚠️ [MY_RANK] WARNING: Parsed rank=0 for user with XP!');
    }

    // Defensive type casting for xp (handle both 'xp' and 'total_xp')
    int xpValue;
    if (json['xp'] != null) {
      if (json['xp'] is int) {
        xpValue = json['xp'] as int;
      } else if (json['xp'] is String) {
        xpValue = int.tryParse(json['xp'] as String) ?? 0;
      } else {
        xpValue = (json['xp'] as num?)?.toInt() ?? 0;
      }
    } else if (json['total_xp'] != null) {
      // Fallback to total_xp if xp is not present
      if (json['total_xp'] is int) {
        xpValue = json['total_xp'] as int;
      } else if (json['total_xp'] is String) {
        xpValue = int.tryParse(json['total_xp'] as String) ?? 0;
      } else {
        xpValue = (json['total_xp'] as num?)?.toInt() ?? 0;
      }
    } else {
      xpValue = 0;
    }

    debugPrint('📊 [MY_RANK] Parsed: rank=$rankValue, xp=$xpValue');
    
    // ✅ CRITICAL: Validate rank >= 1 if xp > 0
    if (xpValue > 0 && rankValue == 0) {
      debugPrint('❌ [MY_RANK] ERROR: User has XP=$xpValue but rank=0! This should not happen.');
    }

    return MyRank(
      rank: rankValue,
      xp: xpValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'xp': xp,
    };
  }
}

class LeaderboardData {
  final List<LeaderboardUser> topUsers;
  final MyRank? myRank;

  LeaderboardData({
    required this.topUsers,
    this.myRank,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for top_users
    List<LeaderboardUser> topUsersList = [];
    if (json['top_users'] != null && json['top_users'] is List) {
      try {
        topUsersList = (json['top_users'] as List<dynamic>)
            .map((item) {
              try {
                return LeaderboardUser.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                debugPrint('⚠️ [LEADERBOARD_DATA] Error parsing user: $e, data: $item');
                return null;
              }
            })
            .whereType<LeaderboardUser>()
            .toList();
      } catch (e) {
        debugPrint('⚠️ [LEADERBOARD_DATA] Error parsing top_users list: $e');
      }
    }

    // Defensive parsing for my_rank
    MyRank? myRankValue;
    if (json['my_rank'] != null) {
      try {
        myRankValue = MyRank.fromJson(json['my_rank'] as Map<String, dynamic>);
      } catch (e) {
        debugPrint('⚠️ [LEADERBOARD_DATA] Error parsing my_rank: $e');
      }
    }

    debugPrint('📊 [LEADERBOARD_DATA] Parsed: ${topUsersList.length} users, myRank=${myRankValue != null ? 'present' : 'null'}');

    return LeaderboardData(
      topUsers: topUsersList,
      myRank: myRankValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top_users': topUsers.map((user) => user.toJson()).toList(),
      'my_rank': myRank?.toJson(),
    };
  }
}
