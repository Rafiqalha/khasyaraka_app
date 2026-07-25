import '../models/mission_model.dart';

abstract class MissionRepository {
  Future<MissionModel?> getTodayMission();
}
