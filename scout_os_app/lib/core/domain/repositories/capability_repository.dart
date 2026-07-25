import '../models/capability_model.dart';

abstract class CapabilityRepository {
  Future<CapabilityModel> getCapabilityProfile(String userId);
}
