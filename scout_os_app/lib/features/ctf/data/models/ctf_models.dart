class CTFRoom {
  final int id;
  final int roomId;
  final String phase;
  final DateTime? phaseStartedAt;
  final int defenseDurationSec;
  final int attackDurationSec;

  CTFRoom({
    required this.id,
    required this.roomId,
    required this.phase,
    this.phaseStartedAt,
    required this.defenseDurationSec,
    required this.attackDurationSec,
  });

  factory CTFRoom.fromJson(Map<String, dynamic> json) {
    return CTFRoom(
      id: json['id'],
      roomId: json['room_id'],
      phase: json['phase'],
      phaseStartedAt: json['phase_started_at'] != null ? DateTime.parse(json['phase_started_at']) : null,
      defenseDurationSec: json['defense_duration_sec'],
      attackDurationSec: json['attack_duration_sec'],
    );
  }
}

class CTFTeam {
  final int id;
  final int ctfRoomId;
  final int teamId;
  final String flag;
  final String defenseImageUrl;
  final String cipherMethod;
  final String cipherKey;
  final bool flagFound;
  final DateTime? flagFoundAt;
  final int? flagFoundBy;
  final bool patchCompleted;
  final int? patchTimeSec;
  final int score;

  CTFTeam({
    required this.id,
    required this.ctfRoomId,
    required this.teamId,
    required this.flag,
    required this.defenseImageUrl,
    required this.cipherMethod,
    required this.cipherKey,
    required this.flagFound,
    this.flagFoundAt,
    this.flagFoundBy,
    required this.patchCompleted,
    this.patchTimeSec,
    required this.score,
  });

  factory CTFTeam.fromJson(Map<String, dynamic> json) {
    return CTFTeam(
      id: json['id'],
      ctfRoomId: json['ctf_room_id'],
      teamId: json['team_id'],
      flag: json['flag'] ?? '',
      defenseImageUrl: json['defense_image_url'] ?? '',
      cipherMethod: json['cipher_method'] ?? '',
      cipherKey: json['cipher_key'] ?? '',
      flagFound: json['flag_found'] ?? false,
      flagFoundAt: json['flag_found_at'] != null ? DateTime.parse(json['flag_found_at']) : null,
      flagFoundBy: json['flag_found_by'],
      patchCompleted: json['patch_completed'] ?? false,
      patchTimeSec: json['patch_time_sec'],
      score: json['score'] ?? 0,
    );
  }
}

class CTFTeamPublicView {
  final int id;
  final int ctfRoomId;
  final int teamId;
  final String defenseImageUrl;
  final String cipherMethod;
  final bool flagFound;
  final DateTime? flagFoundAt;
  final int? flagFoundBy;
  final bool patchCompleted;
  final int score;

  CTFTeamPublicView({
    required this.id,
    required this.ctfRoomId,
    required this.teamId,
    required this.defenseImageUrl,
    required this.cipherMethod,
    required this.flagFound,
    this.flagFoundAt,
    this.flagFoundBy,
    required this.patchCompleted,
    required this.score,
  });

  factory CTFTeamPublicView.fromJson(Map<String, dynamic> json) {
    return CTFTeamPublicView(
      id: json['id'],
      ctfRoomId: json['ctf_room_id'],
      teamId: json['team_id'],
      defenseImageUrl: json['defense_image_url'] ?? '',
      cipherMethod: json['cipher_method'] ?? '',
      flagFound: json['flag_found'] ?? false,
      flagFoundAt: json['flag_found_at'] != null ? DateTime.parse(json['flag_found_at']) : null,
      flagFoundBy: json['flag_found_by'],
      patchCompleted: json['patch_completed'] ?? false,
      score: json['score'] ?? 0,
    );
  }
}

class CTFAttackLog {
  final int id;
  final int ctfRoomId;
  final int attackingTeamId;
  final int userId;
  final String prompt;
  final String aiResponse;
  final int tokensUsed;
  final DateTime createdAt;

