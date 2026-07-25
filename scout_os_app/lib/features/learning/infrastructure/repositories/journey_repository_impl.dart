import '../../../../core/error/result.dart';
import '../../domain/entities/learning_entities.dart';
import '../../domain/repositories/journey_repository.dart';
import '../dtos/journey_dto.dart';
import '../dtos/learning_request_dtos.dart';
import '../models/journey_cache_model.dart';
import '../mappers/journey_mapper.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../sources/journey_api_client.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  final JourneyApiClient apiClient;

  JourneyRepositoryImpl(this.apiClient);

  @override
  Future<Result<Journey?>> getCachedJourney(String journeyId) async {
    try {
      final box = Hive.box('journey_cache');
      final cachedString = box.get(journeyId) as String?;
      if (cachedString != null) {
        final json = jsonDecode(cachedString);
        final cacheModel = JourneyCacheModel.fromJson(json);
        return Success(cacheModel.toEntity());
      }
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(Exception('Cache Read Error: $e'), stackTrace);
    }
  }

  @override
  Future<Result<Journey>> refreshJourney(JourneyRequest request) async {
    try {
      final json = await apiClient.fetchJourneyJson(request);
      
      final dto = JourneyDto.fromJson(json);
      final entity = JourneyMapper.fromDto(dto);
      
      // Save to cache using curriculumId as the journeyId key
      final cacheModel = JourneyCacheModel.fromEntity(entity);
      final box = Hive.box('journey_cache');
      await box.put(request.curriculumId, jsonEncode(cacheModel.toJson()));

      return Success(entity);
    } catch (e, stackTrace) {
      return Failure(Exception('Network Error: $e'), stackTrace);
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
