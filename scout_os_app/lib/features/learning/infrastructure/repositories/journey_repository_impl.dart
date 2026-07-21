import '../../../../core/error/result.dart';
import '../../domain/entities/learning_entities.dart';
import '../../domain/repositories/journey_repository.dart';
import '../dtos/journey_dto.dart';
import '../mappers/journey_mapper.dart';
import '../sources/journey_api_client.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  final JourneyApiClient apiClient;

  JourneyRepositoryImpl(this.apiClient);

  @override
  Future<Result<Journey>> loadJourney(String journeyId) async {
    try {
      final json = await apiClient.fetchJourneyJson(journeyId);
      final dto = JourneyDto.fromJson(json);
      final entity = JourneyMapper.fromDto(dto);
      return Success(entity);
    } catch (e, stackTrace) {
      // In a real app, map specific HTTP/Dio exceptions here
      return Failure(Exception('Failed to load journey: $e'), stackTrace);
    }
  }

  @override
  Future<Result<List<CompetencyDelta>>> completeNode(String nodeId, Evidence evidence) async {
    try {
      // Simulated API call
      await Future.delayed(const Duration(milliseconds: 500));
      return const Success([]);
    } catch (e, stackTrace) {
      return Failure(Exception('Failed to complete node: $e'), stackTrace);
    }
  }

  @override
  Future<Result<Passport>> loadPassport(String studentId) async {
    try {
      // Simulated API call
      await Future.delayed(const Duration(milliseconds: 500));
      return const Success(Passport(
        studentId: "u_1", 
        recentDeltas: [], 
        nextRecommendationId: "j_2",
      ));
    } catch (e, stackTrace) {
      return Failure(Exception('Failed to load passport: $e'), stackTrace);
    }
  }
}