  CTFAttackLog({
    required this.id,
    required this.ctfRoomId,
    required this.attackingTeamId,
    required this.userId,
    required this.prompt,
    required this.aiResponse,
    required this.tokensUsed,
    required this.createdAt,
  });

  factory CTFAttackLog.fromJson(Map<String, dynamic> json) {
    return CTFAttackLog(
      id: json['id'],
      ctfRoomId: json['ctf_room_id'],
      attackingTeamId: json['attacking_team_id'],
      userId: json['user_id'],
      prompt: json['prompt'],
      aiResponse: json['ai_response'],
      tokensUsed: json['tokens_used'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CTFPatchChallenge {
  final int id;
  final int ctfRoomId;
  final int teamId;
  final String challengeType;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final String? userAnswer;
  final bool solved;
  final DateTime? solvedAt;
  final int? timeTakenSec;

  CTFPatchChallenge({
    required this.id,
    required this.ctfRoomId,
    required this.teamId,
    required this.challengeType,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    this.userAnswer,
    required this.solved,
    this.solvedAt,
    this.timeTakenSec,
  });

  factory CTFPatchChallenge.fromJson(Map<String, dynamic> json) {
    return CTFPatchChallenge(
      id: json['id'],
      ctfRoomId: json['ctf_room_id'],
      teamId: json['team_id'],
      challengeType: json['challenge_type'],
      difficulty: json['difficulty'],
      question: json['question'],
      correctAnswer: json['correct_answer'],
      userAnswer: json['user_answer'],
      solved: json['solved'] ?? false,
      solvedAt: json['solved_at'] != null ? DateTime.parse(json['solved_at']) : null,
      timeTakenSec: json['time_taken_sec'],
    );
  }
}

class CTFStateResponse {
  final CTFRoom room;
  final int phaseTimeLeft;
  final CTFTeam myTeam;
  final CTFTeamPublicView opponentTeam;
  final List<CTFAttackLog> recentLogs;
  final CTFPatchChallenge? patchChallenge;

  CTFStateResponse({
    required this.room,
    required this.phaseTimeLeft,
    required this.myTeam,
    required this.opponentTeam,
    required this.recentLogs,
    this.patchChallenge,
  });

  factory CTFStateResponse.fromJson(Map<String, dynamic> json) {
    return CTFStateResponse(
      room: CTFRoom.fromJson(json['room']),
      phaseTimeLeft: json['phase_time_left'],
      myTeam: CTFTeam.fromJson(json['my_team']),
      opponentTeam: CTFTeamPublicView.fromJson(json['opponent_team']),
      recentLogs: (json['recent_logs'] as List).map((e) => CTFAttackLog.fromJson(e)).toList(),
      patchChallenge: json['patch_challenge'] != null ? CTFPatchChallenge.fromJson(json['patch_challenge']) : null,
    );
  }
}

class CulturalImage {
  final String id;
  final String name;
  final String url;
  final String region;

  CulturalImage({
    required this.id,
    required this.name,
    required this.url,
    required this.region,
  });
}

final culturalImagePool = [
  CulturalImage(
    id: "tapis_lampung",
    name: "Tapis Lampung",
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Tapis_Lampung.jpg/640px-Tapis_Lampung.jpg",
    region: "Lampung",
  ),
  CulturalImage(
    id: "batik_solo",
    name: "Batik Solo",
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Batik_Indonesia_by_Crisco_1492.jpg/640px-Batik_Indonesia_by_Crisco_1492.jpg",
    region: "Jawa Tengah",
  ),
  CulturalImage(
    id: "ulos_batak",
    name: "Ulos Batak",
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Ulos.jpg/640px-Ulos.jpg",
    region: "Sumatera Utara",
  ),
  CulturalImage(
    id: "tenun_ntt",
    name: "Tenun NTT",
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Tenun_ikat_Sumba.jpg/640px-Tenun_ikat_Sumba.jpg",
    region: "NTT",
  ),
  CulturalImage(
    id: "songket_palembang",
    name: "Songket Palembang",
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Songket_Palembang.jpg/640px-Songket_Palembang.jpg",
    region: "Sumatera Selatan",
  ),
];
