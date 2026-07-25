import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scout_os_app/core/error/result.dart';
import 'package:scout_os_app/features/learning/infrastructure/dtos/learning_request_dtos.dart';
import 'package:scout_os_app/features/learning/infrastructure/sources/journey_api_client.dart';
import 'package:scout_os_app/features/learning/infrastructure/repositories/journey_repository_impl.dart';

class MockJourneyApiClient extends Mock implements JourneyApiClient {}
class FakeJourneyRequest extends Fake implements JourneyRequest {}

void main() {
  late MockJourneyApiClient mockApiClient;
  late JourneyRepositoryImpl repository;
  late Directory tempDir;

  setUp(() async {
    registerFallbackValue(FakeJourneyRequest());
    mockApiClient = MockJourneyApiClient();
    repository = JourneyRepositoryImpl(mockApiClient);
    
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox('journey_cache');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('JourneyRepositoryImpl Tests', () {
    final Map<String, dynamic> mockJson = {
      'id': 'j_1',
      'title': 'Test Journey',
      'nodes': [
        {
          'id': 'n1',
          'type': 'MISSION',
          'title': 'Mission 1',
          'estimatedSeconds': 100,
          'isRequired': true,
          'telemetryKey': 'm1'
        }
      ]
    };

    test('getCachedJourney returns Success(null) when cache is empty', () async {
      final result = await repository.getCachedJourney('j_1');
      expect(result, isA<Success>());
      expect((result as Success).value, isNull);
    });

    test('refreshJourney calls API and saves to cache', () async {
      when(() => mockApiClient.fetchJourneyJson(any())).thenAnswer((_) async => mockJson);

      final req = const JourneyRequest(academyId: 'a1', curriculumId: 'j_1');
      final result = await repository.refreshJourney(req);
      
      expect(result, isA<Success>());
      
      final box = Hive.box('journey_cache');
      final cachedStr = box.get('j_1');
      expect(cachedStr, isNotNull);
      
      final cachedJson = jsonDecode(cachedStr);
      expect(cachedJson['id'], 'j_1');
      expect(cachedJson['title'], 'Test Journey');
    });

    test('getCachedJourney returns cached data when cache exists', () async {
      final box = Hive.box('journey_cache');
      await box.put('j_1', jsonEncode(mockJson)); // mock JourneyCacheModel format

      final result = await repository.getCachedJourney('j_1');
      
      expect(result, isA<Success>());
      final journey = (result as Success).value;
      expect(journey, isNotNull);
      expect(journey!.id, 'j_1');
      expect(journey.title, 'Test Journey');
      expect(journey.nodes.length, 1);
    });
    
    test('refreshJourney returns Failure when API fails', () async {
      when(() => mockApiClient.fetchJourneyJson(any())).thenThrow(Exception('Timeout'));

      final req = const JourneyRequest(academyId: 'a1', curriculumId: 'j_1');
      final result = await repository.refreshJourney(req);
      
      expect(result, isA<Failure>());
    });
  });
}
