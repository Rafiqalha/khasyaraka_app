class ModeCard {
  final String mode;
  final String title;
  final String description;
  final String icon;
  final int minPlayers;
  final int maxPlayers;

  ModeCard({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.minPlayers,
    required this.maxPlayers,
  });

  factory ModeCard.fromJson(Map<String, dynamic> json) => ModeCard(
    mode: json['mode'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    icon: json['icon'] ?? '',
    minPlayers: json['min_players'] ?? 0,
    maxPlayers: json['max_players'] ?? 0,
  );
}

class GameRoom {
  final int id;
  final String code;
  final int hostUserId;
  final String mode;
  final String status;
  final int? teamAAttacker;
  final int? teamADefender;
  final int? teamBAttacker;
  final int? teamBDefender;
  final int playerCount;
  final int currentRound;
  final int maxRounds;
  final String createdAt;
  final String? startedAt;
  final String? finishedAt;
  final List<RoomPlayer>? players;

  GameRoom({
    required this.id,
    required this.code,
    required this.hostUserId,
    required this.mode,
    required this.status,
    this.teamAAttacker,
    this.teamADefender,
    this.teamBAttacker,
    this.teamBDefender,
    required this.playerCount,
    required this.currentRound,
    required this.maxRounds,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.players,
  });

  factory GameRoom.fromJson(Map<String, dynamic> json) => GameRoom(
    id: json['id'] ?? 0,
    code: json['code'] ?? '',
    hostUserId: json['host_user_id'] ?? 0,
    mode: json['mode'] ?? '',
    status: json['status'] ?? '',
    teamAAttacker: json['team_a_attacker'],
    teamADefender: json['team_a_defender'],
    teamBAttacker: json['team_b_attacker'],
    teamBDefender: json['team_b_defender'],
    playerCount: json['player_count'] ?? 0,
    currentRound: json['current_round'] ?? 0,
    maxRounds: json['max_rounds'] ?? 0,
    createdAt: json['created_at'] ?? '',
    startedAt: json['started_at'],
    finishedAt: json['finished_at'],
    players: json['players'] != null
        ? (json['players'] as List).map((p) => RoomPlayer.fromJson(p)).toList()
        : null,
  );
}

class RoomPlayer {
  final int userId;
  final String fullName;
  final String role;
  final int team;
  final int totalXP;

  RoomPlayer({
    required this.userId,
    required this.fullName,
    required this.role,
    required this.team,
    required this.totalXP,
  });

  factory RoomPlayer.fromJson(Map<String, dynamic> json) => RoomPlayer(
    userId: json['user_id'] ?? 0,
    fullName: json['full_name'] ?? '',
    role: json['role'] ?? 'player',
    team: json['team'] ?? 0,
    totalXP: json['total_xp'] ?? 0,
  );
}

class GameState {
  final GameRoom room;
  final GameRound? round;
  final List<GameAction> actions;
  final int myScore;
  final int teamAScore;
  final int teamBScore;

  GameState({
    required this.room,
    this.round,
    required this.actions,
    required this.myScore,
    required this.teamAScore,
    required this.teamBScore,
  });

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    room: GameRoom.fromJson(json['room']),
    round: json['round'] != null ? GameRound.fromJson(json['round']) : null,
    actions: json['actions'] != null
        ? (json['actions'] as List).map((a) => GameAction.fromJson(a)).toList()
        : [],
    myScore: json['my_score'] ?? 0,
    teamAScore: json['team_a_score'] ?? 0,
    teamBScore: json['team_b_score'] ?? 0,
  );
}

class GameRound {
  final int id;
  final int roomId;
  final int roundNum;
  final int attackerTeam;
  final String scenario;
  final String status;
  final String createdAt;

  GameRound({
    required this.id,
    required this.roomId,
    required this.roundNum,
    required this.attackerTeam,
    required this.scenario,
    required this.status,
    required this.createdAt,
  });

  factory GameRound.fromJson(Map<String, dynamic> json) => GameRound(
    id: json['id'] ?? 0,
    roomId: json['room_id'] ?? 0,
    roundNum: json['round_num'] ?? 0,
    attackerTeam: json['attacker_team'] ?? 0,
    scenario: json['scenario'] ?? '',
    status: json['status'] ?? 'pending',
    createdAt: json['created_at'] ?? '',
  );
}

class GameAction {
  final int id;
  final int roundId;
  final int userId;
  final String role;
  final String input;
  final String output;
  final int scoreChange;
  final int ethicalChange;
  final int timeTakenSecs;
  final String createdAt;

  GameAction({
    required this.id,
    required this.roundId,
    required this.userId,
    required this.role,
    required this.input,
    required this.output,
    required this.scoreChange,
    required this.ethicalChange,
    required this.timeTakenSecs,
    required this.createdAt,
  });

  factory GameAction.fromJson(Map<String, dynamic> json) => GameAction(
    id: json['id'] ?? 0,
    roundId: json['round_id'] ?? 0,
    userId: json['user_id'] ?? 0,
    role: json['role'] ?? 'player',
    input: json['input'] ?? '',
    output: json['output'] ?? '',
    scoreChange: json['score_change'] ?? 0,
    ethicalChange: json['ethical_change'] ?? 0,
    timeTakenSecs: json['time_taken_secs'] ?? 0,
    createdAt: json['created_at'] ?? '',
  );
}

class LobbyState {
  final GameRoom room;
  final List<ModeCard> modes;
  final List<RoomPlayer> players;

  LobbyState({
    required this.room,
    required this.modes,
    required this.players,
  });

  factory LobbyState.fromJson(Map<String, dynamic> json) => LobbyState(
    room: GameRoom.fromJson(json['room']),
    modes: json['modes'] != null
        ? (json['modes'] as List).map((m) => ModeCard.fromJson(m)).toList()
        : [],
    players: json['players'] != null
        ? (json['players'] as List).map((p) => RoomPlayer.fromJson(p)).toList()
        : [],
  );
}
