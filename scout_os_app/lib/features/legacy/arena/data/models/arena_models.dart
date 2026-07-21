class ArenaRoom {
  final int id;
  final String code;
  final String title;
  final String status;
  final int maxTeams;
  final int playersPerTeam;
  final List<ArenaTeam> teams;
  final int currentQIndex;

  ArenaRoom({
    required this.id,
    required this.code,
    required this.title,
    required this.status,
    required this.maxTeams,
    required this.playersPerTeam,
    this.teams = const [],
    this.currentQIndex = -1,
  });

  factory ArenaRoom.fromJson(Map<String, dynamic> json) {
    return ArenaRoom(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      title: json['title'] ?? 'Arena',
      status: json['status'] ?? 'waiting',
      maxTeams: json['max_teams'] ?? 2,
      playersPerTeam: json['players_per_team'] ?? 5,
      currentQIndex: json['current_q_index'] ?? -1,
      teams: (json['teams'] as List<dynamic>?)
              ?.map((t) => ArenaTeam.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class ArenaTeam {
  final int id;
  final String name;
  final int slot;
  final int totalScore;
  final List<ArenaPlayer> players;

  ArenaTeam({
    required this.id,
    required this.name,
    required this.slot,
    required this.totalScore,
    this.players = const [],
  });

  factory ArenaTeam.fromJson(Map<String, dynamic> json) {
    return ArenaTeam(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slot: json['slot'] ?? 0,
      totalScore: json['total_score'] ?? 0,
      players: (json['players'] as List<dynamic>?)
              ?.map((p) => ArenaPlayer.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class ArenaPlayer {
  final int id;
  final int userId;
  final String fullName;
  final bool isCaptain;
  final int score;

  ArenaPlayer({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.isCaptain,
    required this.score,
  });

  factory ArenaPlayer.fromJson(Map<String, dynamic> json) {
    return ArenaPlayer(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? 'Pemain',
      isCaptain: json['is_captain'] ?? false,
      score: json['score'] ?? 0,
    );
  }
}

class RoomState {
  final String status;
  final QuestionState? question;
  final List<TeamScore> leaderboard;
  final int myTeamScore;
  final bool alreadyAnswered;

  RoomState({
    required this.status,
    this.question,
    required this.leaderboard,
    required this.myTeamScore,
    required this.alreadyAnswered,
  });

  factory RoomState.fromJson(Map<String, dynamic> json) {
    return RoomState(
      status: json['status'] ?? 'waiting',
      question: json['question'] != null
          ? QuestionState.fromJson(json['question'])
          : null,
      leaderboard: (json['leaderboard'] as List<dynamic>?)
              ?.map((t) => TeamScore.fromJson(t))
              .toList() ??
          [],
      myTeamScore: json['my_team_score'] ?? 0,
      alreadyAnswered: json['already_answered'] ?? false,
    );
  }
}

class QuestionState {
  final int index;
  final int total;
  final String text;
  final String type;
  final Map<String, dynamic> payload;
  final int timeRemainingSecs;

  QuestionState({
    required this.index,
    required this.total,
    required this.text,
    required this.type,
    required this.payload,
    required this.timeRemainingSecs,
  });

  factory QuestionState.fromJson(Map<String, dynamic> json) {
    return QuestionState(
      index: json['index'] ?? 0,
      total: json['total'] ?? 10,
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      payload: json['payload'] ?? {},
      timeRemainingSecs: json['time_remaining_secs'] ?? 0,
    );
  }
}

class TeamScore {
  final String teamName;
  final int score;

  TeamScore({required this.teamName, required this.score});

  factory TeamScore.fromJson(Map<String, dynamic> json) {
    return TeamScore(
      teamName: json['team_name'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}
