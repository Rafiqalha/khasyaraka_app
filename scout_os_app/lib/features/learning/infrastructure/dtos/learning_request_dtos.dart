class JourneyRequest {
  final String academyId;
  final String curriculumId;

  const JourneyRequest({
    required this.academyId,
    required this.curriculumId,
  });

  Map<String, dynamic> toJson() => {
        'academyId': academyId,
        'curriculumId': curriculumId,
      };
}

class MissionSubmissionRequestDto {
  final String learningSessionId;
  final String nodeId;
  final String language;
  final String code;
  final String clientVersion;
  final int attempt;

  const MissionSubmissionRequestDto({
    required this.learningSessionId,
    required this.nodeId,
    required this.language,
    required this.code,
    required this.clientVersion,
    required this.attempt,
  });

  Map<String, dynamic> toJson() => {
        'learningSessionId': learningSessionId,
        'nodeId': nodeId,
        'language': language,
        'code': code,
        'clientVersion': clientVersion,
        'attempt': attempt,
      };
}
